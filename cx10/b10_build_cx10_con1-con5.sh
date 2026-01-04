#!/bin/bash

# 脚本用于批量创建和启动 Android 容器 con1 到 con5

create_container() {
    local num=$1
    local name="con$num"
    local port=$((5000 + num))

    echo "Processing container $name..."

    # 删除现有容器
    docker rm -f "$name" 2>/dev/null

    # 创建网络（如果不存在）
    docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_xx 2>/dev/null

    # 清理数据目录（可选）
    # rm -fr "/data/local/$name"

    echo "Creating container $name..."
    docker create \
        --restart=always \
        --hostname="$name" \
        --name="$name" \
        --network=bridge_xx \
        --privileged \
        --memory 8G \
        --memory-swap 10G \
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
        --env prop.persist.sys.display.dpi=320 \
        --env prop.persist.vdbd.enable=1 \
        --env prop.persist.vdbkey.pub=0 \
        --env prop.hide.net.iface.name=wlan0 \
        --env prop.persist.hide.customization=mp-default \
        -p "$port":5555 \
        --env PATH=/sbin:/system/sbin:/product/bin:/apex/com.android.runtime/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:/data/local/tmp/plugin/bin \
        cix_android:10 \
        androidboot.redroid_net_ndns=1 \
        androidboot.redroid_net_dns1=223.5.5.5 \
        androidboot.redroid_net_dns2=223.6.6.6

    if [ $? -eq 0 ]; then
        echo "Starting container $name..."
        docker start "$name"
        if [ $? -eq 0 ]; then
            echo "Container $name started successfully"
        else
            echo "Error: Failed to start container $name"
        fi
    else
        echo "Error: Failed to create container $name"
    fi
}

echo "Starting batch creation of containers con1 to con5..."
for i in {1..5}; do
    create_container "$i"
done

echo "All containers processed successfully!"
