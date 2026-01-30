#!/system/bin/sh

CON_NAME=con1
ADB_PORT=5001

docker rm -f ${CON_NAME} > /dev/null 2>&1

docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_new > /dev/null 2>&1
#rm -fr /data/local/con1
docker create  \
    --restart=always \
    --hostname=con1 \
    --name=con1 \
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
    --env PATH=/system/bin:/system/sbin:/system/xbin:/system_ext/bin:/vendor/bin:/vendor/xbin:/odm/bin:/oem/bin:/product/bin:/data/bin:/data/local/tmp/plugin/bin \
    -p ${ADB_PORT}:5555 \
    android:latest \
    androidboot.redroid_net_dns1=223.5.5.5 \
    androidboot.redroid_net_dns2=223.6.6.6 \
    androidboot.redroid_net_ndns=2

docker start ${CON_NAME}

#       --cpu-period 100000 \
#        --cpu-quota 500000 \

#        -p 27042:27042 \

#/system/bin:/system/sbin:/system/xbin:/system_ext/bin:/vendor/bin:/vendor/xbin:/odm/bin:/oem/bin:/product/bin:/data/bin:/data/local/tmp/plugin/bin