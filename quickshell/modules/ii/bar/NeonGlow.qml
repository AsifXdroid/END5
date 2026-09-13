import QtQuick
import qs.modules.common
import qs.modules.common.functions

Item {
    id: root
    property real borderWidth: 1.5
    property real radius: 20
    property color baseColor: Appearance.colors.colPrimary
    property real glowSize: 6

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.width: root.borderWidth
        border.color: ColorUtils.transparentize(root.baseColor, 0.3)
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -root.glowSize
        radius: root.radius + root.glowSize
        color: "transparent"
        border.width: 2
        border.color: ColorUtils.transparentize(root.baseColor, 0.7)
        opacity: glowAnim.value
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -(root.glowSize * 1.5)
        radius: root.radius + root.glowSize * 1.5
        color: "transparent"
        border.width: 1
        border.color: ColorUtils.transparentize(root.baseColor, 0.85)
        opacity: glowAnim.value * 0.4
    }

    SequentialAnimation {
        id: glowAnim
        property real value: 0.3
        running: true
        loops: Animation.Infinite
        NumberAnimation { target: glowAnim; property: "value"; from: 0.15; to: 0.7; duration: 2500; easing.type: Easing.InOutSine }
        NumberAnimation { target: glowAnim; property: "value"; from: 0.7; to: 0.15; duration: 2500; easing.type: Easing.InOutSine }
    }
}
