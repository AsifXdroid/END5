import QtQuick
import qs.modules.common

Item {
    id: root
    property real borderWidth: 2
    property real radius: 20
    property real rotationSpeed: 3000
    property color color1: Appearance.colors.colPrimary
    property color color2: Appearance.colors.colSecondary
    property color color3: Appearance.colors.colTertiary
    property bool breathing: true

    width: parent ? parent.width : 100
    height: parent ? parent.height : 50

    Item {
        id: borderClip
        anchors.fill: parent
        layer.enabled: true

        Rectangle {
            id: outer
            anchors.fill: parent
            radius: root.radius
            color: Qt.rgba(0, 0, 0, 0.01)
        }

        Rectangle {
            id: inner
            anchors.fill: parent
            anchors.margins: root.borderWidth * 2
            radius: root.radius - root.borderWidth
            color: "black"
        }
    }

    Rectangle {
        id: gradientDisc
        anchors.fill: parent
        anchors.margins: -20
        rotation: gradRot.angle
        conicalGradient: Gradient {
            GradientStop { position: 0.0; color: root.color1 }
            GradientStop { position: 0.25; color: root.color2 }
            GradientStop { position: 0.5; color: root.color3 }
            GradientStop { position: 0.75; color: root.color2 }
            GradientStop { position: 1.0; color: root.color1 }
        }

        RotationAnimator on rotation {
            id: gradRot
            from: 0
            to: 360
            duration: root.rotationSpeed
            loops: Animation.Infinite
            running: true
        }
    }

    ShaderEffect {
        anchors.fill: parent
        property variant maskSource: borderClip
        property variant gradientSource: gradientDisc
        fragmentShader: "qrc:/shaders/bordermask.frag.qsb"
        visible: false
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.width: root.borderWidth
        border.color: root.color1
        opacity: 0.4
        visible: true
    }

    Item {
        id: glowContainer
        anchors.fill: parent
        opacity: root.breathing ? breathAnim.value : 0.6

        NumberAnimation on opacity {
            id: breathAnim
            from: 0.2
            to: 0.7
            duration: 2500
            easing.type: Easing.InOutSine
            loops: Animation.Infinite
            running: root.breathing
        }
    }

    Repeater {
        model: 12

        Rectangle {
            required property int index
            property real angle: index * (Math.PI * 2 / 12) + gradRot.angle * Math.PI / 180
            property real dist: root.radius * 0.9

            width: root.borderWidth * 3
            height: root.borderWidth * 3
            radius: width / 2
            color: {
                var t = index / 12
                if (t < 0.33) return ColorUtils.mix(root.color1, root.color2, t / 0.33)
                else if (t < 0.66) return ColorUtils.mix(root.color2, root.color3, (t - 0.33) / 0.33)
                else return ColorUtils.mix(root.color3, root.color1, (t - 0.66) / 0.34)
            }
            opacity: 0.8

            x: root.width / 2 + Math.cos(angle) * dist - width / 2
            y: root.height / 2 + Math.sin(angle) * dist - height / 2

            NumberAnimation on opacity {
                from: 0.3
                to: 1.0
                duration: 800 + index * 100
                easing.type: Easing.InOutSine
                loops: Animation.Infinite
                running: true
            }
        }
    }
}
