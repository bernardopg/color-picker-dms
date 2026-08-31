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
    readonly property var converterRgb: ColorUtils.parseAny(converterInput)
    property string fgInput: ColorUtils.rgbToHex(controller.fgRgb.r, controller.fgRgb.g, controller.fgRgb.b)
    property string bgInput: ColorUtils.rgbToHex(controller.bgRgb.r, controller.bgRgb.g, controller.bgRgb.b)

    // Shared metrics: every card, row and grid cell follows the same rhythm so
    // the tabs line up with each other instead of drifting per section.
    readonly property int rowHeight: 48
    readonly property int labelColumnWidth: 58
    readonly property int gridCellHeight: 40
    readonly property int paletteCellHeight: 52
    readonly property int swatchHeight: 132
    readonly property int sampleHeight: 108

    readonly property real contrastRatio: ColorUtils.contrastRatio(controller.fgRgb, controller.bgRgb)
    readonly property var contrastLevels: ColorUtils.wcagLevels(contrastRatio)
    readonly property int paletteCount: (controller.palette || []).length

    width: parent ? parent.width : 400
    spacing: Theme.spacingL

    function tr(key, fallback, params) {
        return controller.tr(key, fallback, params)
    }

    function swatchTextColor(rgb) {
        return ColorUtils.bestTextColor(rgb)
    }

    // One row shape reused by the Pick and Convert tabs, so both stay aligned
    // to the same label column, paddings and control size.
    component FormatRow: StyledRect {
        id: formatRow

        property string label: ""
        property string value: ""
        property int labelWidth: 58
        property int rowHeight: 48
        property string copyTooltip: ""

        signal copyRequested

        height: formatRow.rowHeight
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh
        border.color: Theme.outlineMedium
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingM
            anchors.rightMargin: Theme.spacingS
            anchors.topMargin: Theme.spacingS
            anchors.bottomMargin: Theme.spacingS
            spacing: Theme.spacingM

            StyledText {
                text: formatRow.label
                color: Theme.primary
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Bold
                verticalAlignment: Text.AlignVCenter
                Layout.preferredWidth: formatRow.labelWidth
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
            }

            StyledText {
                text: formatRow.value
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeMedium
                isMonospace: true
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
            }

            DankActionButton {
                iconName: "content_copy"
                tooltipText: formatRow.copyTooltip
                Layout.alignment: Qt.AlignVCenter
                onClicked: formatRow.copyRequested()
            }
        }
    }

    StyledRect {
        width: parent.width
        height: root.swatchHeight
        radius: Theme.cornerRadius
        color: controller.currentRgb ? ColorUtils.rgbToHex(controller.currentRgb.r, controller.currentRgb.g, controller.currentRgb.b) : Theme.surfaceContainerHigh
        border.color: Theme.outlineMedium
        border.width: 1

        Column {
            anchors.centerIn: parent
            width: parent.width - Theme.spacingL * 2
            spacing: Theme.spacingXS

            StyledText {
                width: parent.width
                text: controller.currentRgb ? ColorUtils.format(controller.currentRgb, "HEX", controller.lowercaseHex) : root.tr("noColorYet", "No color picked yet")
                font.pixelSize: Theme.fontSizeXLarge
                font.weight: Font.Bold
                isMonospace: controller.currentRgb !== null
                color: controller.currentRgb ? root.swatchTextColor(controller.currentRgb) : Theme.surfaceText
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            StyledText {
                width: parent.width
                // Evita repetir o HEX que já aparece acima: quando o formato
                // padrão é HEX, a linha secundária mostra o RGB.
                text: controller.currentRgb ? ColorUtils.format(controller.currentRgb, controller.defaultFormat === "HEX" ? "RGB" : controller.defaultFormat, controller.lowercaseHex) : root.tr("pickHint", "Click Pick to sample a color from your screen")
                font.pixelSize: Theme.fontSizeSmall
                isMonospace: controller.currentRgb !== null
                color: controller.currentRgb ? root.swatchTextColor(controller.currentRgb) : Theme.surfaceVariantText
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }
    }

    RowLayout {
        width: parent.width
        spacing: Theme.spacingM

        DankButton {
            Layout.fillWidth: true
            Layout.preferredHeight: buttonHeight
            Layout.alignment: Qt.AlignVCenter
            text: controller.picking ? root.tr("picking", "Picking…") : root.tr("pickColor", "Pick Color")
            iconName: "colorize"
            backgroundColor: Theme.primary
            textColor: Theme.onPrimary
            enabled: !controller.picking
            onClicked: controller.pickInteractive()
        }

        DankButton {
            Layout.preferredHeight: buttonHeight
            Layout.alignment: Qt.AlignVCenter
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

    Column {
        width: parent.width
        spacing: Theme.spacingM
        visible: root.currentTab === 0

        StyledText {
            width: parent.width
            text: root.tr("pickHint", "Click Pick to sample a color from your screen")
            color: Theme.surfaceVariantText
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            visible: controller.currentRgb === null
        }

        Repeater {
            model: controller.currentRgb ? ColorUtils.allFormats(controller.currentRgb, controller.lowercaseHex) : []

            FormatRow {
                width: parent.width
                label: modelData.key
                value: modelData.value
                labelWidth: root.labelColumnWidth
                rowHeight: root.rowHeight
                copyTooltip: root.tr("copy", "Copy")
                onCopyRequested: controller.copyText(modelData.value)
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
            wrapMode: Text.WordWrap
            visible: root.converterInput.length > 0 && root.converterRgb === null
        }

        Repeater {
            model: root.converterRgb ? ColorUtils.allFormats(root.converterRgb, controller.lowercaseHex) : []

            FormatRow {
                width: parent.width
                label: modelData.key
                value: modelData.value
                labelWidth: root.labelColumnWidth
                rowHeight: root.rowHeight
                copyTooltip: root.tr("copy", "Copy")
                onCopyRequested: controller.copyText(modelData.value)
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
                Layout.preferredWidth: 1
                Layout.alignment: Qt.AlignVCenter
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
                Layout.preferredWidth: 1
                Layout.alignment: Qt.AlignVCenter
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
                Layout.alignment: Qt.AlignVCenter
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
            height: root.sampleHeight
            radius: Theme.cornerRadius
            color: ColorUtils.rgbToHex(controller.bgRgb.r, controller.bgRgb.g, controller.bgRgb.b)
            border.color: Theme.outlineMedium
            border.width: 1

            Column {
                anchors.centerIn: parent
                width: parent.width - Theme.spacingL * 2
                spacing: Theme.spacingXS

                StyledText {
                    width: parent.width
                    text: root.tr("sample", "Sample text")
                    color: ColorUtils.rgbToHex(controller.fgRgb.r, controller.fgRgb.g, controller.fgRgb.b)
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                StyledText {
                    width: parent.width
                    text: root.tr("sampleLarge", "Large text")
                    color: ColorUtils.rgbToHex(controller.fgRgb.r, controller.fgRgb.g, controller.fgRgb.b)
                    font.pixelSize: Theme.fontSizeXLarge
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }
            }
        }

        StyledRect {
            width: parent.width
            height: root.rowHeight
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh
            border.color: Theme.outlineMedium
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingM
                anchors.rightMargin: Theme.spacingM
                spacing: Theme.spacingM

                StyledText {
                    text: root.tr("contrastRatio", "Contrast ratio")
                    color: Theme.surfaceVariantText
                    font.pixelSize: Theme.fontSizeMedium
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                }

                StyledText {
                    text: root.contrastLevels.ratio + ":1"
                    color: Theme.surfaceText
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    isMonospace: true
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        GridLayout {
            width: parent.width
            columns: 2
            columnSpacing: Theme.spacingM
            rowSpacing: Theme.spacingM

            Repeater {
                model: [
                    { key: root.tr("aaNormal", "AA Normal"), pass: root.contrastLevels.aaNormal },
                    { key: root.tr("aaLarge", "AA Large"), pass: root.contrastLevels.aaLarge },
                    { key: root.tr("aaaNormal", "AAA Normal"), pass: root.contrastLevels.aaaNormal },
                    { key: root.tr("aaaLarge", "AAA Large"), pass: root.contrastLevels.aaaLarge }
                ]

                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: root.gridCellHeight
                    radius: Theme.cornerRadius
                    color: modelData.pass ? Theme.primaryBackground : Theme.errorHover
                    border.color: modelData.pass ? Theme.primary : Theme.error
                    border.width: 1

                    StyledText {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingS
                        anchors.rightMargin: Theme.spacingS
                        text: modelData.key + " · " + (modelData.pass ? root.tr("pass", "Pass") : root.tr("fail", "Fail"))
                        color: modelData.pass ? Theme.primary : Theme.error
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
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
            spacing: Theme.spacingM

            StyledText {
                text: root.tr("tab.palette", "Palette")
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Bold
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            StyledText {
                text: root.paletteCount + " " + root.tr("colors", "colors")
                color: Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeSmall
                verticalAlignment: Text.AlignVCenter
                visible: root.paletteCount > 0
                Layout.alignment: Qt.AlignVCenter
            }

            DankActionButton {
                iconName: "delete_sweep"
                enabled: root.paletteCount > 0
                tooltipText: root.tr("clearPalette", "Clear palette")
                Layout.alignment: Qt.AlignVCenter
                onClicked: controller.clearPalette()
            }
        }

        StyledText {
            width: parent.width
            text: root.tr("paletteHint", "Pick a color and add it to build a palette")
            color: Theme.surfaceVariantText
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            visible: root.paletteCount === 0
        }

        GridLayout {
            width: parent.width
            columns: 2
            rowSpacing: Theme.spacingM
            columnSpacing: Theme.spacingM
            visible: root.paletteCount > 0

            Repeater {
                model: controller.palette || []

                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: root.paletteCellHeight
                    radius: Theme.cornerRadius
                    color: modelData
                    border.color: Theme.outlineMedium
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingM
                        anchors.rightMargin: Theme.spacingXS
                        anchors.topMargin: Theme.spacingXS
                        anchors.bottomMargin: Theme.spacingXS
                        spacing: Theme.spacingXS

                        StyledText {
                            text: modelData
                            color: ColorUtils.bestTextColor(ColorUtils.hexToRgb(modelData))
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Bold
                            isMonospace: true
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignVCenter
                        }

                        DankActionButton {
                            iconName: "content_copy"
                            iconColor: ColorUtils.bestTextColor(ColorUtils.hexToRgb(modelData))
                            backgroundColor: "transparent"
                            tooltipText: root.tr("copy", "Copy")
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: controller.copyText(modelData)
                        }

                        DankActionButton {
                            iconName: "close"
                            iconColor: ColorUtils.bestTextColor(ColorUtils.hexToRgb(modelData))
                            backgroundColor: "transparent"
                            tooltipText: root.tr("remove", "Remove")
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: controller.removeFromPalette(modelData)
                        }
                    }
                }
            }
        }
    }
}
