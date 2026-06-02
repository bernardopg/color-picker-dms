# Color Picker DMS

A DankMaterialShell/DankBar widget for picking colors from the screen, copying common color formats, building palettes, converting colors, and checking WCAG contrast.

![Color Picker DMS screenshot](./screenshot.png)

## Features

- DankBar pill quick-pick.
- Right-click DankBar pill menu:
  - pick color with the eyedropper
  - copy last color
  - copy HEX
  - copy RGB
  - copy all formats
  - add current color to palette
  - copy palette
  - open the workbench
- Control-center widget and detail view.
- Popout workbench with:
  - screen color picking
  - copy HEX, RGB, HSL, HSV, and CMYK
  - persistent palette
  - manual color converter
  - WCAG AA/AAA contrast checker
- Settings for default format, backend, auto-copy, lowercase hex, and language.

## Requirements

Required:

- DankMaterialShell >= 0.1.18
- `wl-copy` from `wl-clipboard` for clipboard copy

Capture backend: install at least one of:

- `hyprpicker`
- `grim` + `slurp` (`magick`/ImageMagick improves fallback reliability)
- DMS native `dms color pick`

## Install

Clone into the DMS plugins directory:

```bash
git clone https://github.com/bernardopg/color-picker-dms.git ~/.config/DankMaterialShell/plugins/colorPicker
chmod +x ~/.config/DankMaterialShell/plugins/colorPicker/capture/pick-color
dms restart
```

Then enable the plugin in DMS settings or add it to your DankBar layout.

## Usage

- Left-click the DankBar icon to pick a screen color and auto-copy the configured format.
- Right-click the DankBar icon to open the quick actions menu.
- Open the plugin popout/workbench to copy any format, add the current color to the palette, convert typed colors, or inspect contrast.
- Configure the default copy format and backend from plugin settings.

## Files

- `plugin.json` — DMS manifest.
- `ColorPicker.qml` — root `PluginComponent`.
- `ColorWorkbench.qml` — reusable workbench UI for popout/control center.
- `ColorPickerSettings.qml` — plugin settings UI.
- `ColorUtils.js` — color parsing/conversion/WCAG math.
- `capture/pick-color` — backend wrapper that emits JSON.
- `i18n/en.json` — source strings.

## Repository

GitHub repository name: `color-picker-dms`

DMS plugin id and install directory: `colorPicker`

## License

MIT
