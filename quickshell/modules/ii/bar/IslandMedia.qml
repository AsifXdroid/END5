import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import qs
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Item {
    id: root
    readonly property MprisPlayer player: MprisController.activePlayer
    property bool collapseOnTap: false
    signal tapped()

    property string artDownloadLocation: Directories.coverArt
    property string artFileName: Qt.md5(player?.trackArtUrl ?? "")
    property string artFilePath: `${artDownloadLocation}/${artFileName}`
    property bool artDownloaded: false
    property string displayedArtFilePath: {
        if (!root.artDownloaded) return ""
        if ((player?.trackArtUrl ?? "").startsWith("file://")) return player?.trackArtUrl
        return Qt.resolvedUrl(artFilePath)
    }

    onArtFilePathChanged: {
        if (!player?.trackArtUrl || player?.trackArtUrl.length === 0) {
            root.artDownloaded = (player?.trackArtUrl ?? "").startsWith("file://")
            return
        }
        if (player?.trackArtUrl.startsWith("file://")) {
            root.artDownloaded = true
            return
        }
        artDownloader.targetFile = player?.trackArtUrl
        artDownloader.artFilePath = root.artFilePath
        root.artDownloaded = false
        artDownloader.running = true
    }

    Process {
        id: artDownloader
        property string targetFile: player?.trackArtUrl ?? ""
        property string artFilePath: root.artFilePath
        command: ["bash", "-c",
            `[ -f ${artFilePath} ] || curl -sSL '${targetFile}' -o '${artFilePath}'`]
        onExited: { root.artDownloaded = true }
    }

    Timer {
        running: player?.playbackState == MprisPlaybackState.Playing
        interval: Config.options.resources.updateInterval
        repeat: true
        onTriggered: player.positionChanged()
    }

    implicitWidth: row.implicitWidth + 10
    implicitHeight: row.implicitHeight

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        property bool holdOpenedControls: false
        onPressAndHold: {
            holdOpenedControls = true
            GlobalStates.mediaControlsOpen = !GlobalStates.mediaControlsOpen
        }
        onClicked: {
            if (holdOpenedControls) {
                holdOpenedControls = false
                return
            }
            if (root.collapseOnTap)
                root.tapped()
            else
                GlobalStates.toggleIslandClock()
        }
    }

    RowLayout {
        id: row
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        spacing: 6

        ClippedFilledCircularProgress {
            Layout.alignment: Qt.AlignVCenter
            implicitSize: 32
            lineWidth: 2
            value: player?.length > 0 ? Math.min(1, Math.max(0, (player?.position ?? 0) / player.length)) : 0
            colPrimary: Appearance.colors.colSecondary
            enableAnimation: false

            Item {
                id: artClip
                anchors.centerIn: parent
                width: 28
                height: 28

                Rectangle {
                    id: artGlow
                    anchors.fill: parent
                    radius: artRect.radius
                    color: Appearance.colors.colSecondary
                    visible: root.displayedArtFilePath !== ""

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: Appearance.colors.colSecondary
                        shadowBlur: 0.95
                        shadowOpacity: 0.65
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0
                    }
                }

                Rectangle {
                    id: artRect
                    anchors.fill: parent
                    radius: 14
                    color: Appearance.colors.colSecondaryContainer

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: artRect.width
                            height: artRect.height
                            radius: artRect.radius
                        }
                    }

                    StyledImage {
                        anchors.fill: parent
                        source: root.displayedArtFilePath
                        fillMode: Image.PreserveAspectCrop
                        antialiasing: true
                        sourceSize.width: artRect.width * 2
                        sourceSize.height: artRect.height * 2
                        visible: root.displayedArtFilePath !== ""
                    }

                    MaterialSymbol {
                        anchors.centerIn: parent
                        fill: 1
                        text: player?.isPlaying ? "graphic_eq" : "music_note"
                        iconSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnSecondaryContainer
                        visible: root.displayedArtFilePath === ""
                    }
                }
            }
        }

        ColumnLayout {
            spacing: -3
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.maximumWidth: 170
            Layout.topMargin: 2

            StyledText {
                text: StringUtils.cleanMusicTitle(player?.trackTitle) || Translation.tr("No media")
                font.pixelSize: Appearance.font.pixelSize.smallie
                color: Appearance.colors.colOnLayer1
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            StyledText {
                text: player?.trackArtist?.length > 0
                    ? player.trackArtist
                    : (player?.trackAlbum?.length > 0 ? player.trackAlbum : "")
                visible: text.length > 0
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnSecondaryContainer
                opacity: 0.7
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        RippleButton {
            implicitWidth: 34
            implicitHeight: 26
            buttonRadius: 13
            colBackground: player?.isPlaying ? Appearance.colors.colPrimary : Appearance.colors.colSurfaceContainerLow
            colBackgroundHover: player?.isPlaying ? Appearance.colors.colPrimaryHover : Appearance.colors.colPrimaryContainerHover
            colRipple: player?.isPlaying ? Appearance.colors.colPrimaryActive : Appearance.colors.colPrimaryContainerActive
            downAction: () => player?.togglePlaying()
            contentItem: MaterialSymbol {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                text: player?.isPlaying ? "pause" : "play_arrow"
                iconSize: Appearance.font.pixelSize.large
                fill: 1
                color: player?.isPlaying ? Appearance.colors.colOnPrimary : Appearance.colors.colOnPrimaryContainer
            }
        }

        RippleButton {
            implicitWidth: 24
            implicitHeight: 24
            buttonRadius: 12
            colBackground: "transparent"
            colBackgroundHover: Appearance.colors.colPrimaryContainerHover
            colRipple: Appearance.colors.colPrimaryContainerActive
            downAction: () => player?.next()
            altAction: () => player?.previous()
            contentItem: MaterialSymbol {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                text: "skip_next"
                iconSize: Appearance.font.pixelSize.large
                fill: 1
                color: Appearance.colors.colOnSecondaryContainer
            }
        }
    }
}