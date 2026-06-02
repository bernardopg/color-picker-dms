import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import "ColorUtils.js" as ColorUtils
import "." as Local

PluginComponent {
    id: root

    pluginId: "colorPicker"

    // ── persisted settings (read live) ───────────────────────────────────────
    property string defaultFormat: _load("defaultFormat", "HEX")
    property string backend: _load("backend", "auto")
    property bool lowercaseHex: _load("lowercaseHex", false)
    property bool autoCopy: _load("autoCopy", true)

    // ── live state ───────────────────────────────────────────────────────────
    property var currentRgb: null          // {r,g,b} of the last picked/typed color
    property string lastBackend: ""
    property bool picking: false
    property var palette: _load("palette", [])   // array of "#RRGGBB"

    // contrast tab
    property var fgRgb: ({ r: 33, g: 33, b: 33 })
    property var bgRgb: ({ r: 255, g: 255, b: 255 })

    readonly property string pluginDir: Qt.resolvedUrl(".").toString().replace("file://", "")

    function tr(key, fallback, params) {
        return Local.ColorPickerI18n.tr(key, fallback, params)
    }

    function _load(key, def) {
        if (typeof PluginService !== "undefined" && PluginService)
            return PluginService.loadPluginData(root.pluginId, key, def)
        return def
    }

    function _save(key, value) {
        if (typeof PluginService !== "undefined" && PluginService)
            PluginService.savePluginData(root.pluginId, key, value)
    }

    function reloadSettings() {
        defaultFormat = _load("defaultFormat", "HEX")
        backend = _load("backend", "auto")
        lowercaseHex = _load("lowercaseHex", false)
        autoCopy = _load("autoCopy", true)
        palette = _load("palette", [])
    }

    Connections {
        target: typeof PluginService !== "undefined" ? PluginService : null
        function onPluginDataChanged(changedPluginId) {
            if (changedPluginId === root.pluginId)
                root.reloadSettings()
        }
    }

    // ── clipboard ────────────────────────────────────────────────────────────
    function copyText(text) {
        const cmd = "printf %s " + _shQuote(text) + " | wl-copy"
        Quickshell.execDetached(["sh", "-c", cmd])
        if (typeof ToastService !== "undefined" && ToastService)
            ToastService.showInfo(root.tr("copied", "Copied {value}", { value: text }))
    }

    function lastColorText(format) {
        if (!root.currentRgb)
            return ""
        return ColorUtils.format(root.currentRgb, format || root.defaultFormat, root.lowercaseHex)
    }

    function copyLastColor(format) {
        if (!root.currentRgb) {
            if (typeof ToastService !== "undefined" && ToastService)
                ToastService.showError(root.tr("noColorYet", "No color picked yet"))
            return
        }
        root.copyText(root.lastColorText(format || root.defaultFormat))
    }

    function copyAllFormats() {
        if (!root.currentRgb) {
            if (typeof ToastService !== "undefined" && ToastService)
                ToastService.showError(root.tr("noColorYet", "No color picked yet"))
            return
        }
        const lines = ColorUtils.allFormats(root.currentRgb, root.lowercaseHex).map(item => item.key + ": " + item.value)
        root.copyText(lines.join("\n"))
    }

    function copyPalette() {
        const p = root.palette || []
        if (p.length === 0) {
            if (typeof ToastService !== "undefined" && ToastService)
                ToastService.showError(root.tr("paletteEmpty", "Palette is empty"))
            return
        }
        root.copyText(p.join("\n"))
    }

    function _shQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    // ── screen capture ───────────────────────────────────────────────────────
    Process {
        id: pickProcess
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root._handlePickOutput(text)
            }
        }
        onExited: (code, status) => {
            root.picking = false
            if (code !== 0)
                root._pickError()
        }
    }

    function _handlePickOutput(rawText) {
        const raw = (rawText || "").trim()
        if (raw === "")
            return
        try {
            const data = JSON.parse(raw)
            if (data.error) {
                root._pickError()
                return
            }
            root.currentRgb = { r: data.r, g: data.g, b: data.b }
            root.lastBackend = data.backend || ""
            if (root.autoCopy)
                root.copyText(ColorUtils.format(root.currentRgb, root.defaultFormat, root.lowercaseHex))
        } catch (e) {
            root._pickError()
        }
    }

    function _pickError() {
        if (typeof ToastService !== "undefined" && ToastService)
            ToastService.showError(root.tr("pickError", "Color pick failed or cancelled"))
    }

    Timer {
        id: delayedPickTimer
        interval: 300
        repeat: false
        onTriggered: root._startPickProcess()
    }

    function _hidePluginSurfaces() {
        root.closePopout()
        if (typeof PopoutService !== "undefined" && PopoutService)
            PopoutService.closeControlCenter()
    }

    function _startPickProcess() {
        pickProcess.command = ["bash", root.pluginDir + "capture/pick-color", "--backend", root.backend]
        pickProcess.running = true
    }

    // Hide plugin UI first, then capture so the picker can sample anything on screen.
    function pickInteractive() {
        if (root.picking)
            return
        root.picking = true
        root._hidePluginSurfaces()
        delayedPickTimer.restart()
    }

    // Capture from the bar pill/control-center: same flow, with hidden plugin UI.
    function pickQuick() {
        pickInteractive()
    }

    function showPillMenu(x, y, triggerWidth, section, currentScreen) {
        pillContextMenu.close()
        pillContextMenu.x = Math.max(Theme.spacingM, x)
        pillContextMenu.y = Math.max(Theme.spacingM, y)
        pillContextMenu.open()
    }

    // ── palette ──────────────────────────────────────────────────────────────
    function addToPalette() {
        if (!root.currentRgb)
            return
        const hex = ColorUtils.rgbToHex(root.currentRgb.r, root.currentRgb.g, root.currentRgb.b)
        let p = (root.palette || []).slice()
        if (p.indexOf(hex) === -1) {
            p.unshift(hex)
            if (p.length > 24)
                p = p.slice(0, 24)
            root.palette = p
            root._save("palette", p)
            if (typeof ToastService !== "undefined" && ToastService)
                ToastService.showInfo(root.tr("addedToPalette", "Added to palette"))
        }
    }

    function removeFromPalette(hex) {
        let p = (root.palette || []).filter(c => c !== hex)
        root.palette = p
        root._save("palette", p)
    }

    function clearPalette() {
        root.palette = []
        root._save("palette", [])
    }

    // ── control-center pill ──────────────────────────────────────────────────
    ccWidgetIcon: "colorize"
    ccWidgetPrimaryText: root.tr("name", "Color Picker")
    ccWidgetSecondaryText: root.currentRgb
        ? ColorUtils.format(root.currentRgb, root.defaultFormat, root.lowercaseHex)
        : root.tr("tab.pick", "Pick")
    ccWidgetIsActive: root.currentRgb !== null
    onCcWidgetToggled: pickQuick()
    pillRightClickAction: showPillMenu

    ccDetailContent: Component {
        Item {
            implicitHeight: ccCol.implicitHeight
            ColorWorkbench {
                id: ccCol
                width: parent.width
                controller: root
            }
        }
    }

    // ── popout (full workbench) ──────────────────────────────────────────────
    popoutWidth: 420
    popoutHeight: 560
    popoutContent: Component {
        PopoutComponent {
            id: popoutComp
            headerText: root.tr("name", "Color Picker")
            detailsText: root.lastBackend ? root.lastBackend : ""
            showCloseButton: true

            DankFlickable {
                width: parent.width
                height: root.popoutHeight - popoutComp.headerHeight - Theme.spacingL
                contentHeight: wb.implicitHeight
                clip: true

                ColorWorkbench {
                    id: wb
                    width: parent.width
                    controller: root
                }
            }
        }
    }

    // ── bar pills ────────────────────────────────────────────────────────────
    horizontalBarPill: Component {
        MouseArea {
            width: root.barThickness
            height: root.barThickness
            cursorShape: Qt.PointingHandCursor
            onClicked: root.pickQuick()
            DankIcon {
                name: "colorize"
                size: Theme.barIconSize(root.barThickness, -2)
                color: root.picking ? Theme.primary : Theme.widgetIconColor
                anchors.centerIn: parent
            }
        }
    }

    verticalBarPill: Component {
        MouseArea {
            width: root.barThickness
            height: root.barThickness
            cursorShape: Qt.PointingHandCursor
            onClicked: root.pickQuick()
            DankIcon {
                name: "colorize"
                size: Theme.barIconSize(root.barThickness, -2)
                color: root.picking ? Theme.primary : Theme.widgetIconColor
                anchors.centerIn: parent
            }
        }
    }

    Popup {
        id: pillContextMenu

        parent: Overlay.overlay
        width: 252
        height: menuColumn.implicitHeight + Theme.spacingM * 2
        padding: 0
        modal: true
        dim: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "transparent"
        }

        contentItem: StyledRect {
            radius: Theme.cornerRadius
            color: Theme.surfaceContainer
            border.color: Theme.outlineMedium
            border.width: 1

            Column {
                id: menuColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingXS

                PillMenuAction {
                    iconName: "colorize"
                    label: root.picking ? root.tr("picking", "Picking…") : root.tr("pickColor", "Pick Color")
                    enabled: !root.picking
                    onTriggered: {
                        pillContextMenu.close()
                        root.pickInteractive()
                    }
                }

                PillMenuAction {
                    iconName: "content_copy"
                    label: root.tr("copyLast", "Copy last color")
                    hint: root.currentRgb ? root.lastColorText(root.defaultFormat) : root.tr("noColorYet", "No color picked yet")
                    enabled: root.currentRgb !== null
                    onTriggered: {
                        pillContextMenu.close()
                        root.copyLastColor(root.defaultFormat)
                    }
                }

                PillMenuAction {
                    iconName: "tag"
                    label: root.tr("copyHex", "Copy HEX")
                    hint: root.currentRgb ? root.lastColorText("HEX") : ""
                    enabled: root.currentRgb !== null
                    onTriggered: {
                        pillContextMenu.close()
                        root.copyLastColor("HEX")
                    }
                }

                PillMenuAction {
                    iconName: "palette"
                    label: root.tr("copyRgb", "Copy RGB")
                    hint: root.currentRgb ? root.lastColorText("RGB") : ""
                    enabled: root.currentRgb !== null
                    onTriggered: {
                        pillContextMenu.close()
                        root.copyLastColor("RGB")
                    }
                }

                PillMenuAction {
                    iconName: "format_list_bulleted"
                    label: root.tr("copyAllFormats", "Copy all formats")
                    enabled: root.currentRgb !== null
                    onTriggered: {
                        pillContextMenu.close()
                        root.copyAllFormats()
                    }
                }

                PillMenuAction {
                    iconName: "playlist_add"
                    label: root.tr("addToPalette", "Add to palette")
                    enabled: root.currentRgb !== null
                    onTriggered: {
                        pillContextMenu.close()
                        root.addToPalette()
                    }
                }

                PillMenuAction {
                    iconName: "inventory_2"
                    label: root.tr("copyPalette", "Copy palette")
                    hint: (root.palette || []).length + " " + root.tr("colors", "colors")
                    enabled: (root.palette || []).length > 0
                    onTriggered: {
                        pillContextMenu.close()
                        root.copyPalette()
                    }
                }

                PillMenuAction {
                    iconName: "tune"
                    label: root.tr("openWorkbench", "Open workbench")
                    onTriggered: {
                        pillContextMenu.close()
                        root.triggerPopout()
                    }
                }
            }
        }
    }

    component PillMenuAction: StyledRect {
        id: action

        property string iconName: ""
        property string label: ""
        property string hint: ""
        property bool enabled: true
        signal triggered

        width: parent ? parent.width : 220
        height: hint.length > 0 ? 48 : 38
        radius: Theme.cornerRadius
        color: actionMouse.containsMouse && action.enabled ? Theme.surfaceContainerHigh : Theme.surfaceContainer
        opacity: action.enabled ? 1.0 : 0.45

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingM
            anchors.rightMargin: Theme.spacingM
            spacing: Theme.spacingM

            DankIcon {
                name: action.iconName
                size: 18
                color: Theme.primary
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                StyledText {
                    text: action.label
                    color: Theme.surfaceText
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                StyledText {
                    text: action.hint
                    color: Theme.surfaceVariantText
                    font.pixelSize: Theme.fontSizeXSmall
                    elide: Text.ElideRight
                    visible: action.hint.length > 0
                    Layout.fillWidth: true
                }
            }
        }

        MouseArea {
            id: actionMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: action.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            acceptedButtons: Qt.LeftButton
            onClicked: {
                if (action.enabled)
                    action.triggered()
            }
        }
    }
}
