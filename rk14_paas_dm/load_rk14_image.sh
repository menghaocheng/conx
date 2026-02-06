#!/bin/bash

docker system prune -af

CURT_DATE=$(date  +%Y%m%d)
#CURT_DATE=20250214.0956

tar zxvf rk3588_aic-android14-user-super.img-$CURT_DATE.tgz


tar --xattrs -c -C super_img . | sudo docker import -c 'ENTRYPOINT ["/init", "androidboot.hardware=rk30board"]' - rk3588:ANDROID14_RKR14_DM