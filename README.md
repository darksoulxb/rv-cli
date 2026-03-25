# rv-cli — Packaging & Distribution Guide

**Repo:** https://github.com/darksoulxb/rv-cli  
**Version:** 0.1.0  
**Author:** darksoulxb

---

## What's in this package

```
rv_release/
├── src/                        ← Fixed source (push these to GitHub)
│   ├── rv_cli/
│   │   ├── __init__.py
│   │   ├── main.py             ← Fixed: from rv_cli.storage (was rv.storage)
│   │   ├── storage.py          ← Fixed: from rv_cli.config  (was rv.config)
│   │   └── config.py
│   ├── pyproject.toml          ← Fixed: entry point rv_cli.main:app
│   └── LICENSE
│
├── aur/
│   ├── rv-cli/                 ← Stable AUR package (git tag based)
│   │   ├── PKGBUILD
│   │   └── .SRCINFO
│   └── rv-cli-git/             ← Rolling AUR package (tracks main)
│       ├── PKGBUILD
│       └── .SRCINFO
│
├── debian/
│   ├── build_deb.sh            ← Run to build .deb
│   └── rv-cli/                 ← Debian package tree
│       ├── DEBIAN/
│       │   ├── control
│       │   ├── postinst
│       │   └── prerm
│       └── usr/
│           ├── bin/rv
│           ├── lib/rv-cli/rv_cli/
│           └── share/doc/rv-cli/
│
├── rpm/
│   └── rv-cli.spec             ← RPM spec for Fedora/RHEL/openSUSE
│
└── universal/
    └── install.sh              ← One-liner installer for ANY Linux distro
```

---

## STEP 1 — Fix & push source to GitHub

The original source had broken imports. Copy the fixed files:

```bash
cd /home/nitesh/Documents/python/rv

# Replace with fixed versions from src/ in this package
cp src/rv_cli/main.py     rv_cli/main.py
cp src/rv_cli/storage.py  rv_cli/storage.py
cp src/rv_cli/config.py   rv_cli/config.py
cp src/rv_cli/__init__.py rv_cli/__init__.py
cp src/pyproject.toml     pyproject.toml
cp src/LICENSE            LICENSE

git add rv_cli/ pyproject.toml LICENSE
git commit -m "fix: correct import paths and entry point"
git push origin main
```

Then create the release tag (required for stable AUR + .deb):

```bash
git tag v0.1.0
git push origin v0.1.0
```

---

## STEP 2 — AUR (Arch Linux)

### Push stable package

```bash
mkdir -p ~/aur-packages && cd ~/aur-packages
git clone ssh://aur@aur.archlinux.org/rv-cli.git
cd rv-cli
cp /path/to/rv_release/aur/rv-cli/PKGBUILD .

# Generate real checksum (after pushing tag to GitHub)
updpkgsums

# Regenerate .SRCINFO
makepkg --printsrcinfo > .SRCINFO

# Test locally first
makepkg -si

git add PKGBUILD .SRCINFO
git commit -m "init: rv-cli 0.1.0"
git push
```

### Push git (rolling) package

```bash
cd ~/aur-packages
git clone ssh://aur@aur.archlinux.org/rv-cli-git.git
cd rv-cli-git
cp /path/to/rv_release/aur/rv-cli-git/PKGBUILD .
makepkg --printsrcinfo > .SRCINFO
makepkg -si
git add PKGBUILD .SRCINFO
git commit -m "init: rv-cli-git rolling"
git push
```

Users install with:
```bash
yay -S rv-cli        # stable
yay -S rv-cli-git    # rolling
```

---

## STEP 3 — Debian/Ubuntu .deb

Build the .deb on any machine with `dpkg-deb`:

```bash
cd rv_release/debian
chmod +x build_deb.sh
./build_deb.sh
# Output: rv-cli_0.1.0_all.deb
```

Install:
```bash
sudo dpkg -i rv-cli_0.1.0_all.deb
sudo apt-get install -f    # installs any missing deps
```

---

## STEP 4 — RPM (Fedora / RHEL / openSUSE)

Build on a Fedora/RHEL machine:

```bash
# Install build tools
sudo dnf install rpm-build python3-build python3-installer

# Setup RPM build tree
mkdir -p ~/rpmbuild/{SOURCES,SPECS}
cp rv_release/rpm/rv-cli.spec ~/rpmbuild/SPECS/

# Download source tarball
spectool -g -R ~/rpmbuild/SPECS/rv-cli.spec
# or manually:
wget https://github.com/darksoulxb/rv-cli/archive/refs/tags/v0.1.0.tar.gz \
     -O ~/rpmbuild/SOURCES/v0.1.0.tar.gz

# Build
rpmbuild -bb ~/rpmbuild/SPECS/rv-cli.spec

# Install
sudo rpm -i ~/rpmbuild/RPMS/noarch/rv-cli-0.1.0-1.noarch.rpm
```

---

## STEP 5 — Universal one-liner (any distro)

Host `install.sh` anywhere (GitHub raw, your server, etc.) and users run:

```bash
curl -fsSL https://raw.githubusercontent.com/darksoulxb/rv-cli/main/install.sh | bash
```

Or clone and run locally:
```bash
bash rv_release/universal/install.sh
```

Uninstall:
```bash
bash rv_release/universal/install.sh --uninstall
```

Supports: Arch, Manjaro, Debian, Ubuntu, Fedora, RHEL, openSUSE, Alpine, Void, Gentoo, NixOS, and any distro with pip3.

---

## Quick Reference — install methods by distro

| Distro           | Method                        |
|------------------|-------------------------------|
| Arch / Manjaro   | `yay -S rv-cli`               |
| Debian / Ubuntu  | `dpkg -i rv-cli_0.1.0_all.deb`|
| Fedora / RHEL    | `rpm -i rv-cli-0.1.0.rpm`     |
| openSUSE         | `rpm -i rv-cli-0.1.0.rpm`     |
| Any distro       | `curl ... | bash`             |
| Any distro       | `pip3 install rv-cli`         |
