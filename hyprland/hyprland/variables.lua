-- Default variables
-- Copy these to ~/.config/hypr/custom/variables.lua to make changes in a dotfiles-update-friendly manner

-- The folder within ~/.config/quickshell containing the config
hl.env("qsConfig", "end4-pC")

-- Apps
-- PULL REQUESTS ADDING MORE WILL NOT BE ACCEPTED, CONFIG FOR YOURSELF
terminal = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole'"
fileManager = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'dolphin' 'thunar' 'nemo' 'nautilus'"
browser = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'firefox' 'zen-browser' 'google-chrome-stable' 'chromium'"
codeEditor = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'nvim' 'kate' 'code' 'codium'"
officeSoftware = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'libreoffice' 'onlyoffice-desktopeditors' 'wps'"
textEditor = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'kate' 'nvim' 'nano'"
volumeMixer = "pavucontrol"
settingsApp = "XDG_CURRENT_DESKTOP=gnome ~/.config/hypr/hyprland/scripts/launch_first_available.sh 'qs -p ~/.config/quickshell/$qsConfig/settings.qml' 'gnome-control-center' 'systemsettings'"
taskManager = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'kitty -1 btop' 'kitty -1 htop' 'gnome-system-monitor'"

workspaceGroupSize = 10
