Name:           rv-cli
Version:        0.1.0
Release:        1%{?dist}
Summary:        A fast, no-bs command-line shortcut manager
License:        MIT
URL:            https://github.com/darksoulxb/rv-cli
Source0:        https://github.com/darksoulxb/rv-cli/archive/refs/tags/v%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  python3-devel
BuildRequires:  python3-setuptools
BuildRequires:  python3-build
BuildRequires:  python3-installer
BuildRequires:  python3-wheel
Requires:       python3 >= 3.10
Requires:       python3-typer
Requires:       python3-platformdirs
Requires:       python3-rich
Requires:       python3-click

%description
rv-cli is a minimal command-line tool that lets you bookmark shell commands
under short memorable names. Instead of re-typing long build pipelines or
deployment steps, register them once and run them with a single keyword.

Supports sequential (seq) and single-join (single) execution modes.
Data is stored as JSON with atomic writes to prevent corruption.

%prep
%autosetup -n rv-cli-%{version}

%build
%pyproject_wheel

%install
%pyproject_install

%files
%license LICENSE
%doc README.md
%{_bindir}/rv
%{python3_sitelib}/rv_cli/
%{python3_sitelib}/rv_cli-%{version}.dist-info/

%changelog
* 2025 darksoulxb <https://github.com/darksoulxb>
- Initial RPM package release 0.1.0
