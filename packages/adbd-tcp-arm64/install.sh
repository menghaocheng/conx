#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PORT=${ADBD_TCP_PORT:-5555}
BIN_SRC="$SCRIPT_DIR/bin/adbd"
BIN_DST="/usr/bin/adbd"
REAL_BIN_DST="/usr/local/libexec/adbd-tcp/adbd.real"
LIB_SRC_DIR="$SCRIPT_DIR/lib"
LIB_DST_DIR="/usr/local/lib/adbd-tcp"
START_SCRIPT="/usr/local/sbin/adbd-tcp-start.sh"
OPENRC_SRC="$SCRIPT_DIR/services/openrc/adbd-tcp"
OPENRC_DST="/etc/init.d/adbd-tcp"
SYSTEMD_SRC="$SCRIPT_DIR/services/systemd/adbd-tcp.service"
SYSTEMD_DST="/etc/systemd/system/adbd-tcp.service"
LOCALD_DST="/etc/local.d/adbd-tcp.start"
LOG_DIR="/var/log"
LOG_FILE="$LOG_DIR/adbd-tcp.log"
RC_UPDATE_BIN=$(command -v rc-update 2>/dev/null || true)

if [ -z "$RC_UPDATE_BIN" ] && [ -x /sbin/rc-update ]; then
    RC_UPDATE_BIN=/sbin/rc-update
fi

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "install.sh must be run as root" >&2
        exit 1
    fi
}

ensure_dirs() {
    mkdir -p /usr/bin /usr/local/sbin /usr/local/libexec/adbd-tcp "$LIB_DST_DIR" "$LOG_DIR"
}

strip_cr() {
    target=$1
    tmp=$(mktemp)
    tr -d '\r' < "$target" > "$tmp"
    cat "$tmp" > "$target"
    rm -f "$tmp"
}

backup_if_needed() {
    target=$1
    if [ -f "$target" ]; then
        src_sum=$(md5sum "$BIN_SRC" | awk '{print $1}')
        dst_sum=$(md5sum "$target" | awk '{print $1}')
        if [ "$src_sum" != "$dst_sum" ]; then
            backup="$target.bak.$(date +%Y%m%d%H%M%S)"
            cp -a "$target" "$backup"
            echo "Backed up existing $(basename "$target") to $backup"
        fi
    fi
}

install_binary() {
    if [ ! -f "$BIN_SRC" ]; then
        echo "Missing binary: $BIN_SRC" >&2
        exit 1
    fi
    backup_if_needed "$BIN_DST"
    install -m 0755 "$BIN_SRC" "$REAL_BIN_DST"

    if [ -d "$LIB_SRC_DIR" ]; then
        find "$LIB_SRC_DIR" -maxdepth 1 -type f | while read -r lib; do
            install -m 0644 "$lib" "$LIB_DST_DIR/$(basename "$lib")"
        done
    fi

    cat > "$BIN_DST" <<EOF
#!/bin/sh
set -eu
LIB_DIR=$LIB_DST_DIR
REAL_BIN=$REAL_BIN_DST
export LD_LIBRARY_PATH="\$LIB_DIR\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec "\$REAL_BIN" "\$@"
EOF
    strip_cr "$BIN_DST"
    chmod 0755 "$BIN_DST"
}

install_start_script() {
    cat > "$START_SCRIPT" <<EOF
#!/bin/sh
set -eu
PORT=\${ADBD_TCP_PORT:-$PORT}
LOG_FILE=/var/log/adbd-tcp.log
killall adbd 2>/dev/null || true
exec /usr/bin/adbd tcp:\$PORT >>"\$LOG_FILE" 2>&1
EOF
    strip_cr "$START_SCRIPT"
    chmod 0755 "$START_SCRIPT"
}

install_openrc() {
    if [ ! -d /etc/init.d ] || [ -z "$RC_UPDATE_BIN" ]; then
        return 1
    fi
    install -m 0755 "$OPENRC_SRC" "$OPENRC_DST"
    strip_cr "$OPENRC_DST"
    "$RC_UPDATE_BIN" add adbd-tcp default >/dev/null 2>&1 || true
    if [ -x "$OPENRC_DST" ]; then
        "$OPENRC_DST" restart || "$OPENRC_DST" start || true
    fi
    echo "Installed OpenRC service: $OPENRC_DST"
    return 0
}

install_systemd() {
    if ! command -v systemctl >/dev/null 2>&1; then
        return 1
    fi
    install -m 0644 "$SYSTEMD_SRC" "$SYSTEMD_DST"
    strip_cr "$SYSTEMD_DST"
    systemctl daemon-reload || true
    systemctl enable adbd-tcp.service || true
    systemctl restart adbd-tcp.service || systemctl start adbd-tcp.service || true
    echo "Installed systemd unit: $SYSTEMD_DST"
    return 0
}

install_locald() {
    if [ ! -d /etc/local.d ]; then
        return 1
    fi
    cat > "$LOCALD_DST" <<EOF
#!/bin/sh
killall adbd 2>/dev/null || true
nohup /usr/bin/adbd tcp:$PORT >>/var/log/adbd-tcp.log 2>&1 &
EOF
    strip_cr "$LOCALD_DST"
    chmod 0755 "$LOCALD_DST"
    if [ -n "$RC_UPDATE_BIN" ]; then
        "$RC_UPDATE_BIN" add local default >/dev/null 2>&1 || true
        if [ -x /etc/init.d/local ]; then
            /etc/init.d/local restart || true
        fi
    fi
    echo "Installed local.d fallback: $LOCALD_DST"
    return 0
}

verify_runtime() {
    sleep 1
    if ps | grep -q '[a]dbd'; then
        echo "adbd is running"
    else
        echo "adbd is not running yet; check $LOG_FILE" >&2
    fi
}

main() {
    require_root
    ensure_dirs
    install_binary
    install_start_script

    if install_openrc; then
        :
    elif install_systemd; then
        :
    elif install_locald; then
        :
    else
        echo "No supported init integration found; starting adbd once in background" >&2
        nohup "$START_SCRIPT" >/dev/null 2>&1 &
    fi

    verify_runtime
    echo "Install complete. Expected TCP endpoint: tcp:$PORT"
}

main "$@"