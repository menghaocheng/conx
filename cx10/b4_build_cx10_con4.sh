#!/usr/bin/bash


create_container() {
    local num=$1
    local name="con$num"
    local adb_port=$((5000 + num))
    local mac=f0:d7:af:c4:65:$(printf '%02x' $((0x40 + num)))
    
    docker rm -f "$name" 2>/dev/null
    docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_new 2>/dev/null
    #rm -fr "/data/local/$name"
    
    docker create  \
        --restart=always \
        --hostname=${name} \
        --name=${name} \
        --network=bridge_new \
        --privileged \
        --memory 8G\
        --memory-swap 10G \
        -v /data/local/${name}:/data \
        -v /var/lib/lxcfs/proc/cpuinfo:/proc/cpuinfo:rw  \
        -v /var/lib/lxcfs/proc/diskstats:/proc/diskstats:rw   \
        -v /var/lib/lxcfs/proc/meminfo:/proc/meminfo:rw   \
        -v /var/lib/lxcfs/proc/stat:/proc/stat:rw  \
        -v /var/lib/lxcfs/proc/swaps:/proc/swaps:rw  \
        -v /var/lib/lxcfs/proc/uptime:/proc/uptime:rw \
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
        androidboot.redroid_net_ndns=2 \
        androidboot.redroid_net_dns1=223.5.5.5 \
        androidboot.redroid_net_dns1=223.6.6.6 \
    
    docker start "$name"
}

create_container 4

