#!/bin/bash

# 脚本参数：
# -d: 是否删除容器数据（1表示删除，0表示不删除，默认0）
# -p: 是否创建data分区（1表示创建，0表示不创建，默认1）

# 默认参数值
DELETE_DATA=0
CREATE_PARTITION=1

# 解析命令行参数
while getopts "d:p:" opt; do
  case $opt in
    d) DELETE_DATA=$OPTARG ;;
    p) CREATE_PARTITION=$OPTARG ;;
    \?) echo "无效选项: -$OPTARG" >&2; exit 1 ;;
    :) echo "选项 -$OPTARG 需要参数。" >&2; exit 1 ;;
  esac
done

# 导入镜像前置检查步骤
echo "===== 开始导入镜像前置检查 ====="

# 1. 检查super_img目录
if [ ! -d "/userdata/super_img" ]; then
  echo "错误：/userdata/super_img目录不存在，退出脚本"
  exit 1
fi

# 2. 检查并处理容器con4
if [ "$(docker ps -aq -f name=^/con4$)" ]; then
  echo "容器con4存在，正在停止并删除..."
  docker stop con4
  docker rm con4
  dmsetup remove con4-odm
  dmsetup remove con4-odm_dlkm
  dmsetup remove con4-product
  dmsetup remove con4-system
  dmsetup remove con4-system_dlkm
  dmsetup remove con4-system_ext
  dmsetup remove con4-vendor
  dmsetup remove con4-vendor_dlkm
fi

# 检查并释放相关的loop设备
echo "检查并释放与super-con4.img相关的loop设备..."
LOOP_IMG_DEVICES=$(losetup | grep "super-con4.img" | awk '{print $1}')
if [ -n "$LOOP_IMG_DEVICES" ]; then
  echo "发现super-con4.img相关loop设备: $LOOP_IMG_DEVICES"
  for device in $LOOP_IMG_DEVICES; do
    echo "释放super-con4.img loop设备: $device"
    losetup -d $device
  done
fi

# 3. 检查并删除镜像
if [ "$(docker images -q rk3588:ANDROID14_RKR14_DM 2> /dev/null)" ]; then
  echo "镜像rk3588:ANDROID14_RKR14_DM存在，正在删除..."
  docker rmi rk3588:ANDROID14_RKR14_DM
fi

# 导入镜像
echo "===== 开始导入镜像 ====="
tar --xattrs -c -C /userdata/super_img . | sudo docker import -c 'ENTRYPOINT ["/init", "androidboot.hardware=nxc"]' - rk3588:ANDROID14_RKR14_DM

if [ $? -ne 0 ]; then
  echo "镜像导入失败，退出脚本"
  exit 1
fi

# 删除镜像解压文件
echo "===== 清理临时文件 ====="
#rm -rf /userdata/super_img

# 创建data分区（通过参数控制）
if [ $CREATE_PARTITION -eq 1 ]; then
  echo "===== 开始创建data分区 ====="
  
  # 如果文件存在，先处理
  if [ -f "/userdata/DockerMount/con4.img" ]; then
    echo "con4.img已存在，正在处理..."
    # 检查是否挂载
    MOUNT_POINT=$(mount | grep "/userdata/DockerMount/con4.img" | awk '{print $3}')
    if [ -n "$MOUNT_POINT" ]; then
      umount $MOUNT_POINT
    fi
    rm -f /userdata/DockerMount/con4.img
    rm -rf /userdata/android_data/con4
  fi

  # 检查并释放相关的loop设备
  echo "检查并释放与con4相关的loop设备..."
  LOOP_DEVICES=$(losetup | grep "con4" | awk '{print $1}')
  if [ -n "$LOOP_DEVICES" ]; then
    echo "发现相关loop设备: $LOOP_DEVICES"
    for device in $LOOP_DEVICES; do
      echo "释放loop设备: $device"
      losetup -d $device
    done
  fi
  
  # 创建img文件
  echo "创建con4.img文件..."
  dd if=/dev/urandom of=/userdata/DockerMount/con4.img bs=1M count=0 seek=40480
  
  # 查询并绑定loop设备
  echo "绑定loop设备..."
  LOOP_DEVICE=$(losetup -f --show /userdata/DockerMount/con4.img)
  echo "使用loop设备: $LOOP_DEVICE"
  
  # 格式化
  echo "格式化分区..."
  mkfs.ext4 $LOOP_DEVICE
  
  # 创建挂载路径
  echo "创建挂载路径..."
  mkdir -p /userdata/android_data/con4
  
  # 挂载
  echo "挂载分区..."
  mount -o loop /userdata/DockerMount/con4.img /userdata/android_data/con4
  
  # 解绑loop设备
  echo "解绑loop设备..."
  losetup -d $LOOP_DEVICE
fi

# 创建容器前置条件（通过参数控制）
if [ $DELETE_DATA -eq 1 ]; then
  echo "===== 开始删除容器数据 ====="
  rm -rf /userdata/android_data/con4/*
fi
docker network create -d bridge --subnet=192.168.15.0/24 --ip-range=192.168.15.0/24 --gateway=192.168.15.1 -o macvlan_mode=bridge -o parent=eth0 bridge_new
# docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_new 2>/dev/null

# 创建容器
echo "===== 开始创建容器 ====="
docker run -itd --restart=always --name=con4 --hostname=con4 --privileged \
-v /userdata/android_data/con4:/data \
--volume=/dev/input/event0:/dev/input/event0:rw \
--volume=/dev/input/event1:/dev/input/event1:rw \
--volume=/dev/input/event2:/dev/input/event2:rw \
--volume=/dev/input/event3:/dev/input/event3:rw \
--volume=/dev/input/event4:/dev/input/event4:rw \
--volume=/dev/input/event5:/dev/input/event5:rw \
--volume=/dev/input/event6:/dev/input/event6:rw \
--volume=/dev/input/event7:/dev/input/event7:rw \
--volume=/dev/input/event8:/dev/input/event8:rw \
--volume=/dev/mapper/control:/dev/device-mapper:rw \
-v /var/lib/lxcfs/proc/cpuinfo:/proc/cpuinfo:rw \
-v /var/lib/lxcfs/proc/diskstats:/proc/diskstats:rw \
-v /var/lib/lxcfs/proc/meminfo:/proc/meminfo:rw \
-v /var/lib/lxcfs/proc/stat:/proc/stat:rw \
-v /var/lib/lxcfs/proc/swaps:/proc/swaps:rw \
-v /var/lib/lxcfs/proc/uptime:/proc/uptime:rw \
--network=bridge_new \
--ip=192.168.15.104 \
-p 5004:5555 \
--memory=4096M \
--env PATH=/sbin:/system/sbin:/product/bin:/apex/com.android.runtime/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:/data/local/tmp/plugin/bin \
--env prop.hide.net.iface.name=wlan0 rk3588:ANDROID14_RKR14_DM \
androidboot.redroid_net_dns1=114.114.114.114 \
androidboot.redroid_net_dns2=8.8.8.8 \
androidboot.instance.id=con4


if [ $? -eq 0 ]; then
  echo "容器创建成功"
else
  echo "容器创建失败"
  exit 1
fi

echo "===== 所有操作完成 ====="
