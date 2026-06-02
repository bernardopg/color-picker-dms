# Localization

Translations are managed in Crowdin:

- Project: <https://crowdin.com/project/color-picker-dms>
- Project ID: `902673`
- Source file: `i18n/en.json`
- Downloaded translations: `i18n/%locale_with_underscore%.json`

The plugin loads Crowdin-downloaded bundles automatically based on the current Qt locale. English remains the fallback for missing files or missing keys.

Bundled translations:

- Arabic (`ar_SA`)
- Brazilian Portuguese (`pt_BR`)
- Chinese Simplified (`zh_CN`)
- French (`fr_FR`)
- German (`de_DE`)
- Italian (`it_IT`)
- Japanese (`ja_JP`)
- Russian (`ru_RU`)
- Spanish (`es_ES`)

GitHub Actions includes two Crowdin workflows:

- `Crowdin Upload` uploads source strings when `i18n/en.json` or `crowdin.yml` changes.
- `Crowdin Download` runs manually and opens a PR with translated JSON bundles.

Configure at least one target language in Crowdin before running the download workflow. Until translated strings exist, the Crowdin CLI has no files to export.

Repository secret required for both workflows:

- `CROWDIN_PERSONAL_TOKEN`

Local maintainer commands:

```bash
crowdin config lint --identity ~/.crowdin.yml
crowdin upload sources --identity ~/.crowdin.yml
crowdin download --identity ~/.crowdin.yml --skip-untranslated-strings
```
