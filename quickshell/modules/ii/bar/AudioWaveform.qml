import QtQuick
import qs.modules.common

Item {
    id: root
    property real amplitude: 0.5
    property int barCount: 5
    property real barWidth: 2
    property real barSpacing: 2
    property color barColor: Appearance.colors.colPrimary

    implicitWidth: barCount * (barWidth + barSpacing) - barSpacing
    implicitHeight: 16

    Repeater {
        model: root.barCount

        Rectangle {
            id: bar
            required property int index
            x: index * (root.barWidth + root.barSpacing)
            width: root.barWidth
            height: 4
            radius: root.barWidth / 2
            color: root.barColor
            anchors.verticalCenter: parent.verticalCenter

            SequentialAnimation {
                id: anim
                running: true
                loops: Animation.Infinite
                NumberAnimation {
                    target: bar
                    property: "height"
                    from: 4
                    to: Math.max(4, root.height * root.amplitude * (0.5 + 0.5 * Math.sin(bar.index * 1.2)))
                    duration: 300 + bar.index * 80
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    target: bar
                    property: "height"
                    to: 4
                    duration: 300 + bar.index * 80
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
}
