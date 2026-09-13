# END5

My personal Hyprland + Quickshell desktop setup, forked from [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland).

## What's included

- **Quickshell** (`end4-pC`) — Material Design 3 desktop shell
  - Dynamic Island with wallpaper background
  - Left sidebar bar + auto-hide
  - Keep awake (kills hypridle properly)
  - Wallpapers, AI chat, notifications, OSD
  - All 4 bar styles: Hug, Float, Islands, M3
- **Hyprland** config with custom keybinds
- **Hypridle** — 5min lock, 10min DPMS off, 15min suspend

## Requirements

Arch Linux (or Arch-based) with:

```bash
# Core
sudo pacman -S --needed hyprland quickshell hyprlock hypridle hyprpicker \
    xdg-desktop-portal-hyprland ydotool playerctl brightnessctl \
    cliphist fuzzel curl jq bc

# AUR
yay -S --needed wlogout python-material-you-colors
```

## Install

```bash
git clone https://github.com/AsifXdroid/END5.git
cd END5
chmod +x install.sh
./install.sh
```

The installer will:
1. Backup existing configs to `~/.config/backup/END5-<date>/`
2. Copy quickshell config to `~/.config/quickshell/end4-pC/`
3. Copy hyprland config to `~/.config/hypr/`
4. Skip `hypr/custom/` if it already exists (your personal overrides)

## Keybinds

| Key | Action |
|-----|--------|
| Super+Q | Close window |
| Super+Shift+Q | Kill stuck app |
| Super+C | Telegram |
| Super+M | Toggle mic |
| Super+V | Clipboard history |
| Super+R | App launcher |
| Super+E | File manager |
| Super+T | Terminal |

## Customization

- Quickshell settings: `Super+.` or click the pill
- Hyprland custom overrides: `~/.config/hypr/custom/`
- Bar style: Settings → Bar → Style
- Dynamic Island: Settings → Bar → Dynamic pill

## Credits

- [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) — Original illogical-impulse config
- [Quickshell](https://quickshell.outfoxxed.me/) — QML shell framework
