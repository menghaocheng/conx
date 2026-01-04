#!/usr/bin/bash

docker rm -f con5

docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_xx > /dev/null 2>&1
#rm -fr /data/local/con5

echo "create con5 container ..."
docker create \
	--restart=always \
    --hostname=con5 \
    --name=con5 \
    --network=bridge_xx \
    --privileged \
    --memory 8G\
    --memory-swap 10G \
    -v /data/local/con5:/data \
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
    --env prop.persist.vdbd.enable=1 \
    --env prop.persist.vdbkey.pub=0 \
    --env prop.hide.net.iface.name=wlan0 \
    --env prop.persist.hide.customization=mp-default \
    -p 5005:5555 \
	--env PATH=/sbin:/system/sbin:/product/bin:/apex/com.android.runtime/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:/data/local/tmp/plugin/bin \
	cix_android:10 \
	androidboot.redroid_net_ndns=1 \
	androidboot.redroid_net_dns1=223.5.5.5 \
	androidboot.redroid_net_dns1=223.6.6.6 \

echo "start con5 container ..."
docker start con5
