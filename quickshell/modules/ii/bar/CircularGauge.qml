import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

Item {
    id: root
    property real value: 0
    property string label: ""
    property string icon: ""
    property color accentColor: Appearance.colors.colPrimary
    property real size: 52
    property real lineWidth: 5

    width: size
    height: size

    property real _arcR: size / 2 - lineWidth
    property real _cx: size / 2
    property real _cy: size / 2
    property real _degree: Math.min(1, Math.max(0, value)) * 360

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 0.85)
            strokeWidth: root.lineWidth
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathAngleArc {
                centerX: root._cx
                centerY: root._cy
                radiusX: root._arcR
                radiusY: root._arcR
                startAngle: -90
                sweepAngle: 360
            }
        }

        ShapePath {
            strokeColor: root.accentColor
            strokeWidth: root.lineWidth
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathAngleArc {
                centerX: root._cx
                centerY: root._cy
                radiusX: root._arcR
                radiusY: root._arcR
                startAngle: -90
                sweepAngle: root._degree
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        MaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            text: root.icon
            iconSize: root.size * 0.2
            color: root.accentColor
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: root.size * 0.18
            font.weight: Font.DemiBold
            color: Appearance.colors.colOnLayer1
            text: Math.round(root.value * 100) + "%"
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: root.size * 0.12
            color: Appearance.colors.colOnSurfaceVariant
            text: root.label
        }
    }
}
