import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

import "../code/i18n.js" as I18n

KCM.SimpleKCM {
    id: generalPage

    property string cfg_language: "auto"
    property int cfg_refreshIntervalMinutes: 15
    property alias cfg_showTemperatureInPanel: showTempCheck.checked
    property alias cfg_showTemperatureUnitInPanel: showTempUnitCheck.checked
    property string cfg_panelFontFamily: ""
    property int cfg_panelFontSize: 0
    property string cfg_panelFontWeight: "demibold"
    property alias cfg_panelFontItalic: fontItalicCheck.checked
    property alias cfg_showConditionInTooltip: showTooltipCheck.checked

    function tr(key, params) {
        return I18n.t(key, generalPage.cfg_language, params);
    }

    function indexForValue(modelList, val) {
        for (var i = 0; i < modelList.length; i++) {
            if (modelList[i].value === val) return i;
        }
        return 0;
    }

    function qtWeightFromString(w) {
        switch (w) {
        case "normal": return Font.Normal;
        case "medium": return Font.Medium;
        case "bold": return Font.Bold;
        case "demibold":
        default: return Font.DemiBold;
        }
    }

    readonly property var langOptions: [
        { value: "auto", text: tr("langAuto") },
        { value: "en", text: tr("langEn") },
        { value: "vi", text: tr("langVi") }
    ]

    readonly property var refreshOptions: [
        { value: 5, text: tr("everyMinutes", { n: 5 }) },
        { value: 10, text: tr("everyMinutes", { n: 10 }) },
        { value: 15, text: tr("everyMinutes", { n: 15 }) },
        { value: 30, text: tr("everyMinutes", { n: 30 }) },
        { value: 60, text: tr("everyHour") }
    ]

    readonly property var weightOptions: [
        { value: "normal", text: tr("weightNormal") },
        { value: "medium", text: tr("weightMedium") },
        { value: "demibold", text: tr("weightDemiBold") },
        { value: "bold", text: tr("weightBold") }
    ]

    readonly property var fontFamilyOptions: {
        var list = [{ value: "", text: tr("fontDefault") }];
        var families = Qt.fontFamilies();
        for (var i = 0; i < families.length; i++) {
            list.push({ value: families[i], text: families[i] });
        }
        return list;
    }

    Kirigami.FormLayout {
        QQC2.ComboBox {
            Kirigami.FormData.label: generalPage.tr("languageLabel") + ":"
            model: generalPage.langOptions
            textRole: "text"
            currentIndex: generalPage.indexForValue(generalPage.langOptions, generalPage.cfg_language)
            onActivated: generalPage.cfg_language = generalPage.langOptions[currentIndex].value
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: generalPage.tr("refreshInterval") + ":"
            model: generalPage.refreshOptions
            textRole: "text"
            currentIndex: generalPage.indexForValue(generalPage.refreshOptions, generalPage.cfg_refreshIntervalMinutes)
            onActivated: generalPage.cfg_refreshIntervalMinutes = generalPage.refreshOptions[currentIndex].value
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: generalPage.tr("panelAppearance")
        }

        QQC2.CheckBox {
            id: showTempCheck
            text: generalPage.tr("showTempInPanel")
        }

        QQC2.CheckBox {
            id: showTempUnitCheck
            enabled: showTempCheck.checked
            text: generalPage.tr("showTempUnitInPanel")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: generalPage.tr("panelFontFamily") + ":"
            enabled: showTempCheck.checked
            Layout.fillWidth: true
            model: generalPage.fontFamilyOptions
            textRole: "text"
            currentIndex: generalPage.indexForValue(generalPage.fontFamilyOptions, generalPage.cfg_panelFontFamily)
            onActivated: generalPage.cfg_panelFontFamily = generalPage.fontFamilyOptions[currentIndex].value
        }

        RowLayout {
            Kirigami.FormData.label: generalPage.tr("panelFontSize") + ":"
            enabled: showTempCheck.checked
            spacing: Kirigami.Units.smallSpacing

            QQC2.CheckBox {
                id: autoFontSizeCheck
                text: generalPage.tr("fontSizeAuto")
                checked: generalPage.cfg_panelFontSize <= 0
                onToggled: {
                    if (checked) {
                        generalPage.cfg_panelFontSize = 0;
                    } else {
                        generalPage.cfg_panelFontSize = fontSizeSpin.value;
                    }
                }
            }

            QQC2.SpinBox {
                id: fontSizeSpin
                enabled: !autoFontSizeCheck.checked
                from: 8
                to: 36
                value: generalPage.cfg_panelFontSize > 0 ? generalPage.cfg_panelFontSize : 14
                textFromValue: function(value) { return value + " px"; }
                valueFromText: function(text) { return parseInt(text, 10) || 14; }
                onValueModified: {
                    if (!autoFontSizeCheck.checked) {
                        generalPage.cfg_panelFontSize = value;
                    }
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: generalPage.tr("panelFontStyle") + ":"
            enabled: showTempCheck.checked
            spacing: Kirigami.Units.smallSpacing

            QQC2.ComboBox {
                model: generalPage.weightOptions
                textRole: "text"
                currentIndex: generalPage.indexForValue(generalPage.weightOptions, generalPage.cfg_panelFontWeight)
                onActivated: generalPage.cfg_panelFontWeight = generalPage.weightOptions[currentIndex].value
            }

            QQC2.CheckBox {
                id: fontItalicCheck
                text: generalPage.tr("fontItalic")
            }
        }

        // Live preview of taskbar temperature style
        Rectangle {
            Kirigami.FormData.label: generalPage.tr("fontPreview") + ":"
            visible: showTempCheck.checked
            implicitWidth: previewRow.implicitWidth + Kirigami.Units.largeSpacing * 2
            implicitHeight: Math.max(Kirigami.Units.gridUnit * 2, previewRow.implicitHeight + Kirigami.Units.smallSpacing * 2)
            radius: Kirigami.Units.cornerRadius
            color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)

            RowLayout {
                id: previewRow
                anchors.centerIn: parent
                spacing: Kirigami.Units.smallSpacing

                Image {
                    source: Qt.resolvedUrl("../icons/meteocons/partly-cloudy-day.svg")
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                    sourceSize.width: Math.round(Kirigami.Units.iconSizes.medium * Screen.devicePixelRatio)
                    sourceSize.height: Math.round(Kirigami.Units.iconSizes.medium * Screen.devicePixelRatio)
                }

                QQC2.Label {
                    readonly property string unitSuffix: (Plasmoid.configuration.temperatureUnit === "fahrenheit") ? "°F" : "°C"
                    text: showTempUnitCheck.checked ? ("18" + unitSuffix) : "18°"
                    font.family: generalPage.cfg_panelFontFamily.length > 0
                        ? generalPage.cfg_panelFontFamily
                        : Kirigami.Theme.defaultFont.family
                    font.pixelSize: generalPage.cfg_panelFontSize > 0
                        ? generalPage.cfg_panelFontSize
                        : Kirigami.Theme.defaultFont.pixelSize
                    font.weight: generalPage.qtWeightFromString(generalPage.cfg_panelFontWeight)
                    font.italic: generalPage.cfg_panelFontItalic
                }
            }
        }

        QQC2.CheckBox {
            id: showTooltipCheck
            text: generalPage.tr("showCondInTooltip")
        }

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.7
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            text: generalPage.tr("dynamicIconNote")
        }
    }
}
