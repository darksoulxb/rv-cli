#!/usr/bin/env bash
# Run this on an Arch or Debian machine to build the .deb
# Requires: dpkg-deb (usually pre-installed on Debian/Ubuntu)
#           On Arch: sudo pacman -S dpkg

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEB_ROOT="$SCRIPT_DIR/../debian/rv-cli"

echo "[rv] Setting permissions..."
chmod 755 "$DEB_ROOT/DEBIAN/postinst"
chmod 755 "$DEB_ROOT/DEBIAN/prerm"
chmod 755 "$DEB_ROOT/usr/bin/rv"

echo "[rv] Building .deb package..."
dpkg-deb --build "$DEB_ROOT" rv-cli_0.1.0_all.deb

echo "[rv] Done: rv-cli_0.1.0_all.deb"
echo ""
echo "Install with:"
echo "  sudo dpkg -i rv-cli_0.1.0_all.deb"
echo "  sudo apt-get install -f   # fix any missing deps"
