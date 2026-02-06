#!/bin/sh

#CURT_DATE=20250305
#CURT_DATE=$(date  +%Y%m%d)
#CURT_DATE=$(date  +%Y%m%d.%H%M)

#VERSION=VC.20260104.006

# scp mhc@192.168.164.2:/home/mhc/56T/cx10/android10/IMAGE/${VERSION}-mp_user_${CURT_DATE}/sky1_evb-10-user-super.img.tgz .
scp mhc@192.168.164.2:/home/mhc/56T/cx10/android10/out/target/product/sky1_evb/images/sky1_evb-10-user-super.img.tgz .