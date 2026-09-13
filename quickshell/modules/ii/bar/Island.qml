import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Item {
    id: root
    property var layoutModel: []

    readonly property string mode: GlobalStates.islandMode
    readonly property bool osdMode: root.mode === "osd"
    readonly property bool notifMode: root.mode === "notification"
        && Config.options.island.expandNotifications
    readonly property bool launcherMode: root.mode === "launcher"
        && Config.options.island.enableLauncher
    readonly property bool clockMode: root.mode === "clock"
    readonly property bool wsMode: root.mode === "workspace"

    readonly property real pad: 4
    readonly property real idleMinW: 124
    readonly property real notifH: 60

    readonly property real boxW: root.osdMode ? 250
        : root.notifMode ? 330
        : root.wsMode ? wsMetrics.advanceWidth + 48
        : root.launcherMode ? 400
        : root.clockMode ? 570
        : Math.max(root.idleRowW + root.pad * 2, root.idleMinW)
    readonly property real boxH: root.osdMode ? 40
        : root.notifMode ? root.notifH
        : root.wsMode ? 40
        : root.launcherMode ? (launcherPanel.active && launcherPanel.item
            ? Math.min(launcherPanel.item.implicitHeight + root.pad * 2, 420)
            : 320)
        : root.clockMode ? 435
        : Appearance.sizes.baseBarHeight + root.pad * 2
    readonly property real boxR: root.osdMode ? 20
        : root.notifMode ? root.notifH / 2
        : root.wsMode ? 20
        : root.launcherMode ? 24
        : root.clockMode ? 28
        : box.height / 2

    readonly property real idleRowW: idleRow.implicitWidth

    readonly property var filteredLayoutModel: (root.layoutModel ?? []).filter(w =>
        (w === "workspaces" ? Config.options.island.idleWorkspaces
            : w === "clockWidget" ? Config.options.island.idleClock
            : w === "sysTray" ? Config.options.island.idleTray : true))

    readonly property var notif: Notifications.popupList[0]
    readonly property bool notifHasArt: !!root.notif
        && (!!root.notif.image || !!root.notif.appIcon)

    readonly property real targetBoxHeight: root.boxH
    readonly property real capsuleX: box.x
    readonly property real capsuleY: box.y
    readonly property real capsuleW: box.width
    readonly property real capsuleH: box.height
    readonly property bool morphing: geomW.anim.running
        || geomH.anim.running || geomR.anim.running
    property real shadowOpacity: 0

    AnimatedValue {
        id: geomW
        target: root.boxW
        growMs: 280
        growCurve: Appearance.animationCurves.expressiveFastSpatial
        shrinkMs: 320
        shrinkCurve: Appearance.animationCurves.emphasizedDecel
    }
    AnimatedValue {
        id: geomH
        target: root.boxH
        growMs: 280
        growCurve: Appearance.animationCurves.expressiveFastSpatial
        shrinkMs: 320
        shrinkCurve: Appearance.animationCurves.emphasizedDecel
    }
    AnimatedValue {
        id: geomR
        target: root.boxR
        growMs: 280
        growCurve: Appearance.animationCurves.expressiveFastSpatial
        shrinkMs: 320
        shrinkCurve: Appearance.animationCurves.emphasizedDecel
    }

    AnimatedValue {
        id: osdOp
        target: root.osdMode ? 1 : 0
        growMs: 240
        growCurve: Appearance.animation.elementMoveEnter.bezierCurve
        shrinkMs: 150
        shrinkCurve: Appearance.animation.elementMoveExit.bezierCurve
    }
    AnimatedValue {
        id: notifOp
        target: root.notifMode ? 1 : 0
        growMs: 220
        growCurve: Appearance.animation.elementMoveEnter.bezierCurve
        shrinkMs: 150
        shrinkCurve: Appearance.animation.elementMoveExit.bezierCurve
    }
    AnimatedValue {
        id: clockOp
        target: root.clockMode ? 1 : 0
        growMs: 260
        growCurve: Appearance.animation.elementMoveEnter.bezierCurve
        shrinkMs: 150
        shrinkCurve: Appearance.animation.elementMoveExit.bezierCurve
    }
    AnimatedValue {
        id: clockSc
        target: root.clockMode ? 1 : 0.96
        growMs: 300
        growCurve: Appearance.animation.elementMoveEnter.bezierCurve
        shrinkMs: 150
        shrinkCurve: Appearance.animation.elementMoveExit.bezierCurve
    }
    AnimatedValue {
        id: launcherOp
        target: root.launcherMode ? 1 : 0
        growMs: 240
        growCurve: Appearance.animation.elementMoveEnter.bezierCurve
        shrinkMs: 160
        shrinkCurve: Appearance.animation.elementMoveExit.bezierCurve
    }
    AnimatedValue {
        id: wsOp
        target: root.wsMode ? 1 : 0
        growMs: 200
        growCurve: Appearance.animation.elementMoveEnter.bezierCurve
        shrinkMs: 120
        shrinkCurve: Appearance.animation.elementMoveExit.bezierCurve
    }

    readonly property string wsLabel: GlobalStates.islandWorkspaceId < 0
        ? "Special" : "Workspace " + GlobalStates.islandWorkspaceId

    TextMetrics {
        id: wsMetrics
        font.pixelSize: Appearance.font.pixelSize.small
        font.weight: Font.DemiBold
        text: root.wsLabel
    }

    readonly property int activeWsId: Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1
    property int lastWsId: -999
    onActiveWsIdChanged: {
        if (root.lastWsId === -999) {
            root.lastWsId = root.activeWsId
            return
        }
        if (root.activeWsId === root.lastWsId) return
        const dir = root.activeWsId > root.lastWsId ? "right" : "left"
        root.lastWsId = root.activeWsId
        GlobalStates.flashIslandWorkspace(root.activeWsId, dir)
    }

    Binding {
        target: GlobalStates
        property: "islandCapsuleWidth"
        value: box.width
    }

    StyledRectangularShadow {
        target: box
        opacity: root.shadowOpacity
        visible: opacity > 0.001
    }

    NumberAnimation {
        id: shadowReveal
        target: root
        property: "shadowOpacity"
        to: 1
        duration: 220
        easing.type: Easing.OutQuint
    }

    onMorphingChanged: {
        shadowReveal.stop()
        if (root.morphing)
            root.shadowOpacity = 0
        else
            shadowReveal.restart()
    }
    Component.onCompleted: {
        if (!root.morphing) {
            shadowReveal.restart()
        }
    }

    Rectangle {
        id: box
        x: Math.round((root.width - geomW.value) / 2)
        y: 0
        width: geomW.value
        height: geomH.value
        radius: Math.min(geomR.value, geomH.value / 2)
        color: Config.options.bar.followFrameColor
            ? Appearance.getColorFromName(Config.options.bar.frameColor)
            : Appearance.colors.colLayer0
        border.width: root.clockMode ? 1 : 0
        border.color: root.clockMode ? ColorUtils.transparentize("#f472b6", 0.45) : "transparent"
        clip: true
        scale: root.mode === "idle" ? idlePanel.hoverScale * idlePanel.breathScale : 1.0

        Behavior on scale {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: {
                    if (root.clockMode) return "#1a1a1a"
                    if (root.notifMode) return ColorUtils.mix("#1a1a1a", Appearance.colors.colTertiary, 0.97)
                    return "#1a1a1a"
                }
            }
            GradientStop {
                position: 1.0
                color: {
                    if (root.clockMode) return "#111111"
                    if (root.notifMode) return ColorUtils.mix("#111111", Appearance.colors.colTertiary, 0.95)
                    return "#111111"
                }
            }
        }

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        Rectangle {
            anchors.fill: parent
            radius: box.radius
            color: ColorUtils.transparentize(Appearance.colors.colSurfaceContainer, 0.7)
            visible: root.mode !== "idle"
            opacity: root.mode !== "idle" ? 0.3 : 0

            Behavior on opacity {
                NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
            }
        }

        Item {
            id: rippleContainer
            anchors.fill: parent
            clip: true
            z: 10

            property real rippleProgress: 0

            Rectangle {
                id: ripple1
                anchors.centerIn: parent
                width: 10
                height: 10
                radius: width / 2
                color: "transparent"
                border.width: 1.5
                border.color: ColorUtils.transparentize(Appearance.colors.colPrimary, 0.5)
                opacity: 0
                scale: 1

                NumberAnimation on scale {
                    id: ripple1Anim
                    from: 0.5
                    to: 4.0
                    duration: 800
                    easing.type: Easing.OutQuad
                    running: false
                }
                NumberAnimation on opacity {
                    id: ripple1Fade
                    from: 0.6
                    to: 0.0
                    duration: 800
                    easing.type: Easing.OutQuad
                    running: false
                }
            }

            Rectangle {
                id: ripple2
                anchors.centerIn: parent
                width: 10
                height: 10
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: ColorUtils.transparentize(Appearance.colors.colSecondary, 0.6)
                opacity: 0
                scale: 1

                NumberAnimation on scale {
                    id: ripple2Anim
                    from: 0.3
                    to: 3.0
                    duration: 600
                    easing.type: Easing.OutQuad
                    running: false
                }
                NumberAnimation on opacity {
                    id: ripple2Fade
                    from: 0.4
                    to: 0.0
                    duration: 600
                    easing.type: Easing.OutQuad
                    running: false
                }
            }

            function triggerRipples() {
                ripple1.scale = 0.5
                ripple1.opacity = 0.6
                ripple1Anim.restart()
                ripple1Fade.restart()
                ripple2.scale = 0.3
                ripple2.opacity = 0.4
                ripple2Anim.restart()
                ripple2Fade.restart()
            }
        }

        Repeater {
            id: particles
            model: 0
            z: 11

            Rectangle {
                required property int index
                property real targetX: 0
                property real targetY: 0
                property real speed: 0.5 + Math.random() * 0.5
                property real angle: Math.random() * Math.PI * 2
                property real dist: 40 + Math.random() * 60
                width: 2 + Math.random() * 3
                height: width
                radius: width / 2
                color: Appearance.colors.colPrimary
                opacity: 0

                NumberAnimation on x {
                    id: px
                    duration: 600
                    easing.type: Easing.OutQuad
                    running: false
                }
                NumberAnimation on y {
                    id: py
                    duration: 600
                    easing.type: Easing.OutQuad
                    running: false
                }
                NumberAnimation on opacity {
                    id: po
                    duration: 600
                    easing.type: Easing.OutQuad
                    running: false
                }

                function launch() {
                    var cx = box.width / 2
                    var cy = box.height / 2
                    x = cx - width / 2
                    y = cy - height / 2
                    targetX = cx + Math.cos(angle) * dist - width / 2
                    targetY = cy + Math.sin(angle) * dist - height / 2
                    po.from = 0.7
                    po.to = 0
                    px.from = x; px.to = targetX
                    py.from = y; py.to = targetY
                    po.restart()
                    px.restart()
                    py.restart()
                }
            }

            onCountChanged: {
                if (count > 0) {
                    for (var i = 0; i < count; i++) {
                        var item = itemAt(i)
                        if (item) item.launch()
                    }
                }
            }
        }

        Connections {
            target: root
            function onModeChanged() {
                if (root.mode !== "idle") {
                    rippleContainer.triggerRipples()
                    particles.model = 8
                    resetTimer.start()
                }
            }
        }

        Timer {
            id: resetTimer
            interval: 700
            onTriggered: particles.model = 0
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.notifMode || root.launcherMode || root.clockMode
            onClicked: {
                if (root.notifMode) {
                    Notifications.timeoutAll()
                    GlobalStates.showIslandNotification = false
                }
                if (root.launcherMode)
                    GlobalStates.showIslandLauncher = false
                if (root.clockMode)
                    GlobalStates.showIslandClock = false
            }
        }

        Item {
            id: idlePanel
            anchors.centerIn: parent
            visible: root.mode === "idle" || root.mode === "media"
            implicitWidth: idleRow.implicitWidth
            implicitHeight: idleRow.implicitHeight
            property real hoverScale: 1.0
            property real hoverGlow: 0.0
            property real breathScale: 1.0

            SequentialAnimation {
                id: breathAnim
                running: root.mode === "idle"
                loops: Animation.Infinite
                NumberAnimation {
                    target: idlePanel
                    property: "breathScale"
                    from: 1.0; to: 1.008
                    duration: 2000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    target: idlePanel
                    property: "breathScale"
                    from: 1.008; to: 1.0
                    duration: 2000
                    easing.type: Easing.InOutSine
                }
                onRunningChanged: {
                    if (!running) idlePanel.breathScale = 1.0
                }
            }

            Behavior on hoverScale {
                NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
            }
            Behavior on hoverGlow {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }

            RowLayout {
                id: idleRow
                anchors.centerIn: parent
                spacing: 2

                IslandIdleBar {
                    id: idleBar
                    Layout.alignment: Qt.AlignVCenter
                    layoutModel: root.filteredLayoutModel
                }

                AudioWaveform {
                    id: waveDecor
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 4
                    visible: root.mode === "idle"
                    barCount: 4
                    barWidth: 2
                    barSpacing: 2
                    barColor: Appearance.colors.colPrimary
                    amplitude: 0.6
                    height: 14
                }

                Rectangle {
                    id: chipsDivider
                    visible: Config.options.island.chips.length > 0
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 2
                    Layout.rightMargin: 2
                    width: 1
                    height: 18
                    radius: 1
                    color: ColorUtils.transparentize(Appearance.colors.colOnLayer1, 0.75)
                }

                Loader {
                    active: Config.options.island.chips.length > 0
                    Layout.alignment: Qt.AlignVCenter
                    sourceComponent: IslandStatusChips {}
                }
            }

            MouseArea {
                id: pillInput
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                enabled: !GlobalStates.screenLocked && GlobalStates.barOpen
                onEntered: {
                    idlePanel.hoverScale = 1.02
                    idlePanel.hoverGlow = 1.0
                }
                onExited: {
                    idlePanel.hoverScale = 1.0
                    idlePanel.hoverGlow = 0.0
                }
                onPressed: {
                    idlePanel.hoverScale = 0.97
                }
                onReleased: {
                    idlePanel.hoverScale = 1.02
                }
                onClicked: {
                    if (GlobalStates.islandMode === "notification") {
                        GlobalStates.sidebarRightOpen = true
                        GlobalStates.showIslandNotification = false
                    } else {
                        GlobalStates.toggleIslandClock()
                    }
                }
            }
        }

        Loader {
            id: osdPanel
            anchors.centerIn: parent
            opacity: osdOp.value
            enabled: opacity > 0.5

            sourceComponent: IslandOsd {
                type: GlobalStates.islandOsdType
            }
        }

        Loader {
            id: clockPanel
            anchors.fill: parent
            transformOrigin: Item.Center
            opacity: clockOp.value
            scale: clockSc.value
            enabled: opacity > 0.5

            sourceComponent: IslandClockCapsule {}
        }

        Loader {
            id: launcherPanel
            anchors.fill: parent
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            opacity: launcherOp.value
            enabled: opacity > 0.5

            sourceComponent: IslandQuickToggles {
                contentWidth: box.width - 16
            }
        }

        Item {
            id: notifPanel
            anchors.centerIn: parent
            width: 318
            height: 44
            opacity: notifOp.value
            enabled: opacity > 0.5

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    width: 30
                    height: 30
                    radius: 15
                    color: Appearance.colors.colSecondaryContainer

                    StyledImage {
                        anchors.fill: parent
                        source: {
                            if (!root.notif) return ""
                            if (root.notif.image) return root.notif.image
                            if (root.notif.appIcon)
                                return root.notif.appIcon.startsWith("/")
                                    ? "file://" + root.notif.appIcon
                                    : "image://icon/" + root.notif.appIcon
                            return ""
                        }
                        fillMode: Image.PreserveAspectCrop
                        antialiasing: true
                        visible: status === Image.Ready
                    }

                    MaterialSymbol {
                        anchors.centerIn: parent
                        fill: 1
                        text: "notifications"
                        iconSize: Appearance.font.pixelSize.smallie
                        color: Appearance.colors.colOnSecondaryContainer
                        visible: parent.visible && !root.notifHasArt
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        Layout.fillWidth: true
                        text: root.notif?.summary ?? ""
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        color: Appearance.colors.colOnLayer1
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.notif?.body ?? ""
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        color: Appearance.colors.colOnSecondaryContainer
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        visible: text.length > 0
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: -10
                    visible: (Notifications.popupList.length ?? 0) > 1
                    width: 18
                    height: 18
                    radius: 9
                    color: Appearance.colors.colPrimary

                    Text {
                        anchors.centerIn: parent
                        text: (Notifications.popupList.length - 1)
                        color: Appearance.colors.colOnPrimary
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: Font.DemiBold
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            x: (1 - wsOp.value) * (GlobalStates.islandWorkspaceDirection === "right" ? 24 : -24)
            opacity: wsOp.value
            visible: opacity > 0.01
            text: root.wsLabel
            color: Appearance.colors.colOnLayer1
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.DemiBold
        }
    }

    NeonGlow {
        id: neonGlow
        anchors.fill: box
        radius: box.radius
        baseColor: Appearance.colors.colPrimary
        visible: root.mode === "idle"
        opacity: idlePanel.hoverGlow * 0.8
    }

    FloatingOrbs {
        id: floatingOrbs
        anchors.fill: box
        anchors.margins: 8
        orbCount: 5
        minSize: 3
        maxSize: 6
        orbColor: Appearance.colors.colPrimary
        speed: 3000
        visible: root.mode === "idle"
        opacity: 0.6
    }

    HoloShimmer {
        id: holoShimmer
        anchors.fill: box
        visible: root.mode === "idle"
        intensity: 0.15
        speed: 4000
    }

    Item {
        id: liquidBorder
        anchors.fill: box
        z: 11

        Repeater {
            model: 24

            Rectangle {
                required property int index
                property real angle: index * (Math.PI * 2 / 24) + liquidRot.value * Math.PI / 180
                property real dist: Math.min(box.width, box.height) * 0.48

                width: 4
                height: 4
                radius: 2
                color: {
                    var t = (index / 24 + liquidRot.value / 360) % 1.0
                    if (t < 0.33) return ColorUtils.mix(Appearance.colors.colPrimary, Appearance.colors.colSecondary, t / 0.33)
                    else if (t < 0.66) return ColorUtils.mix(Appearance.colors.colSecondary, Appearance.colors.colTertiary, (t - 0.33) / 0.33)
                    else return ColorUtils.mix(Appearance.colors.colTertiary, Appearance.colors.colPrimary, (t - 0.66) / 0.34)
                }
                opacity: 0.7 + 0.3 * Math.sin(index * 0.5 + liquidRot.value * 0.02)

                x: box.x + box.width / 2 + Math.cos(angle) * dist - width / 2
                y: box.y + box.height / 2 + Math.sin(angle) * dist - height / 2
            }
        }

        NumberAnimation on rotation {
            id: liquidRot
            from: 0
            to: 360
            duration: 6000
            loops: Animation.Infinite
            running: true
        }
    }
}