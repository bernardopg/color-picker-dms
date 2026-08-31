# Changelog

## Unreleased

- Palette chips: hex code left-aligned inside the cell, copy/remove buttons
  anchored to the right edge.
- Popout content now sits on a symmetric horizontal inset that matches the
  header padding, and format-row values are optically centered (equal side
  columns) inside their cards.
- i18n: audit all bundles against `en.json` (61/61 keys present, no empty
  values, `{value}` placeholders consistent) and harden the locale fallback —
  unsupported locales like `zh_TW` or `pt_PT` now fall back to the language
  default bundle (`zh_CN`, `pt_BR`) before English.
- Maintenance: bump crowdin/github-action to v3.0.1, pin
  softprops/action-gh-release to v3.0.3, and point the Crowdin download workflow
  at `.github/crowdin.yml`.

## 1.1.0 - 2026-06-02

- Rename plugin id and directory to `colorPickerDms` to avoid colliding with the
  built-in DMS `colorPicker` bar widget (the collision made the bar render the
  native widget instead of this plugin, breaking the right-click menu).
- Fix right-click quick-actions menu: replace the non-rendering QtQuick Controls
  `Popup` (no `Overlay` exists under Quickshell layer-shell) with a `PluginPopout`.
- Fix plugin failing to load: bind the i18n `Connections` to a named property
  (`QtObject` has no default property).
- Left-click on the bar pill now opens the workbench popout; screen capture moved
  to the right-click menu and the in-workbench "Pick Color" button.
- Hide all plugin surfaces and wait for the close animation before capturing, so
  the picker can sample anything on screen without UI overlap.
- Fix invalid `Theme.fontSizeXSmall` reference in the quick-actions menu.
- Add Crowdin CLI configuration and GitHub Actions sync workflows.
- Load Crowdin-downloaded locale bundles automatically from `i18n/<locale>.json`.
- Add Arabic, Brazilian Portuguese, Chinese Simplified, French, German, Italian, Japanese, Russian, and Spanish translations.
- Validate all shipped i18n JSON bundles in CI.

## 1.0.0

Initial release.

- Add DankBar color picker pill.
- Add right-click quick actions menu.
- Add control-center widget and popout workbench.
- Add HEX/RGB/HSL/HSV/CMYK conversion and copy actions.
- Add persistent palette management.
- Add WCAG contrast checker.
- Add configurable capture backend, default copy format, auto-copy, lowercase HEX, and language settings.
