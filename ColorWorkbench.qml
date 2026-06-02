import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets
import "ColorUtils.js" as ColorUtils

Column {
    id: root

    required property var controller
    property int currentTab: 0
    property string converterInput: ""
    property var converterRgb: ColorUtils.parseAny(converterInput)
    property string fgInput: ColorUtils.rgbToHex(controller.fgRgb.r, controller.fgRgb.g, controller.fgRgb.b)
    property string bgInput: ColorUtils.rgbToHex(controller.bgRgb.r, controller.bgRgb.g, controller.bgRgb.b)

    width: parent ? parent.width : 400
    spacing: Theme.spacingL

    function tr(key, fallback, params) {
        return controller.tr(key, fallback, params)
    }

    function swatchTextColor(rgb) {
        return ColorUtils.bestTextColor(rgb)
    }

    StyledRect {
        width: parent.width
        height: 120
        radius: Theme.cornerRadius
        color: controller.currentRgb ? ColorUtils.rgbToHex(controller.currentRgb.r, controller.currentRgb.g, controller.currentRgb.b) : Theme.surfaceContainerHigh
        border.color: Theme.outlineMedium
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingXS

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: controller.currentRgb ? ColorUtils.format(controller.currentRgb, "HEX", controller.lowercaseHex) : root.tr("noColorYet", "No color picked yet")
                font.pixelSize: Theme.fontSizeXLarge
                font.weight: Font.Bold
                color: controller.currentRgb ? root.swatchTextColor(controller.currentRgb) : Theme.surfaceText
            }

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: controller.currentRgb ? ColorUtils.format(controller.currentRgb, controller.defaultFormat, controller.lowercaseHex) : root.tr("pickHint", "Click Pick to sample a color from your screen")
                font.pixelSize: Theme.fontSizeSmall
                color: controller.currentRgb ? root.swatchTextColor(controller.currentRgb) : Theme.surfaceVariantText
            }
        }
    }

    RowLayout {
        width: parent.width
        spacing: Theme.spacingM

        DankButton {
            Layout.fillWidth: true
            text: controller.picking ? root.tr("picking", "Picking…") : root.tr("pickColor", "Pick Color")
            iconName: "colorize"
            backgroundColor: Theme.primary
            textColor: Theme.onPrimary
            enabled: !controller.picking
            onClicked: controller.pickInteractive()
        }

        DankButton {
            text: root.tr("addToPalette", "Add to palette")
            iconName: "palette"
            enabled: controller.currentRgb !== null
            backgroundColor: Theme.secondary
            textColor: Theme.onPrimary
            onClicked: controller.addToPalette()
        }
    }

    DankTabBar {
        width: parent.width
        model: [
            { text: root.tr("tab.pick", "Pick"), icon: "content_copy" },
            { text: root.tr("tab.convert", "Convert"), icon: "swap_horiz" },
            { text: root.tr("tab.contrast", "Contrast"), icon: "contrast" },
            { text: root.tr("tab.palette", "Palette"), icon: "palette" }
        ]
        currentIndex: root.currentTab
        onTabClicked: index => root.currentTab = index
    }

    Item { width: 1; height: Theme.spacingS }

    Column {
        width: parent.width
        spacing: Theme.spacingM
        visible: root.currentTab === 0

        Repeater {
            model: controller.currentRgb ? ColorUtils.allFormats(controller.currentRgb, controller.lowercaseHex) : []

            StyledRect {
                width: root.width
                height: 44
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Theme.outlineMedium
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingM

                    StyledText {
                        text: modelData.key
                        color: Theme.primary
                        font.weight: Font.Bold
                        font.pixelSize: Theme.fontSizeMedium
                        Layout.preferredWidth: 52
                    }

                    StyledText {
                        text: modelData.value
                        color: Theme.surfaceText
                        font.pixelSize: Theme.fontSizeMedium
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    DankActionButton {
                        iconName: "content_copy"
                        tooltipText: root.tr("copy", "Copy")
                        onClicked: controller.copyText(modelData.value)
                    }
                }
            }
        }
    }

    Column {
        width: parent.width
        spacing: Theme.spacingM
        visible: root.currentTab === 1

        DankTextField {
            width: parent.width
            placeholderText: root.tr("inputPlaceholder", "#1E90FF, rgb(30,144,255), hsl(210,100%,56%)")
            text: root.converterInput
            leftIconName: "edit"
            showClearButton: true
            onTextEdited: root.converterInput = text
            onAccepted: root.converterInput = text
        }

        StyledText {
            width: parent.width
            text: root.tr("invalidColor", "Invalid color")
            color: Theme.error
            font.pixelSize: Theme.fontSizeSmall
            visible: root.converterInput.length > 0 && root.converterRgb === null
        }

        Repeater {
            model: root.converterRgb ? ColorUtils.allFormats(root.converterRgb, controller.lowercaseHex) : []
            StyledRect {
                width: root.width
                height: 44
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Theme.outlineMedium
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingM

                    StyledText { text: modelData.key; color: Theme.primary; font.weight: Font.Bold; Layout.preferredWidth: 52 }
                    StyledText { text: modelData.value; color: Theme.surfaceText; elide: Text.ElideRight; Layout.fillWidth: true }
                    DankActionButton { iconName: "content_copy"; onClicked: controller.copyText(modelData.value) }
                }
            }
        }
    }

    Column {
        width: parent.width
        spacing: Theme.spacingM
        visible: root.currentTab === 2

        RowLayout {
            width: parent.width
            spacing: Theme.spacingM

            DankTextField {
                Layout.fillWidth: true
                placeholderText: root.tr("foreground", "Foreground")
                text: root.fgInput
                leftIconName: "format_color_text"
                onTextEdited: {
                    root.fgInput = text
                    const parsed = ColorUtils.parseAny(text)
                    if (parsed) controller.fgRgb = parsed
                }
            }

            DankTextField {
                Layout.fillWidth: true
                placeholderText: root.tr("background", "Background")
                text: root.bgInput
                leftIconName: "format_color_fill"
                onTextEdited: {
                    root.bgInput = text
                    const parsed = ColorUtils.parseAny(text)
                    if (parsed) controller.bgRgb = parsed
                }
            }

            DankActionButton {
                iconName: "swap_horiz"
                tooltipText: root.tr("swap", "Swap")
                onClicked: {
                    const tmp = controller.fgRgb
                    controller.fgRgb = controller.bgRgb
                    controller.bgRgb = tmp
                    root.fgInput = ColorUtils.rgbToHex(controller.fgRgb.r, controller.fgRgb.g, controller.fgRgb.b)
                    root.bgInput = ColorUtils.rgbToHex(controller.bgRgb.r, controller.bgRgb.g, controller.bgRgb.b)
                }
            }
        }

        StyledRect {
            width: parent.width
            height: 96
            radius: Theme.cornerRadius
            color: ColorUtils.rgbToHex(controller.bgRgb.r, controller.bgRgb.g, controller.bgRgb.b)
            border.color: Theme.outlineMedium
            border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: Theme.spacingXS
                StyledText {
                    text: root.tr("sample", "Sample text")
                    color: ColorUtils.rgbToHex(controller.fgRgb.r, controller.fgRgb.g, controller.fgRgb.b)
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Medium
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                StyledText {
                    text: root.tr("sampleLarge", "Large text")
                    color: ColorUtils.rgbToHex(controller.fgRgb.r, controller.fgRgb.g, controller.fgRgb.b)
                    font.pixelSize: Theme.fontSizeXLarge
                    font.weight: Font.Bold
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        property real ratio: ColorUtils.contrastRatio(controller.fgRgb, controller.bgRgb)
        property var levels: ColorUtils.wcagLevels(ratio)

        StyledText {
            text: root.tr("contrastRatio", "Contrast ratio") + ": " + parent.levels.ratio + ":1"
            color: Theme.surfaceText
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Font.Bold
        }

        GridLayout {
            width: parent.width
            columns: 2
            columnSpacing: Theme.spacingM
            rowSpacing: Theme.spacingM

            Repeater {
                model: [
                    { key: root.tr("aaNormal", "AA Normal"), pass: parent.parent.levels.aaNormal },
                    { key: root.tr("aaLarge", "AA Large"), pass: parent.parent.levels.aaLarge },
                    { key: root.tr("aaaNormal", "AAA Normal"), pass: parent.parent.levels.aaaNormal },
                    { key: root.tr("aaaLarge", "AAA Large"), pass: parent.parent.levels.aaaLarge }
                ]

                StyledRect {
                    Layout.fillWidth: true
                    height: 36
                    radius: Theme.cornerRadius
                    color: modelData.pass ? Theme.primaryBackground : Theme.errorHover
                    border.color: modelData.pass ? Theme.primary : Theme.error
                    border.width: 1
                    StyledText {
                        anchors.centerIn: parent
                        text: modelData.key + " · " + (modelData.pass ? root.tr("pass", "Pass") : root.tr("fail", "Fail"))
                        color: modelData.pass ? Theme.primary : Theme.error
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Medium
                    }
                }
            }
        }
    }

    Column {
        width: parent.width
        spacing: Theme.spacingM
        visible: root.currentTab === 3

        RowLayout {
            width: parent.width
            StyledText {
                Layout.fillWidth: true
                text: (controller.palette || []).length === 0 ? root.tr("paletteEmpty", "Palette is empty") : root.tr("tab.palette", "Palette")
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Bold
            }
            DankActionButton {
                iconName: "delete_sweep"
                enabled: (controller.palette || []).length > 0
                tooltipText: root.tr("clearPalette", "Clear palette")
                onClicked: controller.clearPalette()
            }
        }

        StyledText {
            width: parent.width
            text: root.tr("paletteHint", "Pick a color and add it to build a palette")
            color: Theme.surfaceVariantText
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
            visible: (controller.palette || []).length === 0
        }

        GridLayout {
            width: parent.width
            columns: 2
            rowSpacing: Theme.spacingM
            columnSpacing: Theme.spacingM

            Repeater {
                model: controller.palette || []

                StyledRect {
                    Layout.fillWidth: true
                    height: 48
                    radius: Theme.cornerRadius
                    color: modelData
                    border.color: Theme.outlineMedium
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        StyledText {
                            text: modelData
                            color: ColorUtils.bestTextColor(ColorUtils.hexToRgb(modelData))
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Bold
                            Layout.fillWidth: true
                        }
                        DankActionButton {
                            iconName: "content_copy"
                            iconColor: ColorUtils.bestTextColor(ColorUtils.hexToRgb(modelData))
                            backgroundColor: "transparent"
                            onClicked: controller.copyText(modelData)
                        }
                        DankActionButton {
                            iconName: "close"
                            iconColor: ColorUtils.bestTextColor(ColorUtils.hexToRgb(modelData))
                            backgroundColor: "transparent"
                            onClicked: controller.removeFromPalette(modelData)
                        }
                    }
                }
            }
        }
    }
}
