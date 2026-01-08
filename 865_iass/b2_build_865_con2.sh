#!/system/bin/sh


CON_NAME=con2
ADB_PORT=5002
INSTANCE=instance2
CON_MAC=f0:d7:af:c4:20:20
CON_IP=192.168.15.102

docker rm -f ${CON_NAME} > /dev/null 2>&1

docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_new > /dev/null 2>&1
#rm -fr /data/local/${CON_NAME}

con_ip=${CON_IP}/24 \
con_gateway=192.168.15.1 \
con_dns1=223.5.5.5 \
con_dns2=223.6.6.6 \
docker container create \
    --restart=always \
    --hostname=${CON_NAME} \
    --name=${CON_NAME} \
    --network=bridge_new \
    --privileged \
    --memory 8G\
    --memory-swap 10G \
    --platform linux/amd64 \
    -v /data/local/${CON_NAME}:/data \
    -v /var/lib/lxcfs/proc/cpuinfo:/proc/cpuinfo:rw \
    -v /var/lib/lxcfs/proc/diskstats:/proc/diskstats:rw \
    -v /var/lib/lxcfs/proc/meminfo:/proc/meminfo:rw \
    -v /var/lib/lxcfs/proc/stat:/proc/stat:rw \
    -v /var/lib/lxcfs/proc/swaps:/proc/swaps:rw \
    -v /var/lib/lxcfs/proc/uptime:/proc/uptime:rw \
    --mac-address=${CON_MAC} \
    --ip=${CON_IP} \
    -p ${ADB_PORT}:5555 \
    android:latest ${INSTANCE} \
    persist.sys.display.width=720 \
    persist.sys.display.height=1280 \
    persist.sys.display.vsync=30 \
    persist.sys.display.dpi=320 \

#    ro.boot.virtdroid_width=1080 \
#    ro.boot.virtdroid_height=1920

docker start ${CON_NAME}
