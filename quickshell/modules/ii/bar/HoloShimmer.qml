import QtQuick
import qs.modules.common

Item {
    id: root
    property real intensity: 0.15
    property real speed: 3000

    anchors.fill: parent
    clip: true

    Rectangle {
        id: shimmer1
        width: 80
        height: root.height * 2
        rotation: 25
        x: -80
        y: -root.height * 0.3
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0) }
            GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, root.intensity) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
        }

        NumberAnimation on x {
            from: -80
            to: root.width + 80
            duration: root.speed
            easing.type: Easing.InOutQuad
            loops: Animation.Infinite
            running: true
        }
    }

    Rectangle {
        id: shimmer2
        width: 50
        height: root.height * 2
        rotation: 25
        x: -50
        y: -root.height * 0.3
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0) }
            GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, root.intensity * 0.5) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
        }

        NumberAnimation on x {
            from: -50
            to: root.width + 50
            duration: root.speed * 1.3
            easing.type: Easing.InOutQuad
            loops: Animation.Infinite
            running: true
        }
    }

    Repeater {
        model: 5

        Rectangle {
            required property int index
            property real baseX: (index + 1) * (root.width / 6)
            property real baseY: root.height / 2
            property real hue: index * 72

            width: 60
            height: 60
            radius: 30
            x: baseX - 30
            y: baseY - 30
            color: Qt.hsla(hue / 360, 0.7, 0.5, root.intensity * 0.15)
            opacity: 0.3

            NumberAnimation on opacity {
                from: 0.1
                to: 0.4
                duration: 2000 + index * 300
                easing.type: Easing.InOutSine
                loops: Animation.Infinite
                running: true
            }

            NumberAnimation on x {
                from: baseX - 30 - 10
                to: baseX - 30 + 10
                duration: 3000 + index * 500
                easing.type: Easing.InOutSine
                loops: Animation.Infinite
                running: true
            }

            NumberAnimation on y {
                from: baseY - 30 - 8
                to: baseY - 30 + 8
                duration: 2500 + index * 400
                easing.type: Easing.InOutSine
                loops: Animation.Infinite
                running: true
            }
        }
    }
}
