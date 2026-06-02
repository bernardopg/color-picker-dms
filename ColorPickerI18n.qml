pragma Singleton

import QtQuick
import qs.Services

// Runtime i18n singleton for the Color Picker plugin.
//
// Translations live as flat JSON bundles in i18n/<locale>.json. English
// (i18n/en.json) is always present as the universal fallback: any key
// missing from a translated bundle falls back to English, then to the inline
// default passed to tr(). Crowdin exports locale files with underscores
// (for example i18n/pt_BR.json), matching the normalized Qt locale.
QtObject {
    id: root

    readonly property string pluginId: "colorPicker"

    // "auto" follows the system locale; any other value forces that locale.
    property string languageOverride: "auto"

    property string localeName: {
        try {
            return (Qt.locale().name || "en_US").toString();
        } catch (error) {
            return "en_US";
        }
    }

    readonly property string normalizedLocale: normalizeLocale(languageOverride === "auto" ? localeName : languageOverride)
    readonly property var fallbackTranslations: loadBundle("en_US")
    readonly property var activeTranslations: loadBundle(normalizedLocale)
    property var bundleCache: ({})
    readonly property var languageDefaultLocales: ({
        "ar": "ar_SA",
        "de": "de_DE",
        "es": "es_ES",
        "fr": "fr_FR",
        "it": "it_IT",
        "ja": "ja_JP",
        "pt": "pt_BR",
        "ru": "ru_RU",
        "zh": "zh_CN"
    })

    // Normalize Qt/Crowdin locale variants to the file naming convention used
    // by the downloaded bundles. Missing files are handled by loadBundle().
    function normalizeLocale(value) {
        const raw = (value || "en_US").toString().replace("-", "_").trim();
        if (!raw)
            return "en_US";

        const parts = raw.split("_").filter(function(part) { return part.length > 0 });
        const language = parts.length > 0 ? parts[0].toLowerCase() : "en";
        if (language === "en")
            return "en_US";

        if (parts.length === 1)
            return root.languageDefaultLocales[language] || language;

        const region = parts[1].toUpperCase();
        return language + "_" + region;
    }

    function bundleFile(locale) {
        if (locale === "en_US")
            return "i18n/en.json";
        return "i18n/" + locale + ".json";
    }

    function loadBundle(locale) {
        const normalized = normalizeLocale(locale);
        if (root.bundleCache[normalized])
            return root.bundleCache[normalized];

        const xhr = new XMLHttpRequest();
        try {
            xhr.open("GET", Qt.resolvedUrl(bundleFile(normalized)), false);
            xhr.send();
            if (xhr.status === 0 || (xhr.status >= 200 && xhr.status < 300)) {
                const parsed = JSON.parse(xhr.responseText || "{}");
                root.bundleCache[normalized] = parsed;
                return parsed;
            }
        } catch (error) {
            console.warn("ColorPicker i18n load failed", normalized, error);
        }
        root.bundleCache[normalized] = (normalized === "en_US") ? ({}) : loadBundle("en_US");
        return root.bundleCache[normalized];
    }

    // tr(key, fallback, params): resolve a key against the active bundle, then
    // English, then the inline fallback. params interpolates {name} tokens.
    function tr(key, fallback, params) {
        let text = root.activeTranslations[key];
        if (text === undefined || text === null || text === "")
            text = root.fallbackTranslations[key];
        if (text === undefined || text === null || text === "")
            text = fallback || key;
        if (!params)
            return text;
        for (const param in params) {
            const value = (params[param] === undefined || params[param] === null) ? "" : params[param].toString();
            text = text.replace(new RegExp("\\{" + param + "\\}", "g"), value);
        }
        return text;
    }

    signal localeChanged()

    function loadSettings() {
        const stored = PluginService.loadPluginData(root.pluginId, "languageOverride");
        const newValue = (stored === undefined || stored === null || stored === "") ? "auto" : stored.toString();
        if (newValue !== root.languageOverride) {
            root.languageOverride = newValue;
            // force i18n consumers to re-evaluate translated strings
            root.localeChanged();
        }
    }

    Connections {
        target: PluginService
        function onPluginDataChanged(changedPluginId) {
            if (changedPluginId === root.pluginId)
                root.loadSettings();
        }
    }

    Component.onCompleted: loadSettings()
}
