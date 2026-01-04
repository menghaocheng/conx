#!/bin/bash
set -e  # 遇到错误时退出

# 打印使用说明
usage() {
    echo "Usage: $0 {setup|cleanup|show} <name>"
    echo ""
    echo "This script allows you to manage disk images for mounting and cleanup."
    echo ""
    echo "Commands:"
    echo "  -s, setup    Create a new disk image and mount it."
    echo "  -c, cleanup  Unmount and delete the disk image."
    echo "  -v, show     Show reserved block information and loop device mapping."
    echo ""
    echo "Examples:"
    echo "  1. Create and mount a new image file:"
    echo "     $0 -s android4"
    echo "     This will create 'android4.img' (30GB) and mount it to '/data/local/android4'."
    echo ""
    echo "  2. Unmount and remove the image file:"
    echo "     $0 -c android4"
    echo "     This will unmount and delete 'android4.img'."
    echo ""
    echo "  3. Show information about the image file:"
    echo "     $0 -v android4"
    echo "     This will show reserved block info and loop device mapping for 'android4.img'."
    echo ""
}

# 检查是否有足够的参数
if [ "$#" -lt 2 ]; then
    usage
    exit 1
fi

ACTION="$1"
NAME="$2"
IMG_FILE="/userdata/DockerMount/${NAME}.img"
MOUNT_POINT="/userdata/android_data/${NAME}"

# 检查NAME是否为空
if [ -z "$NAME" ]; then
    echo "Error: <name> cannot be empty!"
    exit 1
fi

# 创建并挂载镜像
setup_image() {
    echo "Creating image file: $IMG_FILE..."
    dd if=/dev/zero of="$IMG_FILE" bs=1M count=0 seek=30720

    echo "Finding available loop device..."
    LOOP_DEV=$(losetup --show -f "$IMG_FILE")
    echo "Using loop device: $LOOP_DEV"

    echo "Formatting as ext4..."
    mkfs.ext4 "$LOOP_DEV"

    echo "Setting file ownership..."
    tune2fs -u 1000 -g 1000 "$IMG_FILE"

    echo "Creating mount directory: $MOUNT_POINT..."
    mkdir -p "$MOUNT_POINT"

    echo "Mounting image..."
    mount -o loop "$LOOP_DEV" "$MOUNT_POINT"

    echo "Setup complete."
    echo "Mounted $IMG_FILE at $MOUNT_POINT"
}

# 卸载并清理镜像
cleanup_image() {
    echo "Unmounting image..."
    umount "$MOUNT_POINT" 2>/dev/null || echo "Not mounted, skipping."

    echo "Detaching loop device..."
    LOOP_DEV=$(losetup -j "$IMG_FILE" | awk -F: '{print $1}')
    if [ -n "$LOOP_DEV" ]; then
        losetup -d "$LOOP_DEV"
        echo "Detached loop device: $LOOP_DEV"
    else
        echo "No loop device found for $IMG_FILE"
    fi

    # 删除镜像文件
    if [ -f "$IMG_FILE" ]; then
        echo "Removing image file: $IMG_FILE"
        rm -f "$IMG_FILE"
        echo "Image file removed."
    else
        echo "No image file found to delete."
    fi

    echo "Cleanup complete."
}

# 显示 Reserved block 信息 和 loop 设备绑定信息
show_info() {
    if [ ! -f "$IMG_FILE" ]; then
        echo "Error: Image file $IMG_FILE does not exist!"
        exit 1
    fi

    echo "Reserved block info for $IMG_FILE:"
    tune2fs -l "$IMG_FILE" | grep "Reserved block"

    echo -e "\nLoop device mapping for $IMG_FILE:"
    losetup -j "$IMG_FILE" || echo "No loop device found."
}

# 参数解析
case "$ACTION" in
    -s|setup)
        setup_image
        ;;
    -c|cleanup)
        cleanup_image
        ;;
    -v|show)
        show_info
        ;;
    *)
        usage
        exit 1
        ;;
esac
