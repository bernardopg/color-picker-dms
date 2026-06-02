<div align="center">

![Color Picker DMS](./assets/Banner01.png)

[![CI](https://img.shields.io/github/actions/workflow/status/bernardopg/color-picker-dms/ci.yml?branch=main&label=CI&style=flat-square)](https://github.com/bernardopg/color-picker-dms/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/tag/bernardopg/color-picker-dms?label=Release&style=flat-square)](https://github.com/bernardopg/color-picker-dms/releases)
[![License](https://img.shields.io/github/license/bernardopg/color-picker-dms?style=flat-square)](LICENSE)
[![Crowdin](https://badges.crowdin.net/color-picker-dms/localized.svg)](https://crowdin.com/project/color-picker-dms)

</div>

## ✨ What It Does

Color Picker DMS is a DankMaterialShell plugin that lets you pick colors from the screen and copy them in various formats. Left-click the DankBar pill to open a full-featured popout workbench (manual picking, conversion, palette management, contrast checking); right-click for a quick-actions menu including the screen eyedropper.

## Features

- DankBar pill: left-click opens the workbench popout, right-click opens the quick-actions menu.
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

### Option 1

Download directly from the [DankMaterialShell Plugins](https://danklinux.com/plugins) page <https://danklinux.com/plugins>

### Option 2

Download the latest release and extract the `colorPickerDms` folder into your DMS plugins directory:

```bash
mkdir -p ~/.config/DankMaterialShell/plugins/colorPickerDms
unzip color-picker-dms.zip -d ~/.config/DankMaterialShell/plugins/colorPickerDms
chmod +x ~/.config/DankMaterialShell/plugins/colorPickerDms/capture/pick-color
dms restart
```

### Option 3

Clone into the DMS plugins directory:

```bash
git clone https://github.com/bernardopg/color-picker-dms.git ~/.config/DankMaterialShell/plugins/colorPickerDms
chmod +x ~/.config/DankMaterialShell/plugins/colorPickerDms/capture/pick-color
dms restart
```

Then enable the plugin in DMS settings or add it to your DankBar layout.

## Usage

- Left-click the DankBar icon to open the workbench popout (pick, convert, palette, contrast).
- Right-click the DankBar icon to open the quick actions menu (eyedropper + copy/palette actions).
- Use the workbench "Pick Color" button or the right-click "Pick Color" entry to sample a screen color; with auto-copy on, the configured format is copied immediately.
- Configure the default copy format, backend, auto-copy, lowercase hex, and language from plugin settings.

<div align="center">

## 💜 Support

If Color Picker DMS helps your DMS setup, you can support ongoing maintenance through GitHub Sponsors:

[![Sponsor](https://img.shields.io/badge/Sponsor-bernardopg-EA4AAA?style=for-the-badge&logo=githubsponsors&logoColor=white)](https://github.com/sponsors/bernardopg)

## 📄 License

Released under the terms in [LICENSE](./LICENSE).

![footer](https://capsule-render.vercel.app/api?type=waving&height=150&fontAlignY=40&section=footer)

</div>
