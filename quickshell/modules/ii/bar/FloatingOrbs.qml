import QtQuick
import qs.modules.common

Item {
    id: root
    property real orbCount: 6
    property real minSize: 3
    property real maxSize: 8
    property color orbColor: Appearance.colors.colPrimary
    property real speed: 2000

    anchors.fill: parent

    Repeater {
        model: Math.round(root.orbCount)

        Rectangle {
            id: orb
            required property int index
            property real orbSize: root.minSize + (index % 3) * ((root.maxSize - root.minSize) / 3)
            property real startX: (index + 1) * (root.width / (root.orbCount + 1))
            property real startY: root.height * 0.3 + (index % 2) * root.height * 0.4
            property real endX: startX + (index % 2 === 0 ? 30 : -30)
            property real endY: startY + (index % 3 === 0 ? -20 : 20)

            width: orbSize
            height: orbSize
            radius: orbSize / 2
            color: root.orbColor
            opacity: 0
            x: startX
            y: startY

            SequentialAnimation on opacity {
                running: true
                loops: Animation.Infinite
                PauseAnimation { duration: orb.index * 200 }
                NumberAnimation { from: 0; to: 0.6; duration: 400; easing.type: Easing.OutQuad }
                PauseAnimation { duration: 600 + orb.index * 100 }
                NumberAnimation { from: 0.6; to: 0; duration: 400; easing.type: Easing.InQuad }
            }

            NumberAnimation on x {
                from: orb.startX; to: orb.endX
                duration: root.speed + orb.index * 300
                easing.type: Easing.InOutSine
                loops: Animation.Infinite
                running: true
            }

            NumberAnimation on y {
                from: orb.startY; to: orb.endY
                duration: root.speed + orb.index * 400
                easing.type: Easing.InOutSine
                loops: Animation.Infinite
                running: true
            }
        }
    }
}
