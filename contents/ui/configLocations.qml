import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

import "../code/i18n.js" as I18n
import "../code/weatherApi.js" as WeatherApi

KCM.SimpleKCM {
    id: locationsPage

    property alias cfg_useSystemLocation: useSystemCheck.checked
    property string cfg_locationsJson: "[]"
    property int cfg_activeLocationIndex: 0

    readonly property string langSetting: Plasmoid.configuration.language || "auto"
    readonly property string resolvedLang: I18n.resolveLang(langSetting)

    property var savedLocations: []
    property var searchResults: []
    property bool isSearching: false
    property string searchStatus: ""
    property string manualError: ""

    function tr(key, params) {
        return I18n.t(key, locationsPage.langSetting, params);
    }

    function loadLocationsFromCfg() {
        try {
            var parsed = JSON.parse(cfg_locationsJson || "[]");
            savedLocations = Array.isArray(parsed) ? parsed : [];
        } catch (e) {
            savedLocations = [];
        }
    }

    function saveLocationsToCfg(list, newActiveIndex, disableSystemLoc) {
        savedLocations = list;
        cfg_locationsJson = JSON.stringify(list);
        if (newActiveIndex !== undefined && newActiveIndex !== null) {
            cfg_activeLocationIndex = newActiveIndex;
        }
        if (disableSystemLoc) {
            useSystemCheck.checked = false;
        }
    }

    function addLocation(loc) {
        var list = savedLocations.slice();
        list.push({
            name: loc.name,
            admin1: loc.admin1 || "",
            country: loc.country || "",
            latitude: Number(loc.latitude),
            longitude: Number(loc.longitude)
        });
        // Automatically select the newly added location if it's the first one or user is in manual mode
        var shouldSelect = !useSystemCheck.checked || list.length === 1;
        saveLocationsToCfg(list, shouldSelect ? list.length - 1 : cfg_activeLocationIndex, false);
    }

    function removeLocation(index) {
        var list = savedLocations.slice();
        list.splice(index, 1);
        var nextIdx = cfg_activeLocationIndex;
        if (nextIdx >= list.length) {
            nextIdx = Math.max(0, list.length - 1);
        }
        saveLocationsToCfg(list, nextIdx, false);
    }

    function activateLocation(index) {
        cfg_activeLocationIndex = index;
        useSystemCheck.checked = false;
    }

    function runSearch() {
        var q = searchField.text.trim();
        if (q.length < 2) {
            searchResults = [];
            searchStatus = "";
            return;
        }
        isSearching = true;
        searchStatus = tr("searching");
        searchResults = [];

        WeatherApi.searchLocations(q, resolvedLang, function(err, results) {
            isSearching = false;
            if (err) {
                searchStatus = tr("errNetwork");
                searchResults = [];
                return;
            }
            searchResults = results || [];
            searchStatus = searchResults.length === 0 ? tr("noResults") : "";
        });
    }

    onCfg_locationsJsonChanged: loadLocationsFromCfg()
    Component.onCompleted: loadLocationsFromCfg()

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        // OS Location Section
        Kirigami.FormLayout {
            Layout.fillWidth: true

            QQC2.CheckBox {
                id: useSystemCheck
                Kirigami.FormData.label: locationsPage.tr("locationSource") + ":"
                text: locationsPage.tr("useOsLocation")
            }

            QQC2.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                opacity: 0.7
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                text: locationsPage.tr("useOsLocationDesc")
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        // City Search Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            QQC2.Label {
                text: locationsPage.tr("searchCity")
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                QQC2.TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: locationsPage.tr("searchPlaceholder")
                    onAccepted: locationsPage.runSearch()
                }

                QQC2.Button {
                    text: locationsPage.tr("searchButton")
                    icon.name: "search"
                    enabled: !locationsPage.isSearching && searchField.text.trim().length >= 2
                    onClicked: locationsPage.runSearch()
                }
            }

            QQC2.Label {
                visible: locationsPage.searchStatus.length > 0
                text: locationsPage.searchStatus
                opacity: 0.75
                font.pointSize: Kirigami.Theme.smallFont.pointSize
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: locationsPage.searchResults.length > 0

                Repeater {
                    model: locationsPage.searchResults
                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: resRow.implicitHeight + Kirigami.Units.smallSpacing * 2
                        radius: Kirigami.Units.cornerRadius
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.05)

                        RowLayout {
                            id: resRow
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.smallSpacing
                            spacing: Kirigami.Units.smallSpacing

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                QQC2.Label {
                                    text: modelData.name
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                QQC2.Label {
                                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                                    opacity: 0.75
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    text: {
                                        var parts = [];
                                        if (modelData.admin1) parts.push(modelData.admin1);
                                        if (modelData.country) parts.push(modelData.country);
                                        parts.push(modelData.latitude.toFixed(2) + ", " + modelData.longitude.toFixed(2));
                                        return parts.join(" • ");
                                    }
                                }
                            }

                            QQC2.Button {
                                text: locationsPage.tr("addLocation")
                                icon.name: "list-add"
                                onClicked: {
                                    locationsPage.addLocation(modelData);
                                    locationsPage.searchResults = [];
                                    searchField.text = "";
                                }
                            }
                        }
                    }
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        // Saved Manual Locations Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            QQC2.Label {
                text: locationsPage.tr("savedLocations")
                font.bold: true
            }

            QQC2.Label {
                visible: locationsPage.savedLocations.length === 0
                text: locationsPage.tr("noSavedLocations")
                opacity: 0.7
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Repeater {
                model: locationsPage.savedLocations
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    readonly property bool isActive: !useSystemCheck.checked && (locationsPage.cfg_activeLocationIndex === index)

                    Layout.fillWidth: true
                    implicitHeight: savedRow.implicitHeight + Kirigami.Units.smallSpacing * 2
                    radius: Kirigami.Units.cornerRadius
                    color: isActive
                        ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.15)
                        : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.05)

                    RowLayout {
                        id: savedRow
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing
                        spacing: Kirigami.Units.smallSpacing

                        Kirigami.Icon {
                            source: isActive ? "checkmark" : "globe"
                            Layout.preferredWidth: Kirigami.Units.iconSizes.small
                            Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            QQC2.Label {
                                text: modelData.name
                                font.bold: isActive
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            QQC2.Label {
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                                opacity: 0.7
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                text: {
                                    var parts = [];
                                    if (modelData.admin1) parts.push(modelData.admin1);
                                    if (modelData.country) parts.push(modelData.country);
                                    parts.push(Number(modelData.latitude).toFixed(2) + ", " + Number(modelData.longitude).toFixed(2));
                                    return parts.join(" • ");
                                }
                            }
                        }

                        QQC2.Button {
                            text: isActive ? locationsPage.tr("activeBadge") : locationsPage.tr("setActive")
                            enabled: !isActive
                            onClicked: locationsPage.activateLocation(index)
                        }

                        QQC2.ToolButton {
                            icon.name: "edit-delete"
                            onClicked: locationsPage.removeLocation(index)
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: locationsPage.tr("remove")
                        }
                    }
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        // Manual Coordinates Entry
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            QQC2.Label {
                text: locationsPage.tr("manualCoordinates")
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                QQC2.TextField {
                    id: manualNameField
                    Layout.fillWidth: true
                    placeholderText: locationsPage.tr("locationName")
                }

                QQC2.TextField {
                    id: manualLatField
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 5.5
                    placeholderText: locationsPage.tr("latitude")
                }

                QQC2.TextField {
                    id: manualLonField
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 5.5
                    placeholderText: locationsPage.tr("longitude")
                }

                QQC2.Button {
                    text: locationsPage.tr("addLocation")
                    icon.name: "list-add"
                    onClicked: {
                        var name = manualNameField.text.trim();
                        var lat = parseFloat(manualLatField.text.trim());
                        var lon = parseFloat(manualLonField.text.trim());
                        if (!name || isNaN(lat) || isNaN(lon) || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
                            locationsPage.manualError = locationsPage.tr("invalidCoordinates");
                            return;
                        }
                        locationsPage.manualError = "";
                        locationsPage.addLocation({
                            name: name,
                            admin1: "",
                            country: "",
                            latitude: lat,
                            longitude: lon
                        });
                        manualNameField.text = "";
                        manualLatField.text = "";
                        manualLonField.text = "";
                    }
                }
            }

            QQC2.Label {
                visible: locationsPage.manualError.length > 0
                text: locationsPage.manualError
                color: Kirigami.Theme.negativeTextColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}
