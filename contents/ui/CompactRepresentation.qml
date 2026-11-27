import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot

    required property var weatherRoot

    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool showTemp: weatherRoot.showTemperatureInPanel && weatherRoot.hasWeather

    Layout.minimumWidth: isVertical ? Kirigami.Units.iconSizes.small : contentLayout.implicitWidth + Kirigami.Units.smallSpacing * 2
    Layout.minimumHeight: isVertical ? contentLayout.implicitHeight + Kirigami.Units.smallSpacing * 2 : Kirigami.Units.iconSizes.small
    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.MiddleButton) {
                weatherRoot.refreshWeather(true);
            } else {
                weatherRoot.expanded = !weatherRoot.expanded;
            }
        }
    }

    GridLayout {
        id: contentLayout
        anchors.centerIn: parent
        columns: compactRoot.isVertical ? 1 : (compactRoot.showTemp ? 2 : 1)
        rowSpacing: 1
        columnSpacing: Kirigami.Units.smallSpacing

        Image {
            id: weatherIcon
            source: weatherRoot.currentWeatherIcon
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            opacity: weatherRoot.isLoading && !weatherRoot.hasWeather ? 0.6 : (mouseArea.containsMouse ? 0.92 : 1.0)

            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: {
                if (compactRoot.isVertical) {
                    return Math.min(compactRoot.width, Kirigami.Units.iconSizes.medium);
                }
                return Math.min(compactRoot.height, Kirigami.Units.iconSizes.medium);
            }
            Layout.preferredHeight: Layout.preferredWidth

            sourceSize.width: Math.max(24, Math.round(Layout.preferredWidth * Screen.devicePixelRatio))
            sourceSize.height: Math.max(24, Math.round(Layout.preferredHeight * Screen.devicePixelRatio))

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }

        PlasmaComponents.Label {
            id: tempLabel
            visible: compactRoot.showTemp
            text: weatherRoot.currentPanelTempText
            font.family: weatherRoot.panelFontFamily.length > 0
                ? weatherRoot.panelFontFamily
                : Kirigami.Theme.defaultFont.family
            font.pixelSize: {
                if (weatherRoot.panelFontSize > 0) {
                    return weatherRoot.panelFontSize;
                }
                return compactRoot.isVertical
                    ? Math.max(9, Math.min(compactRoot.width * 0.34, Kirigami.Theme.smallFont.pixelSize))
                    : Math.max(10, Math.min(compactRoot.height * 0.48, Kirigami.Theme.defaultFont.pixelSize));
            }
            font.weight: {
                switch (weatherRoot.panelFontWeight) {
                case "normal": return Font.Normal;
                case "medium": return Font.Medium;
                case "bold": return Font.Bold;
                case "demibold":
                default: return Font.DemiBold;
                }
            }
            font.italic: weatherRoot.panelFontItalic
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignCenter
        }
    }
}
