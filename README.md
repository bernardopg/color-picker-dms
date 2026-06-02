<div align="center">

![header](https://capsule-render.vercel.app/api?type=waving&height=300&color=gradient&text=Color%20Picker%20DMS&fontSize=50&animation=fadeIn&fontAlign=49&fontAlignY=32&desc=A%20DankMaterialShell/DankBar%20widget%20for%20picking%20colors%20from%20the%20screen&descAlignY=48)

[![CI](https://img.shields.io/github/actions/workflow/status/bernardopg/color-picker-dms/ci.yml?branch=main&label=CI&style=flat-square)](https://github.com/bernardopg/color-picker-dms/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/tag/bernardopg/color-picker-dms?label=Release&style=flat-square)](https://github.com/bernardopg/color-picker-dms/releases)
[![License](https://img.shields.io/github/license/bernardopg/color-picker-dms?style=flat-square)](LICENSE)
[![Crowdin](https://badges.crowdin.net/color-picker-dms/localized.svg)](https://crowdin.com/project/color-picker-dms)

</div>

![Color Picker DMS screenshot](./screenshot.png)

## ✨ What It Does

Color Picker DMS is a DankMaterialShell plugin that lets you pick colors from the screen and copy them in various formats. It provides a quick-pick pill for instant color capture, a right-click menu for common actions, and a full-featured popout workbench for manual picking, conversion, palette management, and contrast checking.

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

## 💜 Support

If Color Picker DMS helps your DMS setup, you can support ongoing maintenance through GitHub Sponsors:

[![Sponsor](https://img.shields.io/badge/Sponsor-bernardopg-EA4AAA?style=for-the-badge&logo=githubsponsors&logoColor=white)](https://github.com/sponsors/bernardopg)

## 📄 License

Released under the terms in [LICENSE](./LICENSE).

![footer](https://capsule-render.vercel.app/api?type=waving&height=150&fontAlignY=40&section=footer)
