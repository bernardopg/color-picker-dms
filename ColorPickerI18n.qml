pragma Singleton

import QtQuick
import qs.Services

// Runtime i18n singleton for the Color Picker plugin.
//
// Translations live as flat JSON bundles in i18n/<locale>.json. English
// (i18n/en.json) is always present as the universal fallback: any key
// missing from a translated bundle falls back to English, then to the inline
// default passed to tr(). Add new i18n/<locale>.json files and extend
// localeBundles below when a new target language is published.
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

    // Maps a normalized locale (pt_BR, zh_CN, ...) to its bundle filename.
    // English is implicit (en.json) and always present as the fallback.
    readonly property var localeBundles: ({
        // "pt_BR": "i18n/pt_BR.json",
        // "zh_CN": "i18n/zh_CN.json",
    })

    readonly property string normalizedLocale: normalizeLocale(languageOverride === "auto" ? localeName : languageOverride)
    readonly property var fallbackTranslations: loadBundle("en_US")
    readonly property var activeTranslations: loadBundle(normalizedLocale)
    property var bundleCache: ({})

    // Collapse a raw locale string to a bundle key we actually ship. Unknown
    // locales degrade to en_US so the plugin is never left without strings.
    function normalizeLocale(value) {
        const raw = (value || "en_US").toString().replace("-", "_").trim();
        if (!raw)
            return "en_US";
        // Exact match on a shipped bundle (e.g. "pt_BR").
        if (root.localeBundles[raw] !== undefined)
            return raw;
        // Language-only prefix match (e.g. "pt" -> first pt_* bundle).
        const lang = raw.split("_")[0].toLowerCase();
        for (const key in root.localeBundles) {
            if (key.toLowerCase().indexOf(lang) === 0)
                return key;
        }
        return "en_US";
    }

    function bundleFile(locale) {
        if (locale === "en_US")
            return "i18n/en.json";
        return root.localeBundles[locale] || "i18n/en.json";
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

    function loadSettings() {
        const stored = PluginService.loadPluginData(root.pluginId, "languageOverride");
        root.languageOverride = (stored === undefined || stored === null || stored === "") ? "auto" : stored.toString();
    }

    property var pluginDataConnection: Connections {
        target: PluginService
        function onPluginDataChanged(changedPluginId) {
            if (changedPluginId === root.pluginId)
                root.loadSettings();
        }
    }

    Component.onCompleted: loadSettings()
}
