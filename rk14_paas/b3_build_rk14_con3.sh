#!/bin/bash

create_container() {
	local IMAGE_NAME="rk3588:ANDROID14_RKR14"
    local NUM=$1
    local CON_NAME="con$NUM"
    local ADB_PORT=$((5000 + NUM))
    local MAC=f0:d7:af:41:65:$(printf '%02x' $((0x40 + NUM)))
    
    docker rm -f "$CON_NAME" 2>/dev/null
    docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_new 2>/dev/null
    #rm -fr "/data/local/$name"
    
    docker create  \
        --restart=always \
        --hostname=${CON_NAME} \
        --name=${CON_NAME} \
        --network=bridge_new \
        --privileged \
        --memory 8G\
        --memory-swap 10G \
        -v /data/local/${CON_NAME}:/data \
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
        --mac-address=${MAC} \
        -p ${ADB_PORT}:5555 \
        --env PATH=/sbin:/system/sbin:/product/bin:/apex/com.android.runtime/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:/data/local/tmp/plugin/bin \
		${IMAGE_NAME} \
        androidboot.redroid_net_ndns=2 \
        androidboot.redroid_net_dns1=223.5.5.5 \
        androidboot.redroid_net_dns1=223.6.6.6 \
    
    docker start "$CON_NAME"
}

create_container 3