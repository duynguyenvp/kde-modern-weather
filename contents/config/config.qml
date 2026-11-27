import QtQuick
import org.kde.plasma.configuration
import "../code/i18n.js" as I18n

ConfigModel {
    ConfigCategory {
        name: I18n.t("tabLocations", typeof plasmoid !== "undefined" && plasmoid.configuration ? plasmoid.configuration.language : "auto")
        icon: "mark-location"
        source: "configLocations.qml"
    }
    ConfigCategory {
        name: I18n.t("tabUnits", typeof plasmoid !== "undefined" && plasmoid.configuration ? plasmoid.configuration.language : "auto")
        icon: "measure"
        source: "configUnits.qml"
    }
    ConfigCategory {
        name: I18n.t("tabGeneral", typeof plasmoid !== "undefined" && plasmoid.configuration ? plasmoid.configuration.language : "auto")
        icon: "configure"
        source: "configGeneral.qml"
    }
}
