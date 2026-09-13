import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    property var layoutModel: []
    implicitWidth: row.implicitWidth
    implicitHeight: Appearance.sizes.baseBarHeight

    function getWidgetUrl(name) {
        if (!name) return "";
        let formattedName = name.charAt(0).toUpperCase() + name.slice(1);
        return Qt.resolvedUrl("./" + formattedName + ".qml");
    }

    function getMirroredForIndex(layout, idx) {
        const prevCount = layout.slice(0, idx).filter(w => w === "visualizer").length
        return prevCount % 2 === 1
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: root.layoutModel
            delegate: islandIdleDelegate
        }

        Component {
            id: islandIdleDelegate
            Loader {
                Layout.alignment: Qt.AlignVCenter
                source: modelData === "clockWidget" ? "" : root.getWidgetUrl(modelData)
                sourceComponent: modelData === "clockWidget" ? compactClockComponent : null
                onLoaded: {
                    if (item && item.hasOwnProperty("mirrored"))
                        item.mirrored = root.getMirroredForIndex(root.layoutModel, index)
                }
            }
        }

        Component {
            id: compactClockComponent
            StyledText {
                text: DateTime.time
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer1
            }
        }
    }
}