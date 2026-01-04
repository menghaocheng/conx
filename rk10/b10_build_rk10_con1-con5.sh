#!/usr/bin/bash

create_container() {
    local num=$1
    local name="con$num"
    local port=$((5000 + num))
    
    docker rm -f "$name"
    docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_new 2>/dev/null
    #rm -fr "/data/local/$name"
    
    docker create  \
        --restart=always \
        --hostname="$name" \
        --name="$name" \
        --network=bridge_new \
        --privileged \
        -v "/data/local/$name:/data" \
        -v /var/lib/lxcfs/proc/cpuinfo:/proc/cpuinfo:rw  \
        -v /var/lib/lxcfs/proc/diskstats:/proc/diskstats:rw   \
        -v /var/lib/lxcfs/proc/meminfo:/proc/meminfo:rw   \
        -v /var/lib/lxcfs/proc/stat:/proc/stat:rw  \
        -v /var/lib/lxcfs/proc/swaps:/proc/swaps:rw  \
        -v /var/lib/lxcfs/proc/uptime:/proc/uptime:rw \
        --env prop.persist.sys.display.width=720 \
        --env prop.persist.sys.display.height=1280 \
        --env prop.persist.sys.display.vsync=30 \
        --env prop.persist.sys.display.dpi=240 \
        --env prop.persist.adbd.enable=1 \
        --env prop.persist.adbkey.pub=0 \
        -p "$port":5555 \
        --env PATH="$PATH" \
        rk3588:RK_ANDROID10-RKR10
    
    docker start "$name"
}

for i in {1..6}; do
    create_container "$i"
done
