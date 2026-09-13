import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    Variants {
        model: {
            const screens = Quickshell.screens;
            const list = Config.options.bar.screenList;
            if (!list || list.length === 0)
                return screens;
            return screens.filter(screen => list.includes(screen.name));
        }
        LazyLoader {
            id: popoffLoader
            active: GlobalStates.islandActive
                && GlobalStates.barOpen
                && !GlobalStates.screenLocked
            required property ShellScreen modelData
            component: PanelWindow {
                id: popoffWindow
                screen: popoffLoader.modelData

                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                exclusiveZone: 0
                WlrLayershell.namespace: "quickshell:island-popoffs"
                WlrLayershell.layer: WlrLayer.Overlay

                readonly property bool chipsEnabled: GlobalStates.islandMode === "idle"
                    || GlobalStates.islandMode === "media"
                property bool baselineReady: false
                property var expireAt: ({})
                property real batteryPrev: -1
                property bool chargerPrev: false
property int updatesPrev: -1
        property string weatherPrev: ""
        property bool weatherSeen: false
        property real lastWeatherSpawn: 0

                anchors {
                    top: true
                    left: true
                }
                margins {
                    top: 0
                    left: (popoffWindow.screen.width + GlobalStates.islandCapsuleWidth) / 2 + 10
                }

                implicitWidth: chipsRow.visible ? chipsRow.width + 16 : 0
                implicitHeight: chipsRow.visible ? chipsRow.height + 10 : 0

                Behavior on implicitWidth {
                    animation: Appearance.animation.elementMoveSmall.numberAnimation.createObject(this)
                }
                Behavior on implicitHeight {
                    animation: Appearance.animation.elementMoveSmall.numberAnimation.createObject(this)
                }

                function chipFile(type) {
                    switch (type) {
                        case "networkSpeed": return "NetworkSpeed.qml"
                        case "battery":      return "BatteryIndicator.qml"
                        case "updates":      return "UpdatesCount.qml"
                        case "weather":      return "WeatherBar.qml"
                        default:             return "NetworkSpeed.qml"
                    }
                }

                function chipTypes() {
                    return Config.options.island.chips || []
                }

                function hasChip(type) {
                    return chipTypes().includes(type)
                }

                function indexOfChip(type) {
                    for (let i = 0; i < chipsModel.count; i++)
                        if (chipsModel.get(i).type === type)
                            return i
                    return -1
                }

                function spawn(type, ms) {
                    if (!popoffWindow.chipsEnabled || !hasChip(type))
                        return
                    const idx = indexOfChip(type)
                    if (idx >= 0) {
                        if (chipsModel.get(idx).retiring)
                            chipsModel.set(idx, { type, retiring: false })
                    } else {
                        chipsModel.append({ type, retiring: false })
                    }
                    popoffWindow.expireAt[type] = Date.now() + ms
                }

                function dismiss(type) {
                    const idx = indexOfChip(type)
                    if (idx < 0) return
                    delete popoffWindow.expireAt[type]
                    const cur = chipsModel.get(idx)
                    if (cur.retiring) return
                    chipsModel.set(idx, { type, retiring: true })
                    retireTimer.start()
                }

function resetBaselines() {
    popoffWindow.batteryPrev = Battery.percentage
    popoffWindow.chargerPrev = Battery.isCharging
    popoffWindow.updatesPrev = Updates.checking ? -1 : Updates.count
    const temp = Weather.data?.temp ?? ""
    if (temp.length > 0 && temp !== "--°")
        popoffWindow.weatherPrev = temp
    popoffWindow.baselineReady = true
}

function scan() {
    if (!popoffWindow.baselineReady) {
        popoffWindow.resetBaselines()
        return
    }

    for (let i = chipsModel.count - 1; i >= 0; i--) {
        const type = chipsModel.get(i).type
        const cur = chipsModel.get(i)
        if ((popoffWindow.expireAt[type] ?? 0) < Date.now() && !cur.retiring) {
            delete popoffWindow.expireAt[type]
            chipsModel.set(i, { type, retiring: true })
            retireTimer.start()
        }
    }

    if (hasChip("battery")) {
        const percentage = Battery.percentage
        const charging = Battery.isCharging
        if (charging !== popoffWindow.chargerPrev)
            spawn("battery", 4500)
        else if (!charging && percentage < popoffWindow.batteryPrev - 0.02)
            spawn("battery", 4000)
        popoffWindow.batteryPrev = percentage
        popoffWindow.chargerPrev = charging
    }

    if (hasChip("updates") && !Updates.checking) {
        const count = Updates.count
        if (count > 0 && popoffWindow.updatesPrev >= 0 && count !== popoffWindow.updatesPrev)
            spawn("updates", 7000)
        popoffWindow.updatesPrev = count
    }

    if (hasChip("weather")) {
        const temp = Weather.data?.temp ?? ""
        if (temp.length > 0 && temp !== "--°") {
            if (popoffWindow.weatherSeen) {
                if (temp !== popoffWindow.weatherPrev
                        && Date.now() - (popoffWindow.lastWeatherSpawn ?? 0) > 60000) {
                    spawn("weather", 5000)
                    popoffWindow.lastWeatherSpawn = Date.now()
                }
                popoffWindow.weatherPrev = temp
            } else {
                popoffWindow.weatherSeen = true
                popoffWindow.weatherPrev = temp
            }
        }
    }

    if (hasChip("networkSpeed") && netMonitor.item) {
        const rate = Math.max(
            netMonitor.item.downloadBytesPerSecond,
            netMonitor.item.uploadBytesPerSecond
        )
        if (rate > (Config.options.island.popoffNetworkThreshold ?? 150) * 1024)
            spawn("networkSpeed", 2500)
    }
}

onChipsEnabledChanged: {
    if (!popoffWindow.chipsEnabled) {
        chipsModel.clear()
        popoffWindow.expireAt = {}
        popoffWindow.baselineReady = false
    }
}

Timer {
                    interval: 500
                    repeat: true
                    running: popoffWindow.chipsEnabled
                    onTriggered: popoffWindow.scan()
                }

                Timer {
                    id: retireTimer
                    interval: 170
                    repeat: false
                    onTriggered: {
                        for (let i = chipsModel.count - 1; i >= 0; i--) {
                            if (chipsModel.get(i).retiring)
                                chipsModel.remove(i)
                        }
                    }
                }

                Connections {
                    target: GlobalStates
                    function onPopoffRequested(type) {
                        popoffWindow.spawn(type, 3000)
                    }
                }

                ListModel {
                    id: chipsModel
                }

                Loader {
                    id: netMonitor
                    source: "NetworkSpeed.qml"
                    visible: true
                    opacity: 0
                    enabled: false
                    x: -200
                }

                Row {
                    id: chipsRow
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    visible: chipsModel.count > 0

                    Repeater {
                        model: chipsModel
                        delegate: chipComponent
                    }
                }

                Component {
                    id: chipComponent
                    Rectangle {
                        id: chip
                        required property string type
                        required property bool retiring

                        height: Math.max(30, content.implicitHeight + 10)
                        width: content.implicitWidth + 18
                        radius: height / 2
                        color: Config.options.bar.followFrameColor
                            ? Appearance.getColorFromName(Config.options.bar.frameColor)
                            : Appearance.colors.colLayer0
                        border.width: 1
                        border.color: ColorUtils.transparentize(Appearance.colors.colLayer0Border, 0.45)
                        opacity: 0
                        scale: 0.86
                        transformOrigin: Item.Left

                        state: chip.retiring
                            ? "out"
                            : content.status === Loader.Ready ? "in" : ""

                        states: [
                            State {
                                name: "in"
                                PropertyChanges {
                                    target: chip
                                    opacity: 1
                                    scale: 1
                                }
                            },
                            State {
                                name: "out"
                                PropertyChanges {
                                    target: chip
                                    opacity: 0
                                    scale: 0.82
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                to: "in"
                                ParallelAnimation {
                                    NumberAnimation {
                                        properties: "opacity"
                                        duration: 260
                                        easing.type: Appearance.animation.elementMoveEnter.type
                                        easing.bezierCurve: Appearance.animation.elementMoveEnter.bezierCurve
                                    }
                                    NumberAnimation {
                                        properties: "scale"
                                        duration: 260
                                        easing.type: Appearance.animation.elementMoveEnter.type
                                        easing.bezierCurve: Appearance.animation.elementMoveEnter.bezierCurve
                                    }
                                }
                            },
                            Transition {
                                to: "out"
                                ParallelAnimation {
                                    NumberAnimation {
                                        properties: "opacity"
                                        duration: 140
                                        easing.type: Appearance.animation.elementMoveExit.type
                                        easing.bezierCurve: Appearance.animation.elementMoveExit.bezierCurve
                                    }
                                    NumberAnimation {
                                        properties: "scale"
                                        duration: 140
                                        easing.type: Appearance.animation.elementMoveExit.type
                                        easing.bezierCurve: Appearance.animation.elementMoveExit.bezierCurve
                                    }
                                }
                            }
                        ]

                        Loader {
                            id: content
                            anchors.centerIn: parent
                            source: popoffWindow.chipFile(chip.type)
                        }
                    }
                }
            }
        }
    }
}