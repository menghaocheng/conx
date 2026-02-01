#!/bin/bash

docker system prune -af

CURT_DATE=$(date  +%Y%m%d)
#CURT_DATE=20250214.0956

tar -xvf rk3588_aic-android14-user-super.img-$CURT_DATE.tgz


mkdir super_img/root
mount super_img/system.img super_img/root -o rw
mount super_img/odm_dlkm.img super_img/root/odm_dlkm -o rw
mount super_img/odm.img super_img/root/odm -o rw
mount super_img/product.img super_img/root/product -o rw
mount super_img/system_dlkm.img super_img/root/system_dlkm -o rw
mount super_img/system_ext.img super_img/root/system_ext -o rw
mount super_img/vendor_dlkm.img super_img/root/vendor_dlkm -o rw
mount super_img/vendor.img super_img/root/vendor -o rw


docker rmi rk3588:ANDROID14_RKR14
tar --xattrs -c -C super_img/root . | sudo docker import -c 'ENTRYPOINT ["/init", "androidboot.hardware=rk30board"]' - rk3588:ANDROID14_RKR14

umount super_img/root/product
umount super_img/root/vendor
umount super_img/root/vendor_dlkm
umount super_img/root/odm
umount super_img/root/odm_dlkm
umount super_img/root/system_dlkm
umount super_img/root/system_ext
umount super_img/root
rm -rf super_img