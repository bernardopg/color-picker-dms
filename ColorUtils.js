.pragma library
//
// ColorUtils.js — pure color math for the Color Picker plugin.
//
// All functions are side-effect free and operate on plain numbers/strings so
// they can be unit-reasoned and reused by the widget, the converter, and the
// WCAG checker. RGB channels are integers 0-255; H is 0-360; S/L/V are 0-100.

// ── parsing ──────────────────────────────────────────────────────────────────

function clamp(value, min, max) {
    return value < min ? min : (value > max ? max : value);
}

function round(value) {
    return Math.round(value);
}

// Expand "#abc" / "abc" -> "AABBCC"; pass through "#aabbcc"/"aabbcc". Returns
// "" when the input is not a valid 3- or 6-digit hex color.
function normalizeHex(input) {
    if (input === undefined || input === null)
        return "";
    var raw = String(input).trim().replace(/^#/, "").toUpperCase();
    if (/^[0-9A-F]{3}$/.test(raw))
        raw = raw[0] + raw[0] + raw[1] + raw[1] + raw[2] + raw[2];
    if (/^[0-9A-F]{6}$/.test(raw))
        return raw;
    return "";
}

// Parse any supported textual color (hex, rgb(), hsl()) into {r,g,b} or null.
function parseAny(input) {
    if (input === undefined || input === null)
        return null;
    var str = String(input).trim();

    var hex = normalizeHex(str);
    if (hex)
        return hexToRgb("#" + hex);

    var rgbMatch = str.match(/rgba?\(\s*(\d+)[,\s]+(\d+)[,\s]+(\d+)/i);
    if (rgbMatch) {
        return {
            r: clamp(parseInt(rgbMatch[1]), 0, 255),
            g: clamp(parseInt(rgbMatch[2]), 0, 255),
            b: clamp(parseInt(rgbMatch[3]), 0, 255)
        };
    }

    var hslMatch = str.match(/hsla?\(\s*(\d+)[,\s]+(\d+)%?[,\s]+(\d+)%?/i);
    if (hslMatch) {
        return hslToRgb(parseInt(hslMatch[1]), parseInt(hslMatch[2]), parseInt(hslMatch[3]));
    }

    return null;
}

// ── conversions ────────────────────────────────────────────────────────────

function hexToRgb(hex) {
    var n = normalizeHex(hex);
    if (!n)
        return { r: 0, g: 0, b: 0 };
    return {
        r: parseInt(n.substring(0, 2), 16),
        g: parseInt(n.substring(2, 4), 16),
        b: parseInt(n.substring(4, 6), 16)
    };
}

function rgbToHex(r, g, b) {
    function h2(v) {
        var s = clamp(round(v), 0, 255).toString(16).toUpperCase();
        return s.length === 1 ? "0" + s : s;
    }
    return "#" + h2(r) + h2(g) + h2(b);
}

function rgbToHsl(r, g, b) {
    var rf = r / 255, gf = g / 255, bf = b / 255;
    var max = Math.max(rf, gf, bf), min = Math.min(rf, gf, bf);
    var d = max - min;
    var h = 0, s = 0, l = (max + min) / 2;

    if (d !== 0) {
        s = d / (1 - Math.abs(2 * l - 1));
        switch (max) {
        case rf: h = ((gf - bf) / d) % 6; break;
        case gf: h = (bf - rf) / d + 2; break;
        default: h = (rf - gf) / d + 4; break;
        }
        h *= 60;
        if (h < 0)
            h += 360;
    }
    return { h: round(h), s: round(s * 100), l: round(l * 100) };
}

function hslToRgb(h, s, l) {
    h = ((h % 360) + 360) % 360;
    s = clamp(s, 0, 100) / 100;
    l = clamp(l, 0, 100) / 100;
    var c = (1 - Math.abs(2 * l - 1)) * s;
    var x = c * (1 - Math.abs((h / 60) % 2 - 1));
    var m = l - c / 2;
    var rf = 0, gf = 0, bf = 0;

    if (h < 60)       { rf = c; gf = x; bf = 0; }
    else if (h < 120) { rf = x; gf = c; bf = 0; }
    else if (h < 180) { rf = 0; gf = c; bf = x; }
    else if (h < 240) { rf = 0; gf = x; bf = c; }
    else if (h < 300) { rf = x; gf = 0; bf = c; }
    else              { rf = c; gf = 0; bf = x; }

    return {
        r: round((rf + m) * 255),
        g: round((gf + m) * 255),
        b: round((bf + m) * 255)
    };
}

function rgbToHsv(r, g, b) {
    var rf = r / 255, gf = g / 255, bf = b / 255;
    var max = Math.max(rf, gf, bf), min = Math.min(rf, gf, bf);
    var d = max - min;
    var h = 0;
    var s = (max === 0) ? 0 : d / max;
    var v = max;

    if (d !== 0) {
        switch (max) {
        case rf: h = ((gf - bf) / d) % 6; break;
        case gf: h = (bf - rf) / d + 2; break;
        default: h = (rf - gf) / d + 4; break;
        }
        h *= 60;
        if (h < 0)
            h += 360;
    }
    return { h: round(h), s: round(s * 100), v: round(v * 100) };
}

function rgbToCmyk(r, g, b) {
    var rf = r / 255, gf = g / 255, bf = b / 255;
    var k = 1 - Math.max(rf, gf, bf);
    if (k >= 1)
        return { c: 0, m: 0, y: 0, k: 100 };
    return {
        c: round((1 - rf - k) / (1 - k) * 100),
        m: round((1 - gf - k) / (1 - k) * 100),
        y: round((1 - bf - k) / (1 - k) * 100),
        k: round(k * 100)
    };
}

// ── formatted string builders ────────────────────────────────────────────────

// Return the color in the requested format ("HEX","RGB","HSL","HSV","CMYK").
// lowercaseHex applies only to HEX output.
function format(rgb, fmt, lowercaseHex) {
    var r = rgb.r, g = rgb.g, b = rgb.b;
    switch (fmt) {
    case "RGB":
        return "rgb(" + r + ", " + g + ", " + b + ")";
    case "HSL": {
        var hsl = rgbToHsl(r, g, b);
        return "hsl(" + hsl.h + ", " + hsl.s + "%, " + hsl.l + "%)";
    }
    case "HSV": {
        var hsv = rgbToHsv(r, g, b);
        return "hsv(" + hsv.h + ", " + hsv.s + "%, " + hsv.v + "%)";
    }
    case "CMYK": {
        var c = rgbToCmyk(r, g, b);
        return "cmyk(" + c.c + "%, " + c.m + "%, " + c.y + "%, " + c.k + "%)";
    }
    case "HEX":
    default: {
        var hex = rgbToHex(r, g, b);
        return lowercaseHex ? hex.toLowerCase() : hex;
    }
    }
}

// All formats as a label/value list — convenient for the "copy any format" UI.
function allFormats(rgb, lowercaseHex) {
    return [
        { key: "HEX",  value: format(rgb, "HEX", lowercaseHex) },
        { key: "RGB",  value: format(rgb, "RGB") },
        { key: "HSL",  value: format(rgb, "HSL") },
        { key: "HSV",  value: format(rgb, "HSV") },
        { key: "CMYK", value: format(rgb, "CMYK") }
    ];
}

// ── WCAG contrast ────────────────────────────────────────────────────────────

function _channelLuminance(c) {
    var cs = c / 255;
    return cs <= 0.03928 ? cs / 12.92 : Math.pow((cs + 0.055) / 1.055, 2.4);
}

// Relative luminance per WCAG 2.1 (0 = black, 1 = white).
function relativeLuminance(rgb) {
    return 0.2126 * _channelLuminance(rgb.r)
         + 0.7152 * _channelLuminance(rgb.g)
         + 0.0722 * _channelLuminance(rgb.b);
}

// Contrast ratio between two colors, 1.0 .. 21.0.
function contrastRatio(rgbA, rgbB) {
    var lA = relativeLuminance(rgbA);
    var lB = relativeLuminance(rgbB);
    var lighter = Math.max(lA, lB);
    var darker = Math.min(lA, lB);
    return (lighter + 0.05) / (darker + 0.05);
}

// WCAG pass/fail verdicts for a given contrast ratio.
function wcagLevels(ratio) {
    return {
        ratio: Math.round(ratio * 100) / 100,
        aaNormal:  ratio >= 4.5,
        aaLarge:   ratio >= 3.0,
        aaaNormal: ratio >= 7.0,
        aaaLarge:  ratio >= 4.5
    };
}

// Choose black or white text for best legibility on a background color.
function bestTextColor(rgb) {
    var white = { r: 255, g: 255, b: 255 };
    var black = { r: 0, g: 0, b: 0 };
    return contrastRatio(rgb, white) >= contrastRatio(rgb, black) ? "#FFFFFF" : "#000000";
}
