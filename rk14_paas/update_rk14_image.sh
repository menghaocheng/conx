#!/bin/sh


#CURT_DATE=20241118
CURT_DATE=$(date  +%Y%m%d)
#CURT_DATE=$(date +%Y%m%d.%H%M)

#scp mhc@192.168.164.2:/vcdev/mhc/build/rk10/Rockchip_RK3588_Android10.0_SDK/IMAGE/RK10_USER_$CURT_DATE/IMAGES/rk3588_docker-android10-user-super.img-$CURT_DATE.tgz .

#scp mhc@192.168.163.2:/home/mhc/56T/rk12_yk/RK3588_12_Vir/IMAGE/RK10_USER_$CURT_DATE/IMAGES/rk3588_docker-android12-userdebug-super.img-$CURT_DATE.tgz .

#scp mhc@192.168.164.2:/home/mhc/56T/rk12_yk/RK3588_12_Vir/IMAGE/RK12_USERDEBUG_$CURT_DATE/IMAGES/rk3588_docker-android12-userdebug-super.img-$CURT_DATE.tgz .
#scp mhc@192.168.164.2:/home/mhc/56T/rk14/RK3588_14_Vir/IMAGE/RK3588_DOCKER_ANDROID14_USERDEBUG_$CURT_DATE/IMAGES/rk3588_docker-android14-userdebug-super.img-$CURT_DATE.tgz .
#scp mhc@192.168.164.2:/home/mhc/56T/rk14/RK3588_14_Vir/IMAGE/RK3588_AIC_ANDROID14_USER_$CURT_DATE/IMAGES/container/rk3588_aic-android14-user-super.img-$CURT_DATE.tgz
scp mhc@192.168.164.2:/home/mhc/56T/rk14/RK3588_14_Vir/IMAGE/RK3588_AIC_ANDROID14_USER_$CURT_DATE/IMAGES/container/rk3588_aic-android14-user-super.img-$CURT_DATE.tgz .



#scp mhc@192.168.164.2:/vcdev/mhc/build/rk12/RK3588_android12.0_vir/IMAGE/RK12_USERDEBUG_$CURT_DATE/IMAGES/rk3588_docker-android12-userdebug-super.img-$CURT_DATE.tgz .

#scp mhc@192.168.164.2:/home/mhc/56T/rkhost/RK3588_linux_ruichi-new/rockdev/boot.img .
