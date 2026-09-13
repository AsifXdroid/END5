import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: page
    forceWidth: true

    property int editingGoalIndex: -1

    function goTo(term) {
        const t = term.toLowerCase().trim()

        function findTarget(rootItem) {
            for (let i = 0; i < rootItem.children.length; i++) {
                let child = rootItem.children[i]
                if (child.title && child.title.toLowerCase().includes(t)) {
                    return child
                }
            }

            for (let i = 0; i < rootItem.children.length; i++) {
                let found = findTarget(rootItem.children[i])
                if (found) return found
            }
            return null
        }

        let target = findTarget(mainLayout)
        if (target) {
            let pos = target.mapToItem(mainLayout, 0, 0)
            page.contentY = Math.max(0, pos.y - 0)
        }
    }

    function listHas(list, v) {
        return (list ?? []).includes(v)
    }
    function setListItem(list, v, on) {
        let l = [...(list ?? [])]
        if (on && !l.includes(v)) l.push(v)
        if (!on) l = l.filter(x => x !== v)
        return l
    }

    function toggleHas(type) {
        return (Config.options.island.utilityToggles ?? []).some(t => t && t.type === type)
    }
    function setToggle(type, on) {
        let l = [...(Config.options.island.utilityToggles ?? [])]
        if (on && !l.some(t => t && t.type === type)) l.push({ type: type, size: 1 })
        if (!on) l = l.filter(t => !(t && t.type === type))
        Config.options.island.utilityToggles = l
    }

    property var toggleMeta: [
        { type: "network", label: "Wifi", icon: "wifi" },
        { type: "bluetooth", label: "Bluetooth", icon: "bluetooth" },
        { type: "audio", label: "Audio", icon: "volume_up" },
        { type: "mic", label: "Mic", icon: "mic" },
        { type: "darkMode", label: "Dark mode", icon: "dark_mode" },
        { type: "nightLight", label: "Night light", icon: "nightlight" },
        { type: "idleInhibitor", label: "Idle inhibitor", icon: "coffee" },
        { type: "notifications", label: "Notifications", icon: "notifications" },
        { type: "powerProfile", label: "Power profile", icon: "bolt" },
        { type: "easyEffects", label: "EasyEffects", icon: "equalizer" },
        { type: "cloudflareWarp", label: "Cloudflare WARP", icon: "shield" },
        { type: "gameMode", label: "Game mode", icon: "sports_esports" },
        { type: "screenSnip", label: "Screen snip", icon: "screenshot_region" },
        { type: "colorPicker", label: "Color picker", icon: "colorize" },
        { type: "onScreenKeyboard", label: "On-screen keyboard", icon: "keyboard" },
        { type: "musicRecognition", label: "Music recognition", icon: "music_note" },
        { type: "antiFlashbang", label: "Anti-flashbang", icon: "flare" }
    ]

    ColumnLayout {
        id: mainLayout
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 20

        ContentSection {
            icon: "pill"
            title: Translation.tr("Pill")
            GroupedList {
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "pill"
                        text: Translation.tr("Dynamic pill")
                        checked: Config.options.island.enabled
                        onCheckedChanged: { Config.options.island.enabled = checked; }
                    }
                }
            }
            ConfigSelectionArray {
                text: Translation.tr("Interface mode")
                icon: "view_column_2"
                currentValue: !Config.options.island.enabled ? 2 : (Config.options.island.barWithIsland ? 1 : 0)
                onSelected: newValue => {
                    if (newValue === 2) {
                        Config.options.island.enabled = false
                    } else {
                        Config.options.island.enabled = true
                        Config.options.island.barWithIsland = (newValue === 1)
                    }
                }
                options: [
                    { displayName: Translation.tr("Island Only"), icon: "pill", value: 0 },
                    { displayName: Translation.tr("Bar + Island"), icon: "view_column_2", value: 1 },
                    { displayName: Translation.tr("Bar Only"), icon: "block", value: 2 },
                ]
            }
        }

        ContentSection {
            icon: "touch_app"
            title: Translation.tr("Behavior & Placement")
            GroupedList {
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "open_in_new"
                        text: Translation.tr("Always float (never hide behind windows)")
                        checked: Config.options.island.alwaysFloat
                        onCheckedChanged: { Config.options.island.alwaysFloat = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "visibility_off"
                        text: Translation.tr("Auto-hide top bar")
                        checked: Config.options.bar.autoHide.enable
                        onCheckedChanged: { Config.options.bar.autoHide.enable = checked; }
                    }
                }
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "touch_app"
                        text: Translation.tr("Hover to expand")
                        checked: Config.options.island.hoverExpand
                        onCheckedChanged: { Config.options.island.hoverExpand = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "output"
                        text: Translation.tr("Outside-click collapse")
                        checked: Config.options.island.outsideCollapse
                        onCheckedChanged: { Config.options.island.outsideCollapse = checked; }
                    }
                }
            }
        }

        ContentSection {
            icon: "home"
            title: Translation.tr("Page 1: Greeting & Overview Components")
            GroupedList {
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "account_circle"
                        text: Translation.tr("User card header")
                        checked: Config.options.island.homeUsercard
                        onCheckedChanged: { Config.options.island.homeUsercard = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "schedule"
                        text: Translation.tr("Clock and date hero")
                        checked: Config.options.island.homeHero
                        onCheckedChanged: { Config.options.island.homeHero = checked; }
                    }
                }
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "battery_android_frame_full"
                        text: Translation.tr("Battery status badge")
                        checked: Config.options.island.homeBattery
                        onCheckedChanged: { Config.options.island.homeBattery = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "timelapse"
                        text: Translation.tr("Uptime counter")
                        checked: Config.options.island.footUptime
                        onCheckedChanged: { Config.options.island.footUptime = checked; }
                    }
                }
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "memory"
                        text: Translation.tr("CPU monitor gauge")
                        checked: Config.options.island.sysCpu
                        onCheckedChanged: { Config.options.island.sysCpu = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "memory_alt"
                        text: Translation.tr("RAM monitor gauge")
                        checked: Config.options.island.sysRam
                        onCheckedChanged: { Config.options.island.sysRam = checked; }
                    }
                }
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "hard_drive"
                        text: Translation.tr("Disk storage gauge")
                        checked: Config.options.island.sysDisk
                        onCheckedChanged: { Config.options.island.sysDisk = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "thermostat"
                        text: Translation.tr("Temperature gauge")
                        checked: Config.options.island.sysTemp
                        onCheckedChanged: { Config.options.island.sysTemp = checked; }
                    }
                }
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "wallpaper"
                        text: Translation.tr("Wallpaper button")
                        checked: Config.options.island.footWallpaper
                        onCheckedChanged: { Config.options.island.footWallpaper = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "document_scanner"
                        text: Translation.tr("OCR text extract")
                        checked: Config.options.island.footOcr
                        onCheckedChanged: { Config.options.island.footOcr = checked; }
                    }
                }
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "lock"
                        text: Translation.tr("Lock screen button")
                        checked: Config.options.island.footLock
                        onCheckedChanged: { Config.options.island.footLock = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "expand_more"
                        text: Translation.tr("System tray button")
                        checked: Config.options.island.footTray
                        onCheckedChanged: { Config.options.island.footTray = checked; }
                    }
                }
            }
        }

        ContentSection {
            icon: "dashboard_customize"
            title: Translation.tr("Page 2: Media & Apps Components")
            GroupedList {
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "music_note"
                        text: Translation.tr("Media player card")
                        checked: Config.options.island.showMediaCard ?? true
                        onCheckedChanged: { Config.options.island.showMediaCard = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "apps"
                        text: Translation.tr("Quick app launcher tiles")
                        checked: Config.options.island.showQuickApps ?? true
                        onCheckedChanged: { Config.options.island.showQuickApps = checked; }
                    }
                }
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "notifications"
                        text: Translation.tr("Notification center deck")
                        checked: Config.options.island.showNotifications ?? true
                        onCheckedChanged: { Config.options.island.showNotifications = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "repeat"
                        text: Translation.tr("Stay expanded when paused")
                        checked: Config.options.island.autoExpandMedia
                        onCheckedChanged: { Config.options.island.autoExpandMedia = checked; }
                    }
                }
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "play_circle"
                        text: Translation.tr("Expand on media playback")
                        checked: Config.options.island.mediaExpands
                        onCheckedChanged: { Config.options.island.mediaExpands = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "notification_important"
                        text: Translation.tr("Expand on notification")
                        checked: Config.options.island.expandNotifications
                        onCheckedChanged: { Config.options.island.expandNotifications = checked; }
                    }
                }
            }
        }

        ContentSection {
            icon: "check_box"
            title: Translation.tr("Page 3: Productivity & Goals Components")
            GroupedList {
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "checklist"
                        text: Translation.tr("Daily goals checklist")
                        checked: Config.options.island.showDailyGoals ?? true
                        onCheckedChanged: { Config.options.island.showDailyGoals = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "widgets"
                        text: Translation.tr("Quick tools row (Capture, Focus, etc.)")
                        checked: Config.options.island.showQuickTools ?? true
                        onCheckedChanged: { Config.options.island.showQuickTools = checked; }
                    }
                }
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "speed"
                        text: Translation.tr("Hardware telemetry strip")
                        checked: Config.options.island.showHardwareTelemetry ?? true
                        onCheckedChanged: { Config.options.island.showHardwareTelemetry = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "videogame_asset"
                        text: Translation.tr("GPU monitor")
                        checked: Config.options.island.sysGpu
                        onCheckedChanged: { Config.options.island.sysGpu = checked; }
                    }
                }
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "swap_horiz"
                        text: Translation.tr("Zram monitor")
                        checked: Config.options.island.sysZram
                        onCheckedChanged: { Config.options.island.sysZram = checked; }
                    }
                }
            }
        }

        ContentSection {
            icon: "edit_note"
            title: Translation.tr("Manage Daily Goals")

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                // Add Goal Bar
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: Appearance.rounding.normal
                    color: Appearance.colors.colLayer1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 10
                        spacing: 8

                        MaterialSymbol {
                            text: "add_task"
                            iconSize: 20
                            color: Appearance.colors.colPrimary
                        }

                        TextInput {
                            id: goalAddInput
                            Layout.fillWidth: true
                            color: Appearance.colors.colOnLayer1
                            font.pixelSize: Appearance.font.pixelSize.small
                            clip: true
                            selectByMouse: true
                            onAccepted: {
                                if (text.trim().length > 0) {
                                    Todo.addTask(text.trim())
                                    text = ""
                                }
                            }

                            Text {
                                visible: parent.text.length === 0
                                text: Translation.tr("Type a new goal & press Enter to add...")
                                color: Appearance.colors.colOutline
                                font.pixelSize: Appearance.font.pixelSize.small
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle {
                            implicitWidth: addBtnText.implicitWidth + 24
                            implicitHeight: 32
                            radius: Appearance.rounding.small
                            color: Appearance.colors.colPrimary
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                MaterialSymbol {
                                    text: "add"
                                    iconSize: 16
                                    color: Appearance.colors.colOnPrimary
                                }
                                StyledText {
                                    id: addBtnText
                                    text: Translation.tr("Add")
                                    font.weight: Font.DemiBold
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnPrimary
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (goalAddInput.text.trim().length > 0) {
                                        Todo.addTask(goalAddInput.text.trim())
                                        goalAddInput.text = ""
                                    }
                                }
                            }
                        }
                    }
                }

                // Goals List
                Repeater {
                    model: Todo.list

                    delegate: Rectangle {
                        required property int index
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: Appearance.rounding.small
                        color: Appearance.colors.colLayer1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10

                            // Checkbox
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 5
                                color: modelData.done ? Appearance.colors.colPrimary : "transparent"
                                border.width: 1.5
                                border.color: modelData.done ? Appearance.colors.colPrimary : Appearance.colors.colOutline

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    visible: modelData.done
                                    text: "check"
                                    iconSize: 15
                                    color: Appearance.colors.colOnPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Todo.toggleTask(index)
                                }
                            }

                            // Content or Edit Field
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                StyledText {
                                    visible: page.editingGoalIndex !== index
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: modelData.content
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    font.strikeout: modelData.done
                                    color: modelData.done ? Appearance.colors.colOutline : Appearance.colors.colOnLayer1
                                    elide: Text.ElideRight

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onDoubleClicked: {
                                            page.editingGoalIndex = index
                                            settingEditInput.text = modelData.content
                                            settingEditInput.forceActiveFocus()
                                        }
                                    }
                                }

                                TextInput {
                                    id: settingEditInput
                                    visible: page.editingGoalIndex === index
                                    anchors.fill: parent
                                    verticalAlignment: TextInput.AlignVCenter
                                    color: Appearance.colors.colPrimary
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    selectByMouse: true
                                    clip: true
                                    onAccepted: {
                                        if (text.trim().length > 0) {
                                            Todo.editTask(index, text.trim())
                                        }
                                        page.editingGoalIndex = -1
                                    }
                                    Keys.onEscapePressed: {
                                        page.editingGoalIndex = -1
                                    }
                                }
                            }

                            // Save button when editing
                            Rectangle {
                                visible: page.editingGoalIndex === index
                                width: 28
                                height: 28
                                radius: 6
                                color: Appearance.colors.colPrimary
                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "check"
                                    iconSize: 16
                                    color: Appearance.colors.colOnPrimary
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (settingEditInput.text.trim().length > 0) {
                                            Todo.editTask(index, settingEditInput.text.trim())
                                        }
                                        page.editingGoalIndex = -1
                                    }
                                }
                            }

                            // Cancel button when editing
                            Rectangle {
                                visible: page.editingGoalIndex === index
                                width: 28
                                height: 28
                                radius: 6
                                color: Appearance.colors.colLayer2
                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "close"
                                    iconSize: 16
                                    color: Appearance.colors.colOnLayer2
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        page.editingGoalIndex = -1
                                    }
                                }
                            }

                            // Edit pencil
                            MaterialSymbol {
                                visible: page.editingGoalIndex !== index
                                text: "edit"
                                iconSize: 18
                                color: editSettingM.containsMouse ? Appearance.colors.colPrimary : Appearance.colors.colOutline
                                MouseArea {
                                    id: editSettingM
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        page.editingGoalIndex = index
                                        settingEditInput.text = modelData.content
                                        settingEditInput.forceActiveFocus()
                                    }
                                }
                            }

                            // Delete button
                            MaterialSymbol {
                                text: "delete"
                                iconSize: 18
                                color: delSettingM.containsMouse ? Appearance.colors.colError : Appearance.colors.colOutline
                                MouseArea {
                                    id: delSettingM
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Todo.deleteItem(index)
                                }
                            }
                        }
                    }
                }

                StyledText {
                    visible: Todo.list.length === 0
                    text: Translation.tr("No daily goals yet. Use the field above to add goals.")
                    color: Appearance.colors.colOutline
                    font.pixelSize: Appearance.font.pixelSize.small
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        ContentSection {
            icon: "toggle_on"
            title: Translation.tr("Launcher toggles")
            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Repeater {
                    model: page.toggleMeta
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        readonly property bool isFirst: index === 0
                        readonly property bool isLast: index === page.toggleMeta.length - 1
                        Layout.fillWidth: true
                        implicitHeight: sw.implicitHeight + 16
                        color: Appearance.colors.colLayer1
                        topLeftRadius: isFirst ? Appearance.rounding.normal : Appearance.rounding.unsharpenmore
                        topRightRadius: isFirst ? Appearance.rounding.normal : Appearance.rounding.unsharpenmore
                        bottomLeftRadius: isLast ? Appearance.rounding.normal : Appearance.rounding.unsharpenmore
                        bottomRightRadius: isLast ? Appearance.rounding.normal : Appearance.rounding.unsharpenmore
                        ConfigSwitch {
                            id: sw
                            anchors { fill: parent; margins: 8 }
                            buttonIcon: modelData.icon
                            text: Translation.tr(modelData.label)
                            checked: page.toggleHas(modelData.type)
                            onCheckedChanged: { if (page.toggleHas(modelData.type) !== checked) page.setToggle(modelData.type, checked); }
                        }
                    }
                }
            }
        }

        ContentSection {
            icon: "empty_dashboard"
            title: Translation.tr("Idle contents")
            GroupedList {
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "steppers"
                        text: Translation.tr("Workspaces")
                        checked: Config.options.island.idleWorkspaces
                        onCheckedChanged: { Config.options.island.idleWorkspaces = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "schedule"
                        text: Translation.tr("Clock")
                        checked: Config.options.island.idleClock
                        onCheckedChanged: { Config.options.island.idleClock = checked; }
                    }
                }
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "inbox"
                        text: Translation.tr("Tray")
                        checked: Config.options.island.idleTray
                        onCheckedChanged: { Config.options.island.idleTray = checked; }
                    }
                }
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "network_check"
                        text: Translation.tr("Network speed")
                        checked: page.listHas(Config.options.island.chips, "networkSpeed")
                        onCheckedChanged: { Config.options.island.chips = page.setListItem(Config.options.island.chips, "networkSpeed", checked); }
                    }
                    ConfigSwitch {
                        buttonIcon: "battery_android_frame_full"
                        text: Translation.tr("Battery")
                        checked: page.listHas(Config.options.island.chips, "battery")
                        onCheckedChanged: { Config.options.island.chips = page.setListItem(Config.options.island.chips, "battery", checked); }
                    }
                }
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "deployed_code_update"
                        text: Translation.tr("Updates")
                        checked: page.listHas(Config.options.island.chips, "updates")
                        onCheckedChanged: { Config.options.island.chips = page.setListItem(Config.options.island.chips, "updates", checked); }
                    }
                    ConfigSwitch {
                        buttonIcon: "flare"
                        text: Translation.tr("Weather")
                        checked: page.listHas(Config.options.island.chips, "weather")
                        onCheckedChanged: { Config.options.island.chips = page.setListItem(Config.options.island.chips, "weather", checked); }
                    }
                }
            }
        }

        ContentSection {
            icon: "notifications"
            title: Translation.tr("Popups & Launcher")
            GroupedList {
                ConfigRow {
                    ConfigSwitch {
                        buttonIcon: "volume_up"
                        text: Translation.tr("Inline volume/brightness popup")
                        checked: Config.options.island.inlineOsd
                        onCheckedChanged: { Config.options.island.inlineOsd = checked; }
                    }
                    ConfigSwitch {
                        buttonIcon: "apps"
                        text: Translation.tr("Quick toggles panel")
                        checked: Config.options.island.enableLauncher
                        onCheckedChanged: { Config.options.island.enableLauncher = checked; }
                    }
                }
            }
        }
    }
}
