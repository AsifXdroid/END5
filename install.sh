#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
QUICKSHELL_SRC="$REPO_ROOT/quickshell"
HYPRLAND_SRC="$REPO_ROOT/hyprland"
QUICKSHELL_DEST="$HOME/.config/quickshell/end4-pC"
HYPRLAND_DEST="$HOME/.config/hypr"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[$0]${NC} $1"; }
ok()    { echo -e "${GREEN}[$0]${NC} $1"; }
warn()  { echo -e "${YELLOW}[$0]${NC} $1"; }
err()   { echo -e "${RED}[$0]${NC} $1"; }

backup_dir="$HOME/.config/backup/END5-$(date +%Y%m%d-%H%M%S)"
backed_up=false

backup_if_exists() {
    local src="$1" dest="$2"
    if [[ -e "$dest" ]]; then
        mkdir -p "$backup_dir"
        local rel="${dest#$HOME/.config/}"
        mkdir -p "$backup_dir/$(dirname "$rel")"
        cp -a "$dest" "$backup_dir/$rel"
        backed_up=true
        warn "Backed up: $dest → $backup_dir/$rel"
    fi
}

echo ""
echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     END5 Desktop Setup Installer     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

# ─── Check dependencies ───
info "Checking dependencies..."
MISSING=()
for cmd in quickshell hyprctl hyprlock hypridle ydotool playerctl brightnessctl curl jq bc cliphist fuzzel; do
    if ! command -v "$cmd" &>/dev/null; then
        MISSING+=("$cmd")
    fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    warn "Missing commands: ${MISSING[*]}"
    echo ""
    echo "Install them on Arch Linux:"
    echo "  sudo pacman -S --needed ${MISSING[*]}"
    echo ""
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

# ─── Backup existing configs ───
info "Backing up existing configs..."
backup_if_exists "$QUICKSHELL_DEST" "$QUICKSHELL_DEST"
backup_if_exists "$HYPRLAND_DEST/hypridle.conf" "$HYPRLAND_DEST/hypridle.conf"
backup_if_exists "$HYPRLAND_DEST/hyprlock.conf" "$HYPRLAND_DEST/hyprlock.conf"
# Backup hyprland custom dir (user-specific)
backup_if_exists "$HYPRLAND_DEST/custom" "$HYPRLAND_DEST/custom"

if $backed_up; then
    ok "Backups saved to: $backup_dir"
    echo ""
fi

# ─── Install quickshell config ───
info "Installing quickshell config to $QUICKSHELL_DEST ..."
mkdir -p "$QUICKSHELL_DEST"
rsync -av --delete \
    --exclude='.git/' \
    --exclude='.specify/' \
    --exclude='.github/' \
    --exclude='AGENTS.md' \
    "$QUICKSHELL_SRC/" "$QUICKSHELL_DEST/"
ok "Quickshell config installed"

# ─── Install hyprland config ───
info "Installing hyprland config to $HYPRLAND_DEST ..."
mkdir -p "$HYPRLAND_DEST"

# Copy main hyprland config files
for f in hyprland.conf hypridle.conf hyprlock.conf monitors.lua; do
    if [[ -f "$HYPRLAND_SRC/$f" ]]; then
        cp -a "$HYPRLAND_SRC/$f" "$HYPRLAND_DEST/$f"
    fi
done

# Copy hyprland subdirectories
for d in hyprland hyprlock; do
    if [[ -d "$HYPRLAND_SRC/$d" ]]; then
        rsync -av "$HYPRLAND_SRC/$d/" "$HYPRLAND_DEST/$d/"
    fi
done

# Copy custom config (skip if exists — user-specific)
if [[ ! -d "$HYPRLAND_DEST/custom" ]]; then
    if [[ -d "$HYPRLAND_SRC/custom" ]]; then
        rsync -av "$HYPRLAND_SRC/custom/" "$HYPRLAND_DEST/custom/"
        ok "Custom hyprland config installed"
    fi
else
    warn "Skipping hyprland/custom/ (already exists — user-specific)"
fi

ok "Hyprland config installed"

# ─── Make scripts executable ───
info "Setting script permissions..."
find "$QUICKSHELL_DEST/scripts" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null
find "$HYPRLAND_DEST" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null
ok "Scripts made executable"

# ─── Done ───
echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Setup Complete!             ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo "Quickshell config: $QUICKSHELL_DEST"
echo "Hyprland config:   $HYPRLAND_DEST"
echo ""
echo "To start:"
echo "  1. Log out and back in (or run: hyprctl reload)"
echo "  2. Launch quickshell:  qs -c end4-pC"
echo ""
echo "Keybinds:"
echo "  Super+Q       Close window"
echo "  Super+Shift+Q Kill stuck app"
echo "  Super+M       Toggle mic"
echo "  Super+V       Clipboard history"
echo "  Super+R       App launcher"
echo ""
