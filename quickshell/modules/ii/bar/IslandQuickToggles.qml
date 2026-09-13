import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.ii.sidebarRight.quickToggles
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    property real contentWidth: 410
    implicitWidth: contentWidth
    implicitHeight: panel.implicitHeight + header.implicitHeight + 24

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 8
        spacing: 10

        RowLayout {
            id: header
            Layout.fillWidth: true
            spacing: 8

            MaterialSymbol {
                text: "search"
                iconSize: Appearance.font.pixelSize.normal
                color: Appearance.colors.colOnLayer1
            }
            MaterialTextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: Translation.tr("Search")
                onAccepted: {
                    GlobalStates.searchOpen = true
                    GlobalStates.showIslandLauncher = false
                }
            }
        }

        AndroidQuickPanel {
            id: panel
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            onOpenAudioOutputDialog: {
                GlobalStates.sidebarRightOpen = true
            }
            onOpenAudioInputDialog: {
                GlobalStates.sidebarRightOpen = true
            }
            onOpenBluetoothDialog: {
                GlobalStates.sidebarRightOpen = true
            }
            onOpenNightLightDialog: {
                GlobalStates.sidebarRightOpen = true
            }
            onOpenWifiDialog: {
                GlobalStates.sidebarRightOpen = true
            }
        }
    }
}