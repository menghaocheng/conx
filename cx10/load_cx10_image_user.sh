#!/bin/bash

CURT_DATE=$(date  +%Y%m%d)
#CURT_DATE=$(date  +%Y%m%d.%H%M)
#CURT_DATE=20250828

tar -xvf sky1_evb-10-user-super.img.tgz

mkdir -p super_img/root
mount super_img/system_a.img super_img/root -o rw
# mount super_img/system_ext_a.img super_img/root/system_ext -o rw
mount super_img/product_a.img super_img/root/product -o rw
mount super_img/vendor_a.img super_img/root/vendor -o rw
rm super_img/root/vendor/etc/fstab.cix

docker rmi -f cix_android:10

tar --xattrs -c -C super_img/root . | docker import -c 'ENTRYPOINT ["/init", "androidboot.hardware=cix"]' - cix_android:10

#umount super_img/root/system_ext #安卓10无需执行这行
umount super_img/root/product
umount super_img/root/vendor
umount super_img/root
rm -rf super_img

