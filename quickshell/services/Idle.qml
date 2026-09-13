pragma Singleton
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Singleton {
    id: root

    property alias inhibit: idleInhibitor.enabled
    inhibit: false

    property var systemdInhibitProc: null

    Connections {
        target: Persistent
        function onReadyChanged() {
            root.inhibit = Persistent.states.idle.inhibit;
        }
    }

    function toggleInhibit(active = null) {
        if (active !== null) {
            root.inhibit = active;
        } else {
            root.inhibit = !root.inhibit;
        }
        Persistent.states.idle.inhibit = root.inhibit;

        // Also inhibit via systemd to prevent hypridle from locking
        if (root.inhibit) {
            systemdInhibitProc = systemdInhibitProcComponent.createObject(root);
        } else if (systemdInhibitProc) {
            systemdInhibitProc.kill();
            systemdInhibitProc = null;
        }
    }

    Component {
        id: systemdInhibitProcComponent
        Process {
            command: ["systemd-inhibit", "--what=idle", "--who=quickshell", "--why=Keep system awake", "sleep", "infinity"]
            running: true
        }
    }

    IdleInhibitor {
        id: idleInhibitor
        window: PanelWindow {
            implicitWidth: 0
            implicitHeight: 0
            color: "transparent"
            anchors {
                right: true
                bottom: true
            }
            mask: Region {
                item: null
            }
        }
    }
}