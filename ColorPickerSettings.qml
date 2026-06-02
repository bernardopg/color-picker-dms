import QtQuick
import qs.Modules.Plugins
import "." as Local

PluginSettings {
    id: settings

    pluginId: "colorPicker"

    function tr(key, fallback, params) {
        return Local.ColorPickerI18n.tr(key, fallback, params)
    }

    SelectionSetting {
        settingKey: "defaultFormat"
        label: settings.tr("settings.defaultFormat", "Default copy format")
        description: settings.tr("settings.defaultFormatDesc", "Format copied to the clipboard when you pick from the bar")
        defaultValue: "HEX"
        options: [
            { value: "HEX", label: settings.tr("format.HEX", "Hex") },
            { value: "RGB", label: settings.tr("format.RGB", "RGB") },
            { value: "HSL", label: settings.tr("format.HSL", "HSL") },
            { value: "HSV", label: settings.tr("format.HSV", "HSV") },
            { value: "CMYK", label: settings.tr("format.CMYK", "CMYK") }
        ]
    }

    SelectionSetting {
        settingKey: "backend"
        label: settings.tr("settings.backend", "Capture backend")
        description: settings.tr("settings.backendDesc", "Screen color sampler. Auto picks the first available.")
        defaultValue: "auto"
        options: [
            { value: "auto", label: settings.tr("backend.auto", "Auto") },
            { value: "hyprpicker", label: settings.tr("backend.hyprpicker", "hyprpicker") },
            { value: "grim", label: settings.tr("backend.grim", "grim + slurp") },
            { value: "dms", label: settings.tr("backend.dms", "dms color pick") }
        ]
    }

    ToggleSetting {
        settingKey: "autoCopy"
        label: settings.tr("settings.autoCopy", "Auto-copy on pick")
        description: settings.tr("settings.autoCopyDesc", "Copy the color to the clipboard immediately after sampling")
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "lowercaseHex"
        label: settings.tr("settings.lowercaseHex", "Lowercase hex")
        description: settings.tr("settings.lowercaseHexDesc", "Emit #aabbcc instead of #AABBCC")
        defaultValue: false
    }

    SelectionSetting {
        settingKey: "languageOverride"
        label: settings.tr("settings.language", "Language")
        description: settings.tr("settings.languageDesc", "Interface language (Auto follows the system locale)")
        defaultValue: "auto"
        options: [
            { value: "auto", label: "Auto" },
            { value: "en_US", label: "English" },
            { value: "ar_SA", label: "العربية" },
            { value: "de_DE", label: "Deutsch" },
            { value: "es_ES", label: "Español" },
            { value: "fr_FR", label: "Français" },
            { value: "it_IT", label: "Italiano" },
            { value: "ja_JP", label: "日本語" },
            { value: "pt_BR", label: "Português (Brasil)" },
            { value: "ru_RU", label: "Русский" },
            { value: "zh_CN", label: "简体中文" }
        ]
    }
}
