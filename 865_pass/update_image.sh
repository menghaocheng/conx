#!/system/bin/sh

CURT_DATE=$(date +%Y%m%d)
echo "DATE=$CURT_DATE"

IMG_VERSION="VC.20251122.029-szx"        # 加引号
echo "IMG_VERSION=$IMG_VERSION"

#REMOTE_PATH="/home/mhc/56T/865_pass/paas_865_android10/IMAGE/${IMG_VERSION}_user_${CURT_DATE}/android-latest.img"
REMOTE_PATH="/home/mhc/56T/865_pass/paas_865_android10/IMAGE/VC.20251203.034-szx_user_20251206/android-latest.img"
REMOTE_PATH="/home/mhc/56T/865_pass/paas_865_android10/IMAGE/VC.20251218.038-mp_user_20251224/android-latest.img"
REMOTE_PATH="/home/mhc/56T/865_pass/paas_865_android10/IMAGE/VC.20251225.039-dbg-mp_user_20251225/android-latest.img"
REMOTE_PATH="/home/mhc/56T/865_pass/paas_865_android10/IMAGE/VC.20251219.038.1-szx_user_20251219/android-latest.img"
REMOTE_PATH="/home/mhc/56T/865_pass/paas_865_android10/IMAGE/VC.20251230.039-mp_user_20251230/android-latest.img"
REMOTE_PATH="/home/mhc/56T/865_pass/paas_865_android10/IMAGE/VC.20260104.040-mp_user_20260105/android-latest.img"

REMOTE_PATH="/home/mhc/56T/865_pass/paas_865_android10/out/target/product/kona/android-latest.img"

echo "远程镜像路径: $REMOTE_PATH"

echo "正在从 192.168.164.2 下载镜像..."
scp -q mhc@192.168.164.2:"${REMOTE_PATH}" . || {
    echo "scp 下载失败！请检查网络或远端目录是否存在"
    exit 1
}

echo "下载完成："
ls -lh android-latest.img