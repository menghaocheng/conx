#!/bin/bash
# Fix binder devices for container conN
# Usage: ./fix_con.sh <num>

num=${1:?Usage: fix_con.sh <num>}
name="con$num"

binder_base=$(( (num - 1) * 3 + 1 ))
binder_dev="binder${binder_base}"
hwbinder_dev="binder$(( binder_base + 1 ))"
vndbinder_dev="binder$(( binder_base + 2 ))"

get_minor() { grep " ${1}$" /proc/misc | awk '{print $1}'; }

bm=$(get_minor "$binder_dev")
hm=$(get_minor "$hwbinder_dev")
vm=$(get_minor "$vndbinder_dev")

echo "Fixing $name: binder=$binder_dev($bm) hw=$hwbinder_dev($hm) vnd=$vndbinder_dev($vm)"

docker exec "$name" sh -c "
    rm -f /dev/binder /dev/hwbinder /dev/vndbinder
    rm -f /dev/binder[0-9] /dev/binder[0-9][0-9]
    mknod /dev/binder c 10 $bm
    mknod /dev/hwbinder c 10 $hm
    mknod /dev/vndbinder c 10 $vm
    chmod 666 /dev/binder /dev/hwbinder /dev/vndbinder
"

docker exec "$name" setprop ctl.restart servicemanager
docker exec "$name" setprop ctl.restart hwservicemanager
docker exec "$name" setprop ctl.restart vndservicemanager
echo "Binder fixed for $name"
