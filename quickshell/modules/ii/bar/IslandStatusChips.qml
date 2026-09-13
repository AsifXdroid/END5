import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: Appearance.sizes.baseBarHeight

    function chipFile(name) {
        switch (name) {
            case "networkSpeed": return "NetworkSpeed.qml"
            case "battery":      return "BatteryIndicator.qml"
            case "updates":      return "UpdatesCount.qml"
            case "weather":      return "WeatherBar.qml"
            default:             return "NetworkSpeed.qml"
        }
    }

    RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 2

        Repeater {
            model: Config.options.island.chips
            delegate: RowLayout {
                id: chip
                required property int index
                required property string modelData
                spacing: 2

                Rectangle {
                    id: separator
                    visible: chip.index > 0
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 18
                    radius: 1
                    color: Appearance.colors.colOutlineVariant
                    opacity: 0.5
                }

                Loader {
                    Layout.alignment: Qt.AlignVCenter
                    source: root.chipFile(chip.modelData)
                }
            }
        }
    }
}