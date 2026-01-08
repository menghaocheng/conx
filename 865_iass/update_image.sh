#!/system/bin/sh

CURT_DATE=$(date +%Y%m%d)
echo "DATE=$CURT_DATE"

REMOTE_PATH="/home/mhc/56T/865/Qualcomm865_vir/out/target/product/kona/android-latest.img"
echo "远程镜像路径: $REMOTE_PATH"

echo "正在从 192.168.164.2 下载镜像..."
scp -q mhc@192.168.164.2:"${REMOTE_PATH}" . || {
    echo "scp 下载失败！请检查网络或远端目录是否存在"
    exit 1
}

echo "下载完成："
ls -lh android-latest.img