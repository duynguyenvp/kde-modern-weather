import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

import "../code/i18n.js" as I18n

KCM.SimpleKCM {
    id: unitsPage

    property string cfg_temperatureUnit: "celsius"
    property string cfg_windSpeedUnit: "kmh"
    property string cfg_pressureUnit: "hpa"
    property string cfg_precipitationUnit: "mm"
    property string cfg_timeFormat: "auto"

    readonly property string langSetting: Plasmoid.configuration.language || "auto"

    function tr(key) {
        return I18n.t(key, unitsPage.langSetting);
    }

    function indexForValue(modelList, val) {
        for (var i = 0; i < modelList.length; i++) {
            if (modelList[i].value === val) return i;
        }
        return 0;
    }

    readonly property var tempOptions: [
        { value: "celsius", text: tr("celsius") },
        { value: "fahrenheit", text: tr("fahrenheit") }
    ]

    readonly property var windOptions: [
        { value: "kmh", text: tr("kmh") },
        { value: "ms", text: tr("ms") },
        { value: "mph", text: tr("mph") },
        { value: "kn", text: tr("kn") }
    ]

    readonly property var pressureOptions: [
        { value: "hpa", text: tr("hpa") },
        { value: "inhg", text: tr("inhg") },
        { value: "mmhg", text: tr("mmhg") }
    ]

    readonly property var precipOptions: [
        { value: "mm", text: tr("mm") },
        { value: "inch", text: tr("inch") }
    ]

    readonly property var timeOptions: [
        { value: "auto", text: tr("timeAuto") },
        { value: "24h", text: tr("time24h") },
        { value: "12h", text: tr("time12h") }
    ]

    Kirigami.FormLayout {
        QQC2.ComboBox {
            Kirigami.FormData.label: unitsPage.tr("temperatureUnit") + ":"
            model: unitsPage.tempOptions
            textRole: "text"
            currentIndex: unitsPage.indexForValue(unitsPage.tempOptions, unitsPage.cfg_temperatureUnit)
            onActivated: unitsPage.cfg_temperatureUnit = unitsPage.tempOptions[currentIndex].value
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: unitsPage.tr("windSpeedUnit") + ":"
            model: unitsPage.windOptions
            textRole: "text"
            currentIndex: unitsPage.indexForValue(unitsPage.windOptions, unitsPage.cfg_windSpeedUnit)
            onActivated: unitsPage.cfg_windSpeedUnit = unitsPage.windOptions[currentIndex].value
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: unitsPage.tr("pressureUnit") + ":"
            model: unitsPage.pressureOptions
            textRole: "text"
            currentIndex: unitsPage.indexForValue(unitsPage.pressureOptions, unitsPage.cfg_pressureUnit)
            onActivated: unitsPage.cfg_pressureUnit = unitsPage.pressureOptions[currentIndex].value
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: unitsPage.tr("precipitationUnit") + ":"
            model: unitsPage.precipOptions
            textRole: "text"
            currentIndex: unitsPage.indexForValue(unitsPage.precipOptions, unitsPage.cfg_precipitationUnit)
            onActivated: unitsPage.cfg_precipitationUnit = unitsPage.precipOptions[currentIndex].value
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: unitsPage.tr("timeFormat") + ":"
            model: unitsPage.timeOptions
            textRole: "text"
            currentIndex: unitsPage.indexForValue(unitsPage.timeOptions, unitsPage.cfg_timeFormat)
            onActivated: unitsPage.cfg_timeFormat = unitsPage.timeOptions[currentIndex].value
        }
    }
}
