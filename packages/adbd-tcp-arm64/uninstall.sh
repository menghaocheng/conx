#!/bin/sh
set -eu

OPENRC_DST="/etc/init.d/adbd-tcp"
SYSTEMD_DST="/etc/systemd/system/adbd-tcp.service"
LOCALD_DST="/etc/local.d/adbd-tcp.start"
START_SCRIPT="/usr/local/sbin/adbd-tcp-start.sh"
BIN_DST="/usr/bin/adbd"
REAL_BIN_DST="/usr/local/libexec/adbd-tcp/adbd.real"
LIB_DST_DIR="/usr/local/lib/adbd-tcp"
RC_UPDATE_BIN=$(command -v rc-update 2>/dev/null || true)

if [ -z "$RC_UPDATE_BIN" ] && [ -x /sbin/rc-update ]; then
    RC_UPDATE_BIN=/sbin/rc-update
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "uninstall.sh must be run as root" >&2
    exit 1
fi

if [ -x "$OPENRC_DST" ]; then
    "$OPENRC_DST" stop >/dev/null 2>&1 || true
fi

if [ -x /etc/init.d/local ]; then
    /etc/init.d/local stop >/dev/null 2>&1 || true
fi

if [ -n "$RC_UPDATE_BIN" ]; then
    "$RC_UPDATE_BIN" del adbd-tcp default >/dev/null 2>&1 || true
    "$RC_UPDATE_BIN" del local default >/dev/null 2>&1 || true
fi

if command -v systemctl >/dev/null 2>&1; then
    systemctl disable --now adbd-tcp.service >/dev/null 2>&1 || true
    systemctl daemon-reload >/dev/null 2>&1 || true
fi

killall adbd 2>/dev/null || true
rm -f "$OPENRC_DST" "$SYSTEMD_DST" "$LOCALD_DST" "$START_SCRIPT" "$BIN_DST" "$REAL_BIN_DST"
rmdir /usr/local/libexec/adbd-tcp 2>/dev/null || true
rm -rf "$LIB_DST_DIR"
echo "Removed adbd TCP startup integration and packaged runtime files."