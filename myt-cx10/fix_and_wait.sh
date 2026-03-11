#!/bin/bash
# Fix binder devices for con4 and wait for boot
NAME=con4
BINDER_MINOR=$(grep " binder10$" /proc/misc | awk '{print $1}')
HWBINDER_MINOR=$(grep " binder11$" /proc/misc | awk '{print $1}')
VNDBINDER_MINOR=$(grep " binder12$" /proc/misc | awk '{print $1}')

echo "Fixing binder: binder10=$BINDER_MINOR binder11=$HWBINDER_MINOR binder12=$VNDBINDER_MINOR"

docker exec "$NAME" sh -c "\
    rm -f /dev/binder /dev/hwbinder /dev/vndbinder; \
    rm -f /dev/binder[0-9] /dev/binder[0-9][0-9]; \
    mknod /dev/binder c 10 ${BINDER_MINOR}; \
    mknod /dev/hwbinder c 10 ${HWBINDER_MINOR}; \
    mknod /dev/vndbinder c 10 ${VNDBINDER_MINOR}; \
    chmod 666 /dev/binder /dev/hwbinder /dev/vndbinder"

echo "Binder fixed. Restarting servicemanagers..."
docker exec "$NAME" setprop ctl.restart servicemanager
docker exec "$NAME" setprop ctl.restart hwservicemanager
docker exec "$NAME" setprop ctl.restart vndservicemanager

echo "Fixing cpuset..."
docker exec "$NAME" sh -c '\
    cpus=$(cat /dev/cpuset/cpuset.cpus); \
    mems=$(cat /dev/cpuset/cpuset.mems); \
    for dir in foreground background top-app system-background restricted; do \
        if [ -d "/dev/cpuset/$dir" ]; then \
            echo "$cpus" > "/dev/cpuset/$dir/cpuset.cpus" 2>/dev/null; \
            echo "$mems" > "/dev/cpuset/$dir/cpuset.mems" 2>/dev/null; \
        fi; \
    done'

echo "Waiting for boot..."
for i in $(seq 1 90); do
    result=$(docker exec "$NAME" getprop sys.boot_completed 2>/dev/null)
    if [ "$result" = "1" ]; then
        echo "Boot completed after ${i}x2 seconds!"
        exit 0
    fi
    sleep 2
done
echo "Boot did not complete within 180s"
docker exec "$NAME" logcat -d -b main -t 50 2>/dev/null | grep -iE "fatal|error|died|binder"
