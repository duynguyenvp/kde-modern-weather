import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

import "../code/i18n.js" as I18n
import "../code/weatherIcons.js" as WeatherIcons
import "../code/units.js" as Units

PlasmaExtras.Representation {
    id: fullRoot

    required property var weatherRoot

    implicitWidth: Kirigami.Units.gridUnit * 24
    implicitHeight: Kirigami.Units.gridUnit * 32
    Layout.minimumWidth: Kirigami.Units.gridUnit * 18
    Layout.minimumHeight: Kirigami.Units.gridUnit * 20

    readonly property var current: weatherRoot.hasWeather ? weatherRoot.weatherData.current : null
    readonly property var hourly: weatherRoot.hasWeather ? weatherRoot.weatherData.hourly : []
    readonly property var daily: weatherRoot.hasWeather ? weatherRoot.weatherData.daily : []

    header: PlasmaExtras.PlasmoidHeading {
        RowLayout {
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.ToolButton {
                id: locationButton
                Layout.fillWidth: true
                icon.name: weatherRoot.useSystemLocation ? "mark-location" : "globe"
                text: {
                    if (weatherRoot.activeLocation && weatherRoot.activeLocation.name) {
                        return weatherRoot.activeLocation.name;
                    }
                    return weatherRoot.useSystemLocation ? weatherRoot.tr("systemLocation") : weatherRoot.tr("noLocation");
                }
                display: PlasmaComponents.AbstractButton.TextBesideIcon
                onClicked: locationMenu.popup(locationButton, 0, locationButton.height)

                PlasmaComponents.ToolTip {
                    text: weatherRoot.tr("switchLocation")
                }
            }

            PlasmaComponents.Menu {
                id: locationMenu

                PlasmaComponents.MenuItem {
                    text: weatherRoot.tr("systemLocation")
                    icon.name: "mark-location"
                    checkable: true
                    checked: weatherRoot.useSystemLocation
                    onTriggered: weatherRoot.switchToSystemLocation()
                }

                PlasmaComponents.MenuSeparator {
                    visible: weatherRoot.savedLocations.length > 0
                }

                Instantiator {
                    model: weatherRoot.savedLocations
                    delegate: PlasmaComponents.MenuItem {
                        required property var modelData
                        required property int index
                        text: modelData.name + (modelData.country ? ", " + modelData.country : "")
                        icon.name: "globe"
                        checkable: true
                        checked: !weatherRoot.useSystemLocation && (Plasmoid.configuration.activeLocationIndex === index)
                        onTriggered: weatherRoot.switchToManualLocation(index)
                    }
                    onObjectAdded: function(index, object) {
                        locationMenu.insertItem(index + 2, object);
                    }
                    onObjectRemoved: function(index, object) {
                        locationMenu.removeItem(object);
                    }
                }

                PlasmaComponents.MenuSeparator {}

                PlasmaComponents.MenuItem {
                    text: weatherRoot.tr("openSettings")
                    icon.name: "configure"
                    onTriggered: weatherRoot.openSettings()
                }
            }

            PlasmaComponents.ToolButton {
                icon.name: "view-refresh"
                enabled: !weatherRoot.isLoading
                onClicked: weatherRoot.refreshWeather(true)
                PlasmaComponents.ToolTip {
                    text: weatherRoot.tr("refresh")
                }
            }

            PlasmaComponents.ToolButton {
                icon.name: "configure"
                onClicked: weatherRoot.openSettings()
                PlasmaComponents.ToolTip {
                    text: weatherRoot.tr("openSettings")
                }
            }
        }
    }

    // Main content
    QQC2.ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: Kirigami.Units.largeSpacing

            // Empty / Error / Initial Loading state
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 16
                visible: !weatherRoot.hasWeather

                ColumnLayout {
                    anchors.centerIn: parent
                    width: parent.width - Kirigami.Units.largeSpacing * 2
                    spacing: Kirigami.Units.mediumSpacing

                    PlasmaComponents.BusyIndicator {
                        Layout.alignment: Qt.AlignHCenter
                        running: weatherRoot.isLoading || weatherRoot.isLocating
                        visible: running
                    }

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                        Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                        source: weatherRoot.errorMessage.length > 0 ? "dialog-warning" : "weather-clear"
                        visible: !(weatherRoot.isLoading || weatherRoot.isLocating)
                    }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.bold: true
                        text: {
                            if (weatherRoot.isLocating) return weatherRoot.tr("locating");
                            if (weatherRoot.isLoading) return weatherRoot.tr("loading");
                            if (weatherRoot.errorMessage.length > 0) return weatherRoot.errorMessage;
                            return weatherRoot.tr("noLocation");
                        }
                    }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        opacity: 0.7
                        visible: !(weatherRoot.isLoading || weatherRoot.isLocating) && weatherRoot.errorMessage.length === 0
                        text: weatherRoot.tr("noLocationHint")
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Kirigami.Units.smallSpacing
                        visible: !(weatherRoot.isLoading || weatherRoot.isLocating)

                        PlasmaComponents.Button {
                            text: weatherRoot.tr("retry")
                            icon.name: "view-refresh"
                            visible: weatherRoot.errorMessage.length > 0
                            onClicked: weatherRoot.refreshWeather(true)
                        }

                        PlasmaComponents.Button {
                            text: weatherRoot.tr("openSettings")
                            icon.name: "configure"
                            onClicked: weatherRoot.openSettings()
                        }
                    }
                }
            }

            // Hero Weather Card
            Rectangle {
                id: heroCard
                visible: weatherRoot.hasWeather
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.smallSpacing
                Layout.bottomMargin: 0
                implicitHeight: heroColumn.implicitHeight + Kirigami.Units.largeSpacing * 2
                radius: Kirigami.Units.cornerRadius * 2

                readonly property var gradColors: current
                    ? WeatherIcons.accentGradient(current.weatherCode, current.isDay)
                    : ["#2563eb", "#38bdf8"]

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: heroCard.gradColors[0] }
                    GradientStop { position: 1.0; color: heroCard.gradColors[1] }
                }

                ColumnLayout {
                    id: heroColumn
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.largeSpacing
                    spacing: Kirigami.Units.smallSpacing

                    // Subtitle: region/country + location source badge
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        QQC2.Label {
                            Layout.fillWidth: true
                            color: "#e2e8f0"
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            elide: Text.ElideRight
                            text: {
                                if (!weatherRoot.activeLocation) return "";
                                var parts = [];
                                if (weatherRoot.activeLocation.admin1) parts.push(weatherRoot.activeLocation.admin1);
                                if (weatherRoot.activeLocation.country) parts.push(weatherRoot.activeLocation.country);
                                return parts.join(", ");
                            }
                        }

                        Rectangle {
                            radius: height / 2
                            color: "#33ffffff"
                            implicitWidth: sourceLabel.implicitWidth + Kirigami.Units.mediumSpacing * 2
                            implicitHeight: sourceLabel.implicitHeight + 4

                            QQC2.Label {
                                id: sourceLabel
                                anchors.centerIn: parent
                                color: "#ffffff"
                                font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.9
                                text: {
                                    if (!weatherRoot.activeLocation) return "";
                                    if (weatherRoot.activeLocation.source === "gps") return weatherRoot.tr("systemLocationGps");
                                    if (weatherRoot.activeLocation.source === "ip") return weatherRoot.tr("systemLocationIp");
                                    return weatherRoot.tr("manualLocation");
                                }
                            }
                        }
                    }

                    // Main Temp & Icon Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.largeSpacing

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            QQC2.Label {
                                text: weatherRoot.currentTempFormatted
                                color: "#ffffff"
                                font.pixelSize: 42
                                font.weight: Font.Bold
                            }

                            QQC2.Label {
                                text: weatherRoot.currentConditionText
                                color: "#f8fafc"
                                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
                                font.weight: Font.Medium
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }

                        Image {
                            source: weatherRoot.currentWeatherIcon
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                            Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                            Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                            sourceSize.width: Math.round(Kirigami.Units.iconSizes.huge * Screen.devicePixelRatio)
                            sourceSize.height: Math.round(Kirigami.Units.iconSizes.huge * Screen.devicePixelRatio)
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    // Feels like + High/Low
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.largeSpacing

                        QQC2.Label {
                            color: "#e2e8f0"
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            text: current
                                ? weatherRoot.tr("feelsLike") + ": " + Units.formatTemp(current.feelsLike, weatherRoot.tempUnit, true)
                                : ""
                        }

                        Item { Layout.fillWidth: true }

                        QQC2.Label {
                            color: "#ffffff"
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            font.weight: Font.DemiBold
                            text: current
                                ? weatherRoot.tr("highLow", {
                                    high: Units.formatTemp(current.tempMax, weatherRoot.tempUnit, false),
                                    low: Units.formatTemp(current.tempMin, weatherRoot.tempUnit, false)
                                })
                                : ""
                        }
                    }
                }
            }

            // Hourly Forecast Card
            Rectangle {
                visible: weatherRoot.hasWeather && hourly.length > 0
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
                implicitHeight: hourlyCol.implicitHeight + Kirigami.Units.mediumSpacing * 2
                radius: Kirigami.Units.cornerRadius * 1.5
                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.06)

                ColumnLayout {
                    id: hourlyCol
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.mediumSpacing
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents.Label {
                        text: weatherRoot.tr("hourlyForecast")
                        font.weight: Font.DemiBold
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        opacity: 0.8
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 5.2
                        orientation: ListView.Horizontal
                        spacing: Kirigami.Units.smallSpacing
                        clip: true
                        model: fullRoot.hourly

                        delegate: ColumnLayout {
                            required property var modelData
                            required property int index
                            width: Kirigami.Units.gridUnit * 3.2
                            spacing: 3

                            PlasmaComponents.Label {
                                Layout.alignment: Qt.AlignHCenter
                                font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.9
                                font.weight: index === 0 ? Font.Bold : Font.Normal
                                opacity: index === 0 ? 1.0 : 0.75
                                text: index === 0
                                    ? weatherRoot.tr("now")
                                    : Units.formatIsoTime(modelData.time, weatherRoot.timeFormat)
                            }

                            Image {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                mipmap: true
                                sourceSize.width: Math.round(Kirigami.Units.iconSizes.medium * Screen.devicePixelRatio)
                                sourceSize.height: Math.round(Kirigami.Units.iconSizes.medium * Screen.devicePixelRatio)
                                source: WeatherIcons.iconUrl(modelData.weatherCode, modelData.isDay)
                            }

                            PlasmaComponents.Label {
                                Layout.alignment: Qt.AlignHCenter
                                font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.85
                                color: Kirigami.Theme.linkColor
                                text: (modelData.precipProb && modelData.precipProb > 0) ? (modelData.precipProb + "%") : " "
                            }

                            PlasmaComponents.Label {
                                Layout.alignment: Qt.AlignHCenter
                                font.weight: Font.DemiBold
                                text: Units.formatTemp(modelData.temperature, weatherRoot.tempUnit, false)
                            }
                        }
                    }
                }
            }

            // Details Metrics Grid
            GridLayout {
                visible: weatherRoot.hasWeather
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
                columns: 2
                columnSpacing: Kirigami.Units.smallSpacing
                rowSpacing: Kirigami.Units.smallSpacing

                Repeater {
                    model: current ? [
                        {
                            icon: WeatherIcons.metricIconUrl("humidity"),
                            label: weatherRoot.tr("humidity"),
                            value: Math.round(current.humidity) + "%"
                        },
                        {
                            icon: WeatherIcons.metricIconUrl("wind"),
                            label: weatherRoot.tr("wind"),
                            value: Units.formatWind(current.windSpeed, weatherRoot.windUnit)
                                + " " + I18n.windDirection(current.windDirection, weatherRoot.langSetting)
                        },
                        {
                            icon: WeatherIcons.metricIconUrl("uv-index"),
                            label: weatherRoot.tr("uvIndex"),
                            value: current.uvIndex !== null
                                ? (current.uvIndex.toFixed(1) + " (" + I18n.uvLevel(current.uvIndex, weatherRoot.langSetting) + ")")
                                : "--"
                        },
                        {
                            icon: WeatherIcons.metricIconUrl("barometer"),
                            label: weatherRoot.tr("pressure"),
                            value: Units.formatPressure(current.pressure, weatherRoot.pressureUnit)
                        },
                        {
                            icon: WeatherIcons.metricIconUrl("mist"),
                            label: weatherRoot.tr("visibility"),
                            value: Units.formatVisibility(current.visibility, weatherRoot.tempUnit, weatherRoot.windUnit)
                        },
                        {
                            icon: WeatherIcons.metricIconUrl("sunrise"),
                            label: weatherRoot.tr("sunrise") + " / " + weatherRoot.tr("sunset"),
                            value: Units.formatIsoTime(current.sunrise, weatherRoot.timeFormat)
                                + " / " + Units.formatIsoTime(current.sunset, weatherRoot.timeFormat)
                        }
                    ] : []

                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: metricRow.implicitHeight + Kirigami.Units.mediumSpacing * 1.6
                        radius: Kirigami.Units.cornerRadius * 1.5
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.06)

                        RowLayout {
                            id: metricRow
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.mediumSpacing * 0.8
                            spacing: Kirigami.Units.smallSpacing

                            Image {
                                source: modelData.icon
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                mipmap: true
                                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                                Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                                sourceSize.width: Math.round(Kirigami.Units.iconSizes.smallMedium * Screen.devicePixelRatio)
                                sourceSize.height: Math.round(Kirigami.Units.iconSizes.smallMedium * Screen.devicePixelRatio)
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                PlasmaComponents.Label {
                                    text: modelData.label
                                    font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.9
                                    opacity: 0.7
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                PlasmaComponents.Label {
                                    text: modelData.value
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }

            // 7-Day Forecast Card
            Rectangle {
                id: dailyCard
                visible: weatherRoot.hasWeather && daily.length > 0
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
                implicitHeight: dailyCol.implicitHeight + Kirigami.Units.mediumSpacing * 2
                radius: Kirigami.Units.cornerRadius * 1.5
                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.06)

                readonly property real weekMin: {
                    if (!daily || daily.length === 0) return 0;
                    var m = daily[0].tempMin;
                    for (var i = 1; i < daily.length; i++) {
                        if (daily[i].tempMin < m) m = daily[i].tempMin;
                    }
                    return m;
                }
                readonly property real weekMax: {
                    if (!daily || daily.length === 0) return 1;
                    var m = daily[0].tempMax;
                    for (var i = 1; i < daily.length; i++) {
                        if (daily[i].tempMax > m) m = daily[i].tempMax;
                    }
                    return Math.max(m, weekMin + 1);
                }

                ColumnLayout {
                    id: dailyCol
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.mediumSpacing
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents.Label {
                        text: weatherRoot.tr("dailyForecast")
                        font.weight: Font.DemiBold
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        opacity: 0.8
                    }

                    Repeater {
                        model: fullRoot.daily
                        delegate: RowLayout {
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing

                            PlasmaComponents.Label {
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 4.2
                                font.weight: index === 0 ? Font.Bold : Font.Normal
                                text: index === 0
                                    ? weatherRoot.tr("today")
                                    : I18n.weekdayShort(modelData.date, weatherRoot.langSetting)
                            }

                            Image {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                                Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                mipmap: true
                                sourceSize.width: Math.round(Kirigami.Units.iconSizes.smallMedium * Screen.devicePixelRatio)
                                sourceSize.height: Math.round(Kirigami.Units.iconSizes.smallMedium * Screen.devicePixelRatio)
                                source: WeatherIcons.iconUrl(modelData.weatherCode, true)
                            }

                            PlasmaComponents.Label {
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 2.2
                                font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.9
                                color: Kirigami.Theme.linkColor
                                horizontalAlignment: Text.AlignRight
                                text: (modelData.precipProbMax && modelData.precipProbMax > 0)
                                    ? (modelData.precipProbMax + "%")
                                    : ""
                            }

                            PlasmaComponents.Label {
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 2.2
                                horizontalAlignment: Text.AlignRight
                                opacity: 0.7
                                text: Units.formatTemp(modelData.tempMin, weatherRoot.tempUnit, false)
                            }

                            // Visual temp range bar
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 6

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 3
                                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.14)
                                }

                                Rectangle {
                                    readonly property real span: dailyCard.weekMax - dailyCard.weekMin
                                    readonly property real startFrac: (modelData.tempMin - dailyCard.weekMin) / span
                                    readonly property real endFrac: (modelData.tempMax - dailyCard.weekMin) / span
                                    x: parent.width * startFrac
                                    width: Math.max(6, parent.width * (endFrac - startFrac))
                                    height: parent.height
                                    radius: 3
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: "#38bdf8" }
                                        GradientStop { position: 1.0; color: "#f97316" }
                                    }
                                }
                            }

                            PlasmaComponents.Label {
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 2.2
                                horizontalAlignment: Text.AlignRight
                                font.weight: Font.DemiBold
                                text: Units.formatTemp(modelData.tempMax, weatherRoot.tempUnit, false)
                            }
                        }
                    }
                }
            }

            // Footer
            RowLayout {
                visible: weatherRoot.hasWeather
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.mediumSpacing
                Layout.rightMargin: Kirigami.Units.mediumSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing

                PlasmaComponents.Label {
                    font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.9
                    opacity: 0.6
                    text: weatherRoot.lastUpdated
                        ? weatherRoot.tr("updatedAt", { time: Units.formatDateClock(weatherRoot.lastUpdated, weatherRoot.timeFormat) })
                        : ""
                }

                Item { Layout.fillWidth: true }

                PlasmaComponents.Label {
                    font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.9
                    opacity: 0.5
                    text: "Open-Meteo"
                }
            }
        }
    }
}
