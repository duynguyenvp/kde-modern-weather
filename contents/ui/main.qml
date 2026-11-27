import QtQuick
import QtQuick.Layouts
import QtPositioning
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import "../code/i18n.js" as I18n
import "../code/weatherIcons.js" as WeatherIcons
import "../code/units.js" as Units
import "../code/weatherApi.js" as WeatherApi

PlasmoidItem {
    id: root

    // Configuration bindings
    readonly property string langSetting: Plasmoid.configuration.language || "auto"
    readonly property string resolvedLang: I18n.resolveLang(langSetting)
    readonly property string tempUnit: Plasmoid.configuration.temperatureUnit || "celsius"
    readonly property string windUnit: Plasmoid.configuration.windSpeedUnit || "kmh"
    readonly property string pressureUnit: Plasmoid.configuration.pressureUnit || "hpa"
    readonly property string precipUnit: Plasmoid.configuration.precipitationUnit || "mm"
    readonly property string timeFormat: Plasmoid.configuration.timeFormat || "auto"
    readonly property int refreshMinutes: Math.max(5, Plasmoid.configuration.refreshIntervalMinutes || 15)
    readonly property bool useSystemLocation: Plasmoid.configuration.useSystemLocation
    readonly property bool showTemperatureInPanel: Plasmoid.configuration.showTemperatureInPanel
    readonly property bool showTemperatureUnitInPanel: Plasmoid.configuration.showTemperatureUnitInPanel
    readonly property string panelFontFamily: Plasmoid.configuration.panelFontFamily || ""
    readonly property int panelFontSize: Plasmoid.configuration.panelFontSize || 0
    readonly property string panelFontWeight: Plasmoid.configuration.panelFontWeight || "demibold"
    readonly property bool panelFontItalic: Plasmoid.configuration.panelFontItalic
    readonly property bool showConditionInTooltip: Plasmoid.configuration.showConditionInTooltip

    // Parsed manual locations
    property var savedLocations: []

    // Active resolved location: { name, admin1, country, latitude, longitude, source: "gps"|"ip"|"manual" }
    property var activeLocation: null
    property var systemLocationCache: null

    // Weather state
    property var weatherData: null
    property bool isLoading: false
    property bool isLocating: false
    property string errorMessage: ""
    property var lastUpdated: null

    // Derived weather properties for taskbar icon & tooltip
    readonly property bool hasWeather: weatherData !== null && weatherData.current !== undefined
    readonly property url currentWeatherIcon: hasWeather
        ? WeatherIcons.iconUrl(weatherData.current.weatherCode, weatherData.current.isDay)
        : WeatherIcons.metricIconUrl("not-available")
    readonly property string currentTempFormatted: hasWeather
        ? Units.formatTemp(weatherData.current.temperature, tempUnit, true)
        : "--"
    readonly property string currentTempShort: hasWeather
        ? Units.formatTemp(weatherData.current.temperature, tempUnit, false)
        : "--"
    readonly property string currentPanelTempText: hasWeather
        ? Units.formatTemp(weatherData.current.temperature, tempUnit, showTemperatureUnitInPanel)
        : "--"
    readonly property string currentConditionText: hasWeather
        ? I18n.weatherDescription(weatherData.current.weatherCode, langSetting)
        : (isLoading || isLocating ? tr("loading") : tr("noLocation"))

    function tr(key, params) {
        return I18n.t(key, root.langSetting, params);
    }

    // Dynamic plasmoid icon (used by System Tray, tooltips, and taskbar)
    Plasmoid.icon: String(currentWeatherIcon).replace(/^file:\/\//, "")

    toolTipMainText: {
        if (hasWeather && activeLocation) {
            return activeLocation.name + " — " + currentTempFormatted;
        }
        return tr("appName");
    }

    toolTipSubText: {
        if (!hasWeather) {
            if (errorMessage.length > 0) return errorMessage;
            if (isLocating) return tr("locating");
            if (isLoading) return tr("loading");
            return tr("noLocationHint");
        }
        if (!showConditionInTooltip) {
            return currentConditionText;
        }
        var c = weatherData.current;
        var lines = [
            currentConditionText,
            tr("feelsLike") + ": " + Units.formatTemp(c.feelsLike, tempUnit, true),
            tr("humidity") + ": " + Math.round(c.humidity) + "%  •  "
                + tr("wind") + ": " + Units.formatWind(c.windSpeed, windUnit)
                + " " + I18n.windDirection(c.windDirection, langSetting)
        ];
        return lines.join("\n");
    }

    switchWidth: Kirigami.Units.gridUnit * 16
    switchHeight: Kirigami.Units.gridUnit * 18

    compactRepresentation: CompactRepresentation {
        weatherRoot: root
    }

    fullRepresentation: FullRepresentation {
        weatherRoot: root
    }

    // OS Geolocation (QtPositioning / GeoClue2)
    PositionSource {
        id: positionSource
        active: false
        updateInterval: 600000 // 10 minutes

        onPositionChanged: {
            var coord = position.coordinate;
            if (coord && coord.isValid && !isNaN(coord.latitude) && !isNaN(coord.longitude)) {
                gpsFallbackTimer.stop();
                positionSource.active = false;
                root.handleSystemCoordinates(coord.latitude, coord.longitude);
            }
        }

        onSourceErrorChanged: {
            if (sourceError !== PositionSource.NoError && root.useSystemLocation && root.isLocating) {
                gpsFallbackTimer.stop();
                positionSource.active = false;
                root.fallbackToIpLocation();
            }
        }
    }

    Timer {
        id: gpsFallbackTimer
        interval: 6000
        repeat: false
        onTriggered: {
            positionSource.active = false;
            if (root.useSystemLocation && root.isLocating) {
                root.fallbackToIpLocation();
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: root.refreshMinutes * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.refreshWeather(false)
    }

    function parseSavedLocations() {
        try {
            var parsed = JSON.parse(Plasmoid.configuration.locationsJson || "[]");
            if (Array.isArray(parsed)) {
                savedLocations = parsed;
                return;
            }
        } catch (e) {
            // ignore malformed json
        }
        savedLocations = [];
    }

    function openSettings() {
        var action = Plasmoid.internalAction("configure");
        if (action) {
            action.trigger();
        }
    }

    function switchToSystemLocation() {
        Plasmoid.configuration.useSystemLocation = true;
        refreshWeather(true);
    }

    function switchToManualLocation(index) {
        if (index < 0 || index >= savedLocations.length) {
            return;
        }
        Plasmoid.configuration.activeLocationIndex = index;
        Plasmoid.configuration.useSystemLocation = false;
        refreshWeather(true);
    }

    function resolveActiveLocationAndFetch(forceRelocate) {
        errorMessage = "";
        parseSavedLocations();

        if (useSystemLocation) {
            if (!forceRelocate && systemLocationCache !== null) {
                activeLocation = systemLocationCache;
                fetchWeatherForActiveLocation();
                return;
            }
            isLocating = true;
            isLoading = true;
            gpsFallbackTimer.restart();
            positionSource.active = true;
            positionSource.update();
        } else {
            positionSource.active = false;
            gpsFallbackTimer.stop();
            isLocating = false;

            if (savedLocations.length === 0) {
                activeLocation = null;
                weatherData = null;
                isLoading = false;
                return;
            }
            var idx = Plasmoid.configuration.activeLocationIndex || 0;
            if (idx < 0 || idx >= savedLocations.length) {
                idx = 0;
            }
            var loc = savedLocations[idx];
            activeLocation = {
                name: loc.name || "",
                admin1: loc.admin1 || "",
                country: loc.country || "",
                latitude: loc.latitude,
                longitude: loc.longitude,
                source: "manual"
            };
            fetchWeatherForActiveLocation();
        }
    }

    function handleSystemCoordinates(lat, lon) {
        WeatherApi.reverseGeocode(lat, lon, resolvedLang, function(err, loc) {
            isLocating = false;
            var resolved = loc || {
                name: lat.toFixed(2) + ", " + lon.toFixed(2),
                admin1: "",
                country: "",
                latitude: lat,
                longitude: lon,
                source: "gps"
            };
            systemLocationCache = resolved;
            activeLocation = resolved;
            fetchWeatherForActiveLocation();
        });
    }

    function fallbackToIpLocation() {
        WeatherApi.fetchIpLocation(function(err, loc) {
            isLocating = false;
            if (err || !loc) {
                isLoading = false;
                errorMessage = tr("errLocation");
                return;
            }
            systemLocationCache = loc;
            activeLocation = loc;
            fetchWeatherForActiveLocation();
        });
    }

    function fetchWeatherForActiveLocation() {
        if (!activeLocation || activeLocation.latitude === undefined || activeLocation.longitude === undefined) {
            isLoading = false;
            return;
        }
        isLoading = true;
        errorMessage = "";
        WeatherApi.fetchWeather(activeLocation.latitude, activeLocation.longitude, function(err, data) {
            isLoading = false;
            if (err || !data) {
                errorMessage = tr("errNetwork");
                return;
            }
            weatherData = data;
            lastUpdated = new Date();
            errorMessage = "";
        });
    }

    function refreshWeather(forceRelocate) {
        resolveActiveLocationAndFetch(Boolean(forceRelocate));
    }

    // Watch configuration changes
    Connections {
        target: Plasmoid.configuration
        function onUseSystemLocationChanged() {
            root.refreshWeather(false);
        }
        function onLocationsJsonChanged() {
            root.parseSavedLocations();
            if (!root.useSystemLocation) {
                root.refreshWeather(false);
            }
        }
        function onActiveLocationIndexChanged() {
            if (!root.useSystemLocation) {
                root.refreshWeather(false);
            }
        }
        function onLanguageChanged() {
            // Re-resolve reverse geocode city name in new language if using system GPS
            if (root.useSystemLocation && root.systemLocationCache && root.systemLocationCache.source === "gps") {
                root.handleSystemCoordinates(root.systemLocationCache.latitude, root.systemLocationCache.longitude);
            }
        }
    }

    Component.onCompleted: {
        parseSavedLocations();
        refreshWeather(true);
    }
}
