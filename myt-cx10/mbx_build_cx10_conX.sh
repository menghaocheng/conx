#!/bin/bash

# cix_android:10 on MYT hardware
# Post-start fixes: binder device replacement + cpuset population

careate_bridge_network() {
    docker network create --driver=bridge --subnet=192.168.15.0/24 \
        -o com.docker.network.bridge.enable_ip_masquerade=true \
        -o com.docker.network.bridge.enable_icc=true \
        bridge_new 2>/dev/null
}

fix_cpuset() {
    local name=$1
    docker exec "$name" sh -c '\
        cpus=$(cat /dev/cpuset/cpuset.cpus); \
        mems=$(cat /dev/cpuset/cpuset.mems); \
        for dir in foreground background top-app system-background restricted; do \
            if [ -d "/dev/cpuset/$dir" ]; then \
                echo "$cpus" > "/dev/cpuset/$dir/cpuset.cpus" 2>/dev/null; \
                echo "$mems" > "/dev/cpuset/$dir/cpuset.mems" 2>/dev/null; \
            fi; \
        done'
}

create_container() {
    local num=$1
    local name="con$num"
    local mac=f0:d7:af:c4:65:$(printf '%02x' $((0x40 + num)))

    local adb_port=$((5000 + num))

    # binder devices: con N uses binder[(N-1)*3+1], binder[(N-1)*3+2], binder[(N-1)*3+3]
    local binder_base=$(( (num - 1) * 3 + 1 ))
    local binder_dev="binder${binder_base}"
    local hwbinder_dev="binder$(( binder_base + 1 ))"
    local vndbinder_dev="binder$(( binder_base + 2 ))"

    docker rm -f "$name" 2>/dev/null

    #rm -fr "/data/local/$name"

    docker create  \
        --restart=no \
        --hostname=${name} \
        --name=${name} \
        --network=bridge_new \
        --privileged \
        --cgroupns=host \
        --security-opt seccomp=unconfined \
        --memory 8G \
        --memory-swap 10G \
        -v /data/local/${name}:/data \
        --device /dev/${binder_dev}:/dev/binder:rwm \
        --device /dev/${hwbinder_dev}:/dev/hwbinder:rwm \
        --device /dev/${vndbinder_dev}:/dev/vndbinder:rwm \
        --device /dev/${binder_dev}:/dev/conx_binder:rwm \
        --device /dev/${hwbinder_dev}:/dev/conx_hwbinder:rwm \
        --device /dev/${vndbinder_dev}:/dev/conx_vndbinder:rwm \
        --device /dev/dri \
        --device /dev/fuse \
        --device /dev/dma_heap/system \
        --device /dev/dma_heap/system-uncached \
        --device /dev/ashmem \
        --device /dev/mali0 \
        --device /dev/tee0 \
        --device /dev/teepriv0 \
        --device /dev/video0 \
        --device /dev/video1 \
        --device-cgroup-rule='c 10:* rmw' \
        --device-cgroup-rule='b 252:* rmw' \
        --device-cgroup-rule='b 7:* rmw' \
        --env prop.persist.sys.display.width=720 \
        --env prop.persist.sys.display.height=1280 \
        --env prop.persist.sys.display.vsync=30 \
        --env prop.persist.sys.display.dpi=320 \
        --env prop.persist.adbd.enable=1 \
        --env prop.persist.vdbd.enable=1 \
        --env prop.persist.adbkey.pub=0 \
        --env prop.persist.vdbkey.pub=0 \
        --env prop.hide.net.iface.name=wlan0 \
        --env prop.persist.sys.pushstream=1 \
        --env prop.persist.hide.customization=mp-default \
        --env prop.ro.hide.release.rw.enable=0 \
        --env prop.ro.hide.sdk.rw.enable=0 \
        --env prop.ro.hide.vpspath.enc=1 \
        --env prop.ro.hide.vpspath.hide=1 \
        --env prop.ro.hide.vps.debug=1 \
        --env prop.hide.mtrace.enable=1 \
        --mac-address=${mac} \
        -p ${adb_port}:5555 \
        --env PATH=/sbin:/system/sbin:/product/bin:/apex/com.android.runtime/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:/data/local/tmp/plugin/bin \
        cix_android:10 \
        androidboot.conx_binder_fix=1 \
        androidboot.hardware=cix \
        androidboot.redroid_net_ndns=2 \
        androidboot.redroid_net_dns1=223.5.5.5 \
        androidboot.redroid_net_dns2=223.6.6.6

    docker start "$name"

    # Binder is now corrected inside the image during init in docker mode.
    fix_cpuset "$name"

    echo "Container $name started. Waiting for Android boot..."
    for i in $(seq 1 60); do
        if docker exec "$name" getprop sys.boot_completed 2>/dev/null | grep -q 1; then
            echo "Container $name boot completed!"
            return 0
        fi
        sleep 2
    done
    echo "Warning: Container $name boot did not complete within 120s"
}

careate_bridge_network

create_container $1


        # -p ${port_base}:5555 \
        # -p $((port_base+1)):9082 \
        # -p $((port_base+2)):9083 \
        # -p $((port_base+3)):10000 \
        # -p $((port_base+4)):10001/udp \
        # -p $((port_base+5)):10006 \
        # -p $((port_base+6)):10007/udp \
        # -p $((port_base+7)):10008 \
        # -p $((port_base+8)):10008/udp \
