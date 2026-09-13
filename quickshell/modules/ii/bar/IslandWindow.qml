import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Scope {
    Binding {
        target: GlobalStates
        property: "islandLayoutModel"
        value: {
            const trayHasItems = SystemTray.items.values.length > 0
            const layout = Config.options.bar.layouts.middleLayout
            if (trayHasItems) return layout
            return layout.filter(name => name !== "sysTray")
        }
    }

    Variants {
        model: {
            const screens = Quickshell.screens;
            const list = Config.options.bar.screenList;
            if (!list || list.length === 0)
                return screens;
            return screens.filter(screen => list.includes(screen.name));
        }
        LazyLoader {
            id: winLoader
            active: GlobalStates.islandActive && GlobalStates.barOpen && !GlobalStates.screenLocked
            required property ShellScreen modelData
            component: PanelWindow {
                id: root
                screen: winLoader.modelData
                visible: true

                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                exclusiveZone: 0
                WlrLayershell.namespace: "quickshell:island"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: (GlobalStates.showIslandClock || GlobalStates.showIslandLauncher) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

                anchors {
                    top: true
                    left: true
                    right: true
                }
                margins {
                    top: 0
                    left: 0
                    right: 0
                    bottom: 0
                }

                readonly property real requestedWindowHeight: Math.ceil(
                    islandCapsule.targetBoxHeight + 36
                )

                property real retainedWindowHeight: 0
                implicitHeight: Math.max(root.requestedWindowHeight, root.retainedWindowHeight)

                function reconcileWindowHeight() {
                    if (root.requestedWindowHeight >= root.retainedWindowHeight) {
                        shrinkTimer.stop()
                        root.retainedWindowHeight = root.requestedWindowHeight
                    } else {
                        shrinkTimer.restart()
                    }
                }
                onRequestedWindowHeightChanged: root.reconcileWindowHeight()

                Timer {
                    id: shrinkTimer
                    interval: 460
                    repeat: false
                    onTriggered: root.retainedWindowHeight = root.requestedWindowHeight
                }

                property bool hasWin: (HyprlandData.windowList ? HyprlandData.windowList.length : 0) > 0
                property bool autoHideEnabled: Config.options.bar.autoHide.enable
                property bool superShow: false
                property bool hoverExpandedActive: false
                Timer {
                    id: superTimer
                    interval: (Config?.options.bar.autoHide.showWhenPressingSuper.delay ?? 140)
                    repeat: false
                    onTriggered: root.superShow = true
                }
                Timer {
                    id: hoverExpandDelayTimer
                    interval: 350
                    repeat: false
                    onTriggered: {
                        if (!hoverRegion.containsMouse) return
                        if (!Config.options.island.hoverExpand) return
                        if (root.isExpanded) return
                        root.hoverExpandedActive = true
                        const action = Config.options.island.hoverExpandAction
                        if (action === 2) GlobalStates.showIslandLauncher = true
                        else if (action === 1) GlobalStates.showIslandClock = true
                    }
                }
                Timer {
                    id: hoverCollapseDelayTimer
                    interval: 250
                    repeat: false
                    onTriggered: {
                        if (hoverRegion.containsMouse) return
                        if (!root.hoverExpandedActive) return
                        root.hoverExpandedActive = false
                        if (Config.options.island.hoverExpandAction === 2) GlobalStates.showIslandLauncher = false
                        else if (Config.options.island.hoverExpandAction === 1) GlobalStates.showIslandClock = false
                    }
                }
                Connections {
                    target: GlobalStates
                    function onSuperDownChanged() {
                        if (!Config?.options.bar.autoHide.showWhenPressingSuper.enable) return
                        if (GlobalStates.superDown) superTimer.restart()
                        else { superTimer.stop(); root.superShow = false }
                    }
                }
                readonly property bool isExpanded: GlobalStates.islandMode !== "idle"
                readonly property bool mustShow: (Config.options.island.alwaysFloat ?? true) ? true : (!root.autoHideEnabled || !root.hasWin || hoverRegion.containsMouse || root.superShow || root.isExpanded || root.hoverExpandedActive)

                mask: Region {
                    Region {
                        x: 0
                        y: 0
                        width: root.width
                        height: Config.options.bar.autoHide.hoverRegionWidth
                    }
                    Region {
                        x: Math.floor(islandCapsule.capsuleX)
                        y: Math.floor(islandCapsule.capsuleY)
                        width: Math.ceil(islandCapsule.capsuleW)
                        height: Math.ceil(islandCapsule.capsuleH)
                    }
                }

                MouseArea {
                    id: hoverRegion
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    z: 10
                    onEntered: {
                        if (Config.options.island.hoverExpand && !root.isExpanded) {
                            hoverCollapseDelayTimer.stop()
                            hoverExpandDelayTimer.restart()
                        }
                    }
                    onExited: {
                        if (Config.options.island.hoverExpand) {
                            hoverExpandDelayTimer.stop()
                            hoverCollapseDelayTimer.restart()
                        }
                    }
                }

                Island {
                    id: islandCapsule
                    z: 20
                    anchors.fill: parent
                    layoutModel: GlobalStates.islandLayoutModel
                    visible: root.mustShow
                }

                function refreshDismissable() {
                    const collapse = Config.options.island.outsideCollapse
                    const isDrop = collapse && (GlobalStates.islandMode === "notification"
                        || GlobalStates.islandMode === "launcher"
                        || GlobalStates.islandMode === "clock")
                    if (isDrop)
                        GlobalFocusGrab.addDismissable(root)
                    else
                        GlobalFocusGrab.removeDismissable(root)
                }

                Component.onCompleted: {
                    root.retainedWindowHeight = root.requestedWindowHeight
                    root.refreshDismissable()
                }
                Component.onDestruction: {
                    GlobalFocusGrab.removeDismissable(root)
                }

                Connections {
                    target: GlobalStates
                    function onIslandModeChanged() {
                        root.refreshDismissable()
                    }
                }
                Connections {
                    target: Config.options.island
                    function onOutsideCollapseChanged() {
                        root.refreshDismissable()
                    }
                }
                Connections {
                    target: GlobalFocusGrab
                    function onDismissed() {
                        if (GlobalStates.islandMode === "notification") {
                            Notifications.timeoutAll()
                            GlobalStates.showIslandNotification = false
                        }
                        if (GlobalStates.islandMode === "launcher") {
                            GlobalStates.showIslandLauncher = false
                        }
                        if (GlobalStates.islandMode === "clock") {
                            GlobalStates.showIslandClock = false
                        }
                    }
                }
            }
        }
    }
}