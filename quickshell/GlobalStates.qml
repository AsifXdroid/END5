import qs.modules.common
import qs.services
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property bool barOpen: true
    property bool crosshairOpen: false
    property bool sidebarLeftOpen: false
    property bool sidebarRightOpen: false
    property bool mediaControlsOpen: false
    property bool osdBrightnessOpen: false
    property bool settingsOpen: false
    property bool osdVolumeOpen: false
    property bool oskOpen: false
    property bool overlayOpen: false
    property bool overviewOpen: false
    property bool regionSelectorOpen: false
    property bool searchOpen: false
    property bool screenLocked: false
    property bool screenLockContainsCharacters: false
    property bool screenUnlockFailed: false
    property bool screenTranslatorOpen: false
    property bool sessionOpen: false
    property bool superDown: false
    property bool superReleaseMightTrigger: true
    property bool wallpaperSelectorOpen: false
    property bool workspaceShowNumbers: false
    property string settingsPage: ""
    property Item currentPageInstance: null
    property list<real> visualizerPoints: []
    property bool desktopWidgetKeyboardFocus: false
    property bool desktopMenuOpen: false
    property var desktopMenuScreen: null
    property real desktopMenuX: 0
    property real desktopMenuY: 0
    property string wallpaperSelectorTarget: "wallpaper"
    property bool dropShelfOpen: false
    property real dropShelfX: 0
    property real dropShelfY: 0

    // Island router — a multi-function dynamic island centered on the bar.
    // Independent feature: works with any bar style.
    readonly property bool islandActive: Config.options.island.enabled
    readonly property bool islandHasTrack: (MprisController.activePlayer?.trackTitle?.length ?? 0) > 0
    readonly property bool islandMediaActive: Config.options.island.mediaExpands
        && (MprisController.isPlaying || Config.options.island.autoExpandMedia)
        && root.islandHasTrack

    property bool showIslandNotification: false
    property bool showIslandOsd: false
    property bool showIslandWorkspace: false
    property int islandWorkspaceId: 1
    property string islandWorkspaceDirection: "right"
    property bool showIslandLauncher: false
    property bool showIslandClock: false
    property bool showIslandTray: false
    onShowIslandClockChanged: if (!showIslandClock) showIslandTray = false
    property int islandClockPage: 1 // 0=productivity, 1=home, 2=background + media
    function islandClockNav(dir: int): void {
        root.islandClockPage = Math.max(0, Math.min(2, root.islandClockPage + dir))
    }
    property string islandOsdType: "volume"
    property var islandLayoutModel: []
    property real islandCapsuleWidth: 0
    signal popoffRequested(string type)

    readonly property string islandMode: root.islandActive
        ? (root.showIslandNotification ? "notification"
            : root.showIslandOsd ? "osd"
            : root.showIslandWorkspace ? "workspace"
            : root.showIslandLauncher ? "launcher"
            : root.showIslandClock ? "clock"
            : root.islandMediaActive ? "media"
            : "idle")
        : "idle"

    function toggleIslandLauncher() {
        root.showIslandLauncher = !root.showIslandLauncher;
        if (root.showIslandLauncher) {
            root.showIslandNotification = false;
            root.showIslandOsd = false;
            root.showIslandClock = false;
        }
    }

    function toggleIslandClock() {
        root.showIslandClock = !root.showIslandClock;
        if (root.showIslandClock) {
            root.showIslandNotification = false;
            root.showIslandOsd = false;
            root.showIslandLauncher = false;
        }
    }

    Timer {
        id: islandOsdTimer
        interval: Config.options.osd.timeout
        repeat: false
        onTriggered: root.showIslandOsd = false
    }

    Timer {
        id: islandWorkspaceTimer
        interval: 1400
        repeat: false
        onTriggered: root.showIslandWorkspace = false
    }

    function flashIslandWorkspace(id, direction) {
        if (!root.islandActive) return;
        root.islandWorkspaceId = id;
        if (direction) root.islandWorkspaceDirection = direction;
        root.showIslandWorkspace = true;
        islandWorkspaceTimer.restart();
    }

    Timer {
        id: islandNotificationTimer
        interval: Config?.options.notifications.timeout ?? Config.options.notifications.timeout
        repeat: false
        onTriggered: {
            if (Notifications.popupList.length === 0)
                root.showIslandNotification = false;
        }
    }

    function triggerIslandOsd(type) {
        if (!root.islandActive || !Config.options.island.inlineOsd) return;
        if (type) root.islandOsdType = type;
        root.showIslandOsd = true;
        islandOsdTimer.restart();
    }

    Connections {
        target: Notifications
        function onNotify() {
            if (!root.islandActive || !Config.options.island.expandNotifications) return;
            root.showIslandNotification = true;
            islandNotificationTimer.restart();
        }
        function onPopupListChanged() {
            if (Notifications.popupList.length === 0)
                root.showIslandNotification = false;
        }
    }

    Connections {
        target: Audio.sink?.audio ?? null
        function onVolumeChanged() {
            if (!Audio.ready) return;
            root.triggerIslandOsd("volume");
        }
        function onMutedChanged() {
            if (!Audio.ready) return;
            root.triggerIslandOsd("volume");
        }
    }

    Connections {
        target: Brightness
        function onBrightnessChanged() {
            root.triggerIslandOsd("brightness");
        }
    }

    Connections {
        target: Hyprsunset
        function onGammaChangeAttempt() {
            root.triggerIslandOsd("gamma");
        }
    }

    IpcHandler {
        target: "island"
        function toggleLauncher(): void {
            GlobalStates.toggleIslandLauncher()
        }
        function toggleClock(): void {
            GlobalStates.toggleIslandClock()
        }
        function openClock(): void {
            GlobalStates.showIslandClock = true
        }
        function closeClock(): void {
            GlobalStates.showIslandClock = false
        }
        function openLauncher(): void {
            GlobalStates.showIslandLauncher = true
        }
        function closeLauncher(): void {
            GlobalStates.showIslandLauncher = false
        }
        function showOsd(): void {
            GlobalStates.triggerIslandOsd("volume")
        }
        function popoff(chipType: string): void {
            GlobalStates.popoffRequested(chipType)
        }
        function setPage(page: int): void {
            GlobalStates.islandClockPage = Math.max(0, Math.min(2, page))
        }
    }

    readonly property var hotCornerOptions: [
        { displayName: Translation.tr("None"),                  value: "none" },
        { displayName: Translation.tr("Left Sidebar"),           value: "sidebarLeftOpen" },
        { displayName: Translation.tr("Right Sidebar"),          value: "sidebarRightOpen" },
        { displayName: Translation.tr("Overview Launcher"),               value: "overviewOpen" },
        { displayName: Translation.tr("Wallpaper Selector"),     value: "wallpaperSelectorOpen" },
        { displayName: Translation.tr("Media Controls"),         value: "mediaControlsOpen" },
        { displayName: Translation.tr("Overlay"),                value: "overlayOpen" },
        { displayName: Translation.tr("ScreenShot Region"),        value: "regionSelectorOpen" },
        { displayName: Translation.tr("Screen Translator"),      value: "screenTranslatorOpen" },
        { displayName: Translation.tr("On-screen Keyboard"),     value: "oskOpen" },
        { displayName: Translation.tr("Session Menu"),           value: "sessionOpen" }
    ]

    function toggleState(name) {
        if (!name || name === "none") return;
        root[name] = !root[name];
    }
    
    onSidebarRightOpenChanged: {
        if (GlobalStates.sidebarRightOpen) {
            Notifications.timeoutAll();
            Notifications.markAllRead();
        }
    }

    Timer {
        id: barRefreshTimer
        interval: 200
        repeat: false
        onTriggered: {
            root.barOpen = true
        }
    }

    function refreshBar() {
        if (!root.barOpen) return;
        root.barOpen = false
        barRefreshTimer.restart()
    }

    CompositorGlobalShortcut {
        name: "workspaceNumber"
        description: "Hold to show workspace numbers, release to show icons"
        onPressed: { root.superDown = true }
        onReleased: { root.superDown = false }
    }

    IpcHandler {
        target: "background"
        function toggleCenteredWallpaper(): void {
            Config.options.background.centeredWallpaper = !Config.options.background.centeredWallpaper
        }
    }

     CompositorGlobalShortcut {
        name: "centeredWallpaperToggle"
        description: "Toggles centered wallpaper"
        onPressed: {
            Config.options.background.centeredWallpaper = !Config.options.background.centeredWallpaper
        }
    }

    CompositorGlobalShortcut {
        name: "islandToggle"
        description: "Toggles Island clock"
        onPressed: {
            root.toggleIslandClock()
        }
    }

    IpcHandler {
        target: "island"
        function toggle(): void {
            root.toggleIslandClock()
        }
        function open(): void {
            root.showIslandClock = true
        }
        function close(): void {
            root.showIslandClock = false
        }
    }

}
