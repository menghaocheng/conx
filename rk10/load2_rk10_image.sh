#!/bin/bash

docker system prune -af

#CURT_DATE=20241118
CURT_DATE=$(date  +%Y%m%d)
#CURT_DATE=$(date  +%Y%m%d.%H%M)
#CURT_DATE=20241231
#CURT_DATE=20250828

tar -xvf rk3588_docker-android10-userdebug-super.img-$CURT_DATE.tgz

mkdir -p super_img/root
mount super_img/system.img super_img/root -o rw
mount super_img/product.img super_img/root/product -o rw 
mount super_img/vendor.img super_img/root/vendor -o rw 
mount super_img/odm.img super_img/root/odm -o rw 
#rm super_img/root/vendor/etc/fstab.rk30board

docker rmi rk3588:RK_ANDROID10-RKR10 > /dev/null 2>&1

#tar --xattrs -c -C super_img/root . | sudo docker import -c 'ENTRYPOINT ["/init", "androidboot.hardware=rk30board"]' - rk3588:RK_ANDROID10-RKR10
tar --xattrs -c -C super_img/root . | sudo docker import -c 'ENTRYPOINT ["/init"]' - rk3588:RK_ANDROID10-RKR10


umount super_img/root/product
umount super_img/root/vendor
umount super_img/root/odm
umount super_img/root
rm -rf super_img

