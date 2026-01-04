#!/usr/bin/bash

docker rm -f con4

docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_xx > /dev/null 2>&1
#rm -fr /data/local/con4

echo "create con4 container ..."
docker create \
    --restart=always \
    --hostname=con4 \
    --name=con4 \
    --network=bridge_xx \
    --privileged \
    --memory 8G\
    --memory-swap 10G \
    -v /data/local/con4:/data \
    -v /var/lib/lxcfs/proc/cpuinfo:/proc/cpuinfo:rw  \
    -v /var/lib/lxcfs/proc/diskstats:/proc/diskstats:rw   \
    -v /var/lib/lxcfs/proc/meminfo:/proc/meminfo:rw   \
    -v /var/lib/lxcfs/proc/stat:/proc/stat:rw  \
    -v /var/lib/lxcfs/proc/swaps:/proc/swaps:rw  \
    -v /var/lib/lxcfs/proc/uptime:/proc/uptime:rw \
    --env prop.persist.sys.display.width=720 \
    --env prop.persist.sys.display.height=1280 \
    --env prop.persist.sys.display.vsync=40 \
    --env prop.persist.sys.display.dpi=320 \
    --env prop.persist.adbd.enable=1 \
    --env prop.persist.vdbd.enable=1 \
    --env prop.persist.adbkey.pub=0 \
    --env prop.persist.vdbkey.pub=0 \
    --env prop.hide.net.iface.name=wlan0 \
    --env prop.ro.instance.id=RK3S07P1402515718_3b7a525d-f488-4a7f-9afb-e80209cd8d00 \
    --env prop.persist.sys.SignalAddress=nats://web-szyf.phone.androidscloud.com:4432 \
    --env prop.persist.sys.SN=5004 \
    --env prop.persist.sys.pushstream=1 \
    --env prop.persist.hide.customization=mp-default \
    --env prop.ro.hide.release.rw.enable=0 \
    --env prop.ro.hide.sdk.rw.enable=0 \
    --env prop.ro.hide.vpspath.enc=1 \
    --env prop.ro.hide.vpspath.hide=1 \
    --env prop.ro.hide.vps.debug=1 \
    --env prop.hide.mtrace.enable=1 \
    --env prop.hide.mtrace.prefix=HHHM==== \
    --mac-address=f0:d7:af:c4:65:68 \
    -p 5004:5555 \
    --env PATH=/sbin:/system/sbin:/product/bin:/apex/com.android.runtime/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:/data/local/tmp/plugin/bin \
    cix_android:10 \
    androidboot.redroid_net_ndns=1 \
    androidboot.redroid_net_dns1=223.5.5.5 \
    androidboot.redroid_net_dns1=223.6.6.6 \

echo "start con4 container ..."
docker start con4
