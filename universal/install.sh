#!/usr/bin/env bash
# ============================================================
#  rv-cli — Universal Linux Installer
#  https://github.com/darksoulxb/rv-cli
#  Supports: Arch, Debian/Ubuntu, Fedora, openSUSE, Alpine,
#            Void, Gentoo, NixOS, and any distro with pip3
# ============================================================

set -e

VERSION="0.1.0"
REPO="https://github.com/darksoulxb/rv-cli"
TARBALL="https://github.com/darksoulxb/rv-cli/archive/refs/tags/v${VERSION}.tar.gz"
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
RESET="\033[0m"

log()    { echo -e "${BOLD}${GREEN}[rv]${RESET} $*"; }
warn()   { echo -e "${BOLD}${YELLOW}[rv]${RESET} $*"; }
err()    { echo -e "${BOLD}${RED}[rv] ERROR:${RESET} $*"; exit 1; }
header() { echo -e "\n${CYAN}${BOLD}$*${RESET}\n"; }

# ── Detect distro ────────────────────────────────────────────
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="${ID}"
        DISTRO_LIKE="${ID_LIKE:-}"
    elif command -v lsb_release &>/dev/null; then
        DISTRO_ID=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    else
        DISTRO_ID="unknown"
    fi
}

# ── Install system Python deps per distro ────────────────────
install_system_deps() {
    case "$DISTRO_ID" in
        arch|manjaro|endeavouros|garuda)
            log "Detected Arch-based distro"
            sudo pacman -Sy --noconfirm --needed python python-pip python-typer python-platformdirs python-rich python-click
            ;;
        debian|ubuntu|linuxmint|pop|elementary|kali|parrot|raspbian)
            log "Detected Debian/Ubuntu-based distro"
            sudo apt-get update -qq
            sudo apt-get install -y python3 python3-pip python3-venv
            ;;
        fedora)
            log "Detected Fedora"
            sudo dnf install -y python3 python3-pip python3-typer python3-platformdirs python3-rich python3-click
            ;;
        rhel|centos|almalinux|rocky)
            log "Detected RHEL-based distro"
            sudo dnf install -y python3 python3-pip
            ;;
        opensuse*|suse)
            log "Detected openSUSE"
            sudo zypper install -y python3 python3-pip python3-typer python3-platformdirs
            ;;
        alpine)
            log "Detected Alpine Linux"
            sudo apk add --no-cache python3 py3-pip
            ;;
        void)
            log "Detected Void Linux"
            sudo xbps-install -Sy python3 python3-pip
            ;;
        gentoo)
            log "Detected Gentoo"
            sudo emerge dev-lang/python dev-python/pip
            ;;
        nixos)
            warn "NixOS detected. Use nix-env or add to configuration.nix instead:"
            echo "  nix-env -iA nixpkgs.python3Packages.typer nixpkgs.python3Packages.platformdirs"
            warn "Attempting pip install anyway..."
            ;;
        *)
            # fallback — check ID_LIKE
            if echo "$DISTRO_LIKE" | grep -qi "arch"; then
                sudo pacman -Sy --noconfirm --needed python python-pip
            elif echo "$DISTRO_LIKE" | grep -qi "debian\|ubuntu"; then
                sudo apt-get update -qq && sudo apt-get install -y python3 python3-pip
            elif echo "$DISTRO_LIKE" | grep -qi "fedora\|rhel"; then
                sudo dnf install -y python3 python3-pip
            else
                warn "Unknown distro '$DISTRO_ID'. Skipping system deps — relying on pip."
            fi
            ;;
    esac
}

# ── Check Python version ──────────────────────────────────────
check_python() {
    if ! command -v python3 &>/dev/null; then
        err "python3 not found. Install Python 3.10+ and re-run."
    fi
    PY_VER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    PY_MAJOR=$(echo "$PY_VER" | cut -d. -f1)
    PY_MINOR=$(echo "$PY_VER" | cut -d. -f2)
    if [ "$PY_MAJOR" -lt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 10 ]; }; then
        err "Python 3.10+ required, found $PY_VER"
    fi
    log "Python $PY_VER OK"
}

# ── Install rv-cli via pip ────────────────────────────────────
install_pip() {
    log "Installing rv-cli via pip..."
    # Try normal pip first, fall back to --break-system-packages (PEP 668 distros)
    if pip3 install "git+${REPO}.git" --quiet 2>/dev/null; then
        log "pip install succeeded"
    elif pip3 install "git+${REPO}.git" --quiet --break-system-packages 2>/dev/null; then
        log "pip install (--break-system-packages) succeeded"
    else
        warn "pip install failed, trying with --user flag..."
        pip3 install "git+${REPO}.git" --user --quiet || \
            pip3 install "git+${REPO}.git" --user --quiet --break-system-packages || \
            err "pip install failed. Check your internet connection and try manually:\n  pip3 install git+${REPO}.git"
    fi
}

# ── Verify PATH for --user installs ──────────────────────────
fix_path() {
    USER_BIN="$HOME/.local/bin"
    if ! command -v rv &>/dev/null; then
        if [ -f "$USER_BIN/rv" ]; then
            warn "'rv' not in PATH. Add this to your shell config:"
            echo ""
            echo "  # ~/.bashrc or ~/.zshrc or ~/.config/fish/config.fish"
            echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
            echo ""
            warn "Then run: source ~/.bashrc  (or restart terminal)"
        fi
    fi
}

# ── Uninstall ─────────────────────────────────────────────────
uninstall() {
    header "Uninstalling rv-cli..."
    pip3 uninstall rv-cli rv_cli -y 2>/dev/null || \
        pip3 uninstall rv-cli rv_cli -y --break-system-packages 2>/dev/null || true
    log "rv-cli removed."
    exit 0
}

# ── Main ──────────────────────────────────────────────────────
main() {
    header "rv-cli v${VERSION} — Universal Installer"
    log "Source: ${REPO}"

    # Handle flags
    case "${1:-}" in
        --uninstall|-u) uninstall ;;
        --help|-h)
            echo "Usage: bash install.sh [--uninstall]"
            echo ""
            echo "  (no args)    Install rv-cli"
            echo "  --uninstall  Remove rv-cli"
            exit 0
            ;;
    esac

    detect_distro
    log "Distro: ${DISTRO_ID}"
    check_python
    install_system_deps
    install_pip
    fix_path

    echo ""
    log "✓ rv-cli installed successfully!"
    echo ""
    echo -e "  ${BOLD}Get started:${RESET}"
    echo -e "    ${CYAN}rv --help${RESET}"
    echo -e "    ${CYAN}rv add deploy 'git push origin main'${RESET}"
    echo -e "    ${CYAN}rv deploy${RESET}"
    echo ""
    echo -e "  ${BOLD}Repo:${RESET} ${REPO}"
    echo ""
}

main "$@"
