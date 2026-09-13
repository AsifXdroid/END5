import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Scope {
    Variants {
        model: {
            const screens = Quickshell.screens;
            const list = Config.options.bar.screenList;
            if (!list || list.length === 0)
                return screens;
            return screens.filter(screen => list.includes(screen.name));
        }
        LazyLoader {
            id: diskLoader
            active: GlobalStates.islandActive && GlobalStates.barOpen
                && !GlobalStates.screenLocked && GlobalStates.islandMediaActive
            required property ShellScreen modelData
            component: PanelWindow {
                id: diskWindow
                screen: diskLoader.modelData

                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                exclusiveZone: 0
                WlrLayershell.namespace: "quickshell:island-disk"
                WlrLayershell.layer: WlrLayer.Overlay

                readonly property real diskSize: 52
                readonly property real plateW: 300
                readonly property real plateH: 56
                readonly property real plateR: 20
                readonly property real gap: 12

                readonly property var player: MprisController.activePlayer
                readonly property bool playing: player?.isPlaying ?? false
                readonly property string artUrl: player?.trackArtUrl ?? ""
                readonly property bool hasFileArt: artUrl.startsWith("file://")

                anchors {
                    top: true
                    left: true
                }
                margins {
                    top: 0
                    left: (diskWindow.screen.width + GlobalStates.islandCapsuleWidth) / 2 + gap
                }

                readonly property AnimatedValue morphW: AnimatedValue {
                    target: diskRoot.expanded ? diskWindow.plateW : diskWindow.diskSize
                    growMs: 320
                    growCurve: Appearance.animationCurves.expressiveFastSpatial
                    shrinkMs: 280
                    shrinkCurve: Appearance.animationCurves.emphasizedDecel
                }
                readonly property AnimatedValue morphH: AnimatedValue {
                    target: diskRoot.expanded ? diskWindow.plateH : diskWindow.diskSize
                    growMs: 320
                    growCurve: Appearance.animationCurves.expressiveFastSpatial
                    shrinkMs: 280
                    shrinkCurve: Appearance.animationCurves.emphasizedDecel
                }
                readonly property AnimatedValue morphR: AnimatedValue {
                    target: diskRoot.expanded ? diskWindow.plateR : diskWindow.diskSize / 2
                    growMs: 320
                    growCurve: Appearance.animationCurves.expressiveFastSpatial
                    shrinkMs: 280
                    shrinkCurve: Appearance.animationCurves.emphasizedDecel
                }
                readonly property AnimatedValue morphContent: AnimatedValue {
                    target: diskRoot.expanded ? 1 : 0
                    growMs: 340
                    growCurve: Appearance.animation.elementMoveEnter.bezierCurve
                    shrinkMs: 160
                    shrinkCurve: Appearance.animation.elementMoveExit.bezierCurve
                }

                implicitWidth: diskWindow.morphW.value
                implicitHeight: diskWindow.morphH.value

                function lerp(a, b, t) { return a + (b - a) * t }
                function capsuleColor() {
                    return Config.options.bar.followFrameColor
                        ? Appearance.getColorFromName(Config.options.bar.frameColor)
                        : Appearance.colors.colLayer0
                }

                Item {
                    id: diskRoot
                    anchors.fill: parent
                    property bool expanded: false

                    Rectangle {
                        id: capsule
                        anchors.fill: parent
                        radius: Math.min(diskWindow.morphR.value, parent.height / 2)
                        color: diskWindow.capsuleColor()
                        border.width: 1
                        border.color: Appearance.colors.colLayer0Border
                        clip: true
                    }

                    Item {
                        id: artSpin
                        width: 40
                        height: 40
                        x: Math.round(diskWindow.lerp(6, 7, diskWindow.morphContent.value))
                        y: Math.round(diskWindow.lerp(6, 14, diskWindow.morphContent.value))
                        scale: 1 - 0.3 * diskWindow.morphContent.value
                        opacity: 1 - diskWindow.morphContent.value
                        visible: opacity > 0.01

                        NumberAnimation on rotation {
                            from: 0
                            to: 360
                            duration: 7000
                            loops: Animation.Infinite
                            running: diskWindow.playing && !diskRoot.expanded
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            clip: true
                            color: "transparent"

                            StyledImage {
                                anchors.fill: parent
                                source: diskWindow.hasFileArt ? diskWindow.artUrl : ""
                                fillMode: Image.PreserveAspectCrop
                                visible: diskWindow.hasFileArt
                            }

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: diskWindow.playing ? "graphic_eq" : "music_note"
                                iconSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnSecondaryContainer
                                visible: !diskWindow.hasFileArt
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: Appearance.colors.colScrim
                            opacity: diskWindow.playing ? 0 : 0.45
                            visible: opacity > 0.01

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "pause"
                                iconSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnLayer1
                            }
                        }
                    }

                    Item {
                        id: plate
                        anchors.fill: parent
                        opacity: diskWindow.morphContent.value
                        scale: 0.94 + 0.06 * diskWindow.morphContent.value
                        transformOrigin: Item.Left
                        enabled: opacity > 0.5
                        visible: opacity > 0.01

                        IslandMedia {
                            anchors.centerIn: parent
                            collapseOnTap: true
                            onTapped: diskRoot.expanded = false
                        }
                    }

                    Rectangle {
                        anchors.centerIn: artSpin
                        width: artSpin.width
                        height: artSpin.height
                        radius: width / 2
                        color: "transparent"
                        visible: !diskRoot.expanded

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: !diskRoot.expanded && diskWindow.morphContent.value < 0.5
                            onClicked: diskRoot.expanded = true
                        }
                    }
                }
            }
        }
    }
}