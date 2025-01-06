#!/bin/sh
# shell created by madhouse

PYTHON_VERSION=$(python -c "import sys; print(sys.version_info.minor)")
ARCHITECTURE=$(uname -m)

case $PYTHON_VERSION in
  13)
    BASE_BRANCH='python-3.13'
    ;;
  12)
    BASE_BRANCH='python-3.12'
    ;;
  9)
    BASE_BRANCH='python-3.9'
    ;;
  *)
    echo "Unsupported Python version: $PYTHON_VERSION"
    exit 1
    ;;
esac

get_chipset_info() {
  if [ -f "/proc/stb/info/chipset" ]; then
    cat /proc/stb/info/chipset
  else
    echo "unknown"
  fi
}

install_dependencies() {
  echo '====================================='
  echo ' Installing necessary dependencies   '
  echo '====================================='
  opkg update
  opkg install wireguard-tools
  opkg install wireguard-tools-bash-completion
  opkg install kernel-module-wireguard
  opkg install openresolv
  opkg install alsa-utils
  opkg install iptables
  if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies."
    exit 1
  fi
  echo "Dependencies installed successfully."
}

CHIPSET=$(get_chipset_info)

RAW_URL_VERSION="https://raw.githubusercontent.com/m4dhouse/Wireguard-Vpn/$BASE_BRANCH/version"
VERSION=$(python -c "import urllib.request; print(urllib.request.urlopen('$RAW_URL_VERSION').read().decode())")

case $ARCHITECTURE in
  arm*)
    if [ "$CHIPSET" == "hi3716mv430" ]; then
      URL_IPK="https://raw.githubusercontent.com/m4dhouse/Wireguard-Vpn/$BASE_BRANCH/enigma2-plugin-extensions-wireguard-vpn-h82h_${VERSION}_all.ipk"
    else
      URL_IPK="https://raw.githubusercontent.com/m4dhouse/Wireguard-Vpn/$BASE_BRANCH/enigma2-plugin-extensions-wireguard-vpn_${VERSION}_all.ipk"
    fi
    ;;
  mips*)
    URL_IPK="https://raw.githubusercontent.com/m4dhouse/Wireguard-Vpn/$BASE_BRANCH/enigma2-plugin-extensions-wireguard-vpn-mips_${VERSION}_all.ipk"
    ;;
  *)
    echo "Unsupported architecture: $ARCHITECTURE"
    exit 1
    ;;
esac

install_dependencies

echo '====================================='
echo '   I install WireGuard VPN plugin'
echo '====================================='
opkg --force-reinstall --force-overwrite --force-depends install $URL_IPK
echo ''
echo '===================================='
echo '         Restarting enigma2         '
echo '===================================='
init 4
init 3
exit 0
