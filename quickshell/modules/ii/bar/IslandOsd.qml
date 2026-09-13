import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

Item {
    id: root
    property string type: "volume" // volume | brightness | gamma

    readonly property var focusedScreen: WM.compositor === "hyprland"
        ? Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)
        : Quickshell.screens.find(s => s.name === WM.focusedMonitor?.name)
    readonly property var brightnessMonitor: Brightness.getMonitorForScreen(root.focusedScreen)

    readonly property bool isVolume: root.type === "volume"
    readonly property real value: isVolume
        ? ((Audio.sink?.audio.volume ?? 0))
        : root.type === "brightness"
            ? (root.brightnessMonitor?.brightness ?? 0.5)
            : (Hyprsunset.gamma / 100 ?? 0.5)
    readonly property bool iconRotate: root.type === "brightness"

    implicitWidth: row.implicitWidth + 8
    implicitHeight: row.implicitHeight

    Connections {
        target: root
        function onValueChanged() {
            iconPulse.restart()
            valPulse.restart()
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Rectangle {
            id: iconBg
            Layout.alignment: Qt.AlignVCenter
            width: 28
            height: 28
            radius: 14
            color: Appearance.colors.colSecondaryContainer

            MaterialSymbol {
                id: iconText
                anchors.centerIn: parent
                color: Appearance.colors.colOnSecondaryContainer
                renderType: Text.QtRendering
                text: isVolume
                    ? (Audio.sink?.audio.muted ? "volume_off" : "volume_up")
                    : root.type === "brightness" ? "light_mode" : "wb_twilight"
                iconSize: 22
                rotation: root.iconRotate ? 180 * root.value : 0

                Behavior on rotation {
                    animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
                }
            }

            SequentialAnimation {
                id: iconPulse
                NumberAnimation {
                    target: iconText
                    property: "opacity"
                    to: 0.35
                    duration: 80
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: iconText
                    property: "opacity"
                    to: 1.0
                    duration: 140
                    easing.type: Easing.InOutQuad
                }
            }
        }

        StyledSlider {
            id: valueSlider
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 130
            configuration: StyledSlider.Configuration.XS
            stopIndicatorValues: []
            from: 0
            to: 1
            value: root.value
        }

        Rectangle {
            id: valueBg
            Layout.alignment: Qt.AlignVCenter
            width: 40
            height: 28
            radius: 14
            color: Appearance.colors.colTertiaryContainer

            StyledText {
                id: valueText
                anchors.centerIn: parent
                color: Appearance.colors.colOnTertiaryContainer
                font.pixelSize: Appearance.font.pixelSize.normal
                font.features: { "tnum": 1 }
                text: Math.round(root.value * 100)
            }

            SequentialAnimation {
                id: valPulse
                NumberAnimation {
                    target: valueText
                    property: "scale"
                    from: 0.9
                    to: 1.0
                    duration: 60
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: valueText
                    property: "scale"
                    to: 1.0
                    duration: 120
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
}