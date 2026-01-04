#!/usr/bin/bash

set -e  # 发生错误时终止脚本执行

CPU_OVERSUBSCRIBE=120   # CPU 超分比例（120% 表示超分 20%）
TOTAL_MEMORY=16         # 总内存为 16GB
HOST_MEMORY_RESERVED=1  # 预留给宿主机的内存，默认是 1GB
TOTAL_SWAP=8            # 总 swap 为 8GB

create_container() {
    local num=$1
    local total_containers=$2
    local name="android$num"
    local port=$((5000 + num))

    # 计算实际可用内存和 swap
    local available_memory=$((TOTAL_MEMORY - HOST_MEMORY_RESERVED))     # 可用内存（不包含宿主机预留的部分）
    local memory_limit=$((available_memory * 1024 / total_containers))  # 平均分配内存（单位是MB）
    local swap_limit=$((memory_limit + $((TOTAL_SWAP * 1024 / total_containers)))) # 平均分配swap（单位是MB）
    local cpu_period=100000  # 固定 CPU period 为 100000 微秒（100 毫秒）

    # 计算总时间片（宿主机 8 核 CPU）
    local total_cpu_period=$((8 * cpu_period))  # 8 核 CPU，总时间片 = 8 * 100000
    local total_cpu_period_with_oversubscribe=$((total_cpu_period * CPU_OVERSUBSCRIBE / 100))  # 计算超分比例后总时间片
    local cpu_quota=$((total_cpu_period_with_oversubscribe / total_containers))  # 每个容器的 CPU 时间片

    echo "Creating container: $name (Port: $port, Mem: ${memory_limit}M, Swap: ${swap_limit}M, CPU Quota: $cpu_quota)"

    # 移除旧容器（如果存在）
    docker rm -f "$name" 2>/dev/null || true

    # 创建自定义网络（如果不存在）
    if ! docker network inspect bridge_new &>/dev/null; then
        docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_new
    fi

    # 创建容器（但不启动）
    docker create \
        --restart=always \
        --hostname="$name" \
        --name="$name" \
        --network=bridge_new \
        --privileged \
        -v "/data/android_data/$name:/data" \
        -v /var/lib/lxcfs/proc/cpuinfo:/proc/cpuinfo:rw  \
        -v /var/lib/lxcfs/proc/diskstats:/proc/diskstats:rw   \
        -v /var/lib/lxcfs/proc/meminfo:/proc/meminfo:rw   \
        -v /var/lib/lxcfs/proc/stat:/proc/stat:rw  \
        -v /var/lib/lxcfs/proc/swaps:/proc/swaps:rw  \
        -v /var/lib/lxcfs/proc/uptime:/proc/uptime:rw \
        --memory "${memory_limit}M" \
        --memory-swap "${swap_limit}M" \
        --cpu-period "$cpu_period" \
        --cpu-quota "$cpu_quota" \
        --env prop.persist.sys.display.width=720 \
        --env prop.persist.sys.display.height=1280 \
        --env prop.persist.sys.display.vsync=30 \
        --env prop.persist.sys.display.dpi=240 \
        --env prop.persist.adbd.enable=1 \
        --env prop.persist.adbkey.pub=0 \
        -p "$port":5555 \
        --env PATH="$PATH" \
        rk3588:RK_ANDROID10-RKR10

    echo "Container $name created."

    # 启动容器
    docker start "$name"
    echo "Container $name started."
}

start_containers() {
    local num_containers=${1:-5}  # 默认 5 个容器

    # 确保参数是正整数
    if ! [[ "$num_containers" =~ ^[1-9][0-9]*$ ]]; then
        echo "Usage: start_containers <num_containers>"
        echo "Error: <num_containers> must be a positive integer."
        return 1
    fi

    echo "Starting $num_containers containers with CPU oversubscription: $CPU_OVERSUBSCRIBE%"

    # 创建并启动容器
    for ((i = 1; i <= num_containers; i++)); do
        create_container "$i" "$num_containers"
    done
}

# 允许直接运行脚本时传入参数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    start_containers "$@"
fi
