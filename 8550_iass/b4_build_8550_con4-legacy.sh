#!/bin/sh

index=4


if [ "$1" != "" ]; then
    index=$1
fi

BUILD_TYP="bridge"
if [ "$2" = "1" ]; then
    BUILD_TYP="ipvlan"
elif [ "$2" = "2" ]; then
    BUILD_TYP="macvlan"
fi

docker rm -f con$index

#IMAGE=192.168.50.18:5000/menghc:1.0.11
#IMAGE=192.168.110.14:5000/menghc:1.0.11
#IMAGE=192.168.50.18:5000/caic:2.0.71
#IMAGE=192.168.50.18:5000/qsandroid:1.0.145


#IMAGE=192.168.50.18:5000/menghc:1.0.11
#IMAGE=192.168.110.14:5000/lfl:1.0.test
#IMAGE=192.168.110.14:5000/caic-cr10t-mhc:1.0.m13

#RESTART="--restart no"
#RESTART="--restart always"
#RESTART="--restart unless-stopped"

#ENV
#ENV="$ENV -e "HELLO1=Wrold1" -e "HELLO2=Wrold2""

#VOLUME
#VOLUME="$VOLUME -v /vendor/bin/busybox:/vendor/bin/busybox"
#VOLUME="$VOLUME -v /system/bin/ethtool:/system/bin/ethtool"
#VOLUME="$VOLUME -v /data/cce/data/common.prop:/product/common.prop"
#VOLUME="$VOLUME -v /data/testapp:/oem/app"

#--volume /data/cce/data/cmdline:/proc/cmdline --volume /data/cce/data/version:/proc/version"


#START_CAIC=start_caic.sh
#START_CAIC=start_caic_pause.sh

#USE_PAUSE="--use-pause 1"
# --blkio-weight 510


#PASSTHROU="$PASSTHROU --mac f8:02:77:9c:22:26"
#docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_new

#docker run -d -h con3 --name con3 --restart=always --network bridge_new --ip=192.168.15.100 -p 5003:5555 -v /data/local/lxc_instance3:/data android:latest instance3
if [ "$BUILD_TYP" = "bridge" ]; then
    #docker run -d -h con3 --name con3 --restart=always --network bridge_new --ip=192.168.15.100 -p 5003:5555 -v /data/local/lxc_instance3:/data android:latest instance3 11:26 ro.boot.virtdroid_width=1020 ro.boot.virtdroid_height=2280
    #docker run -d -h con4 --name con4 --restart=always --network bridge_new --ip=192.168.15.101 -p 5004:5555 -v /data/local/lxc_instance4:/data android:latest instance4 11:26 ro.boot.virtdroid_width=1020 ro.boot.virtdroid_height=2280
    #docker run -d -h con4 --name con5 --restart=always --network bridge_new -p 5004:5555 -v /data/local/lxc_instance5:/data android:latest instance5
    docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_new > /dev/null 2>&1

docker run -d -h con4 \
    --name con4 \
    --platform=linux/amd64 \
    --restart=always \
    --network bridge_new \
    --ip=192.168.15.104 \
    -p 5004:5555 \
    -v /data/local/con4:/data \
    android:latest instance4 \
    ro.boot.virtdroid_width=1080 \
    ro.boot.virtdroid_height=1920 \
    ro.oem.product.manufacturer=GGG \
    ro.oem.board.platform=HHH \
    ro.product.board=AAA \
    ro.product.brand=BBB \
    ro.product.device=CCC \
    ro.product.manufacturer=DDD \
    ro.product.model=EEE \
    ro.product.name=FFF \ 
    ro.hello=world \
    persist.navbar.status=1 \


    #ro.boot.virtdroid_width=1920 \
    #ro.boot.virtdroid_height=1080 \

    #-m 8G \
    #--cpus=8 \	
    #ro.boot.virtdroid_width=1920 \
    #ro.boot.virtdroid_height=1080 \

    #ro.boot.virtdroid_width=1080 ro.boot.virtdroid_height=1920

#	docker run -d -h con4 \
#		--name con4 \
#		--restart=always \
#		--network bridge_new \
#		--ip=192.168.15.100 \
#		--privileged \
#		-v /data/local/build.prop:/product/etc/build.prop \
#		-v /data/android_data/data_4:/data \
#		-v /system_ext:/system_ext \
#		-v /metadata:/metadata \
#		-v /system_dlkm:/system_dlkm \
#		-v /vendor/dsp:/vendor/dsp \
#		-v /vendor_dlkm:/vendor_dlkm \
#		--env persist.container.is=4 \
#		android:latest
	
#S版本	
#	docker create -it \
#		--restart=always \
#		--platform linux/amd64 \
#		--name=con4 \
#		--network=bridge_new \
#		--ip=192.168.15.100 \
#		--hostname=con4 \
#		--privileged \
#		-v /data/local/build.prop:/product/etc/build.prop \
#		-v /data/android_data/data_4:/data \
#		-v /system_ext:/system_ext \
#		-v /metadata:/metadata \
#		-v /system_dlkm:/system_dlkm \
#		-v /vendor/dsp:/vendor/dsp \
#		-v /vendor_dlkm:/vendor_dlkm \
#		--env PATH=$PATH \
#		--env persist.container.is=4 \
#		android:latest
#	docker start con4
	return
fi

		#-v /data/local/build.prop:/product/etc/build.prop \

#docker network create -d ipvlan --subnet=192.168.16.0/24 --gateway=192.168.16.1 -o ipvlan_mode=l2 -o parent=eth0 ipvlan

if [ "$BUILD_TYP" = "ipvlan" ]; then
	#con_gateway=192.168.11.1 \
	#con_dns1=114.114.114.114 \
	#con_dns2=223.5.5.5 \
	#con_storage=32768 \
	#docker container create -h con4 \
	#--name con4 \
	#--memory=7784628224 \
	#--ip=192.168.11.100 \
	#--platform linux/amd64 \
	#--restart=always \
	#--network ipvlan \
#	-v /data/local/lxc_instance4:/data \
#	android:latest instance4 \
#	ro.instance.id=QS8519E1302300447_60a76de6-71f4-43c2-aae7-41e7fe88948c \
#	ro.boot.virtdroid_width=1920 \
#	ro.boot.virtdroid_height=1080 \
#	ro.sf.lcd_density=360 \
#	persist.instance.alias=QS8519E1302300447_60a76de6-71f4-43c2-aae7-41e7fe88948c
	
	con_gateway=192.168.16.1 \
	con_dns1=114.114.114.114 \
	con_dns2=223.5.5.5 \
	docker container create -h con4 \
	--name con4 \
	--ip=192.168.11.100 \
	--platform linux/amd64 \
	--restart=always \
	--network ipvlan \
	-v /data/local/lxc_instance4:/data \
	android:latest instance4

	
	#docker network create -d ipvlan --subnet=192.168.11.0/24 --gateway=192.168.11.1 -o ipvlan_mode=l2 -o parent=eth0 ipvlan
	
#	docker create -it  \
#		--platform linux/amd64 \
#		--name=con4 \
#		--hostname=con4 \
#		--privileged \
#		-v /data/android_data/data_4:/data \
#		--network=ipvlan \
#		--ip=192.168.11.211 \
#		--cpus=6 \
#		--memory=5120M \
#		--dns=114.114.114.114 \
#		--env PATH=$PATH \
#		--env persist.container.ip=192.168.11.211/21 \
#		--env persist.container.gateway=192.168.11.1 \
#		--env persist.container.dns1=114.114.114.114 \
#		--env persist.container.dns2="114.114.114.114" \
#		--env persist.container.is=4 \
#		--env ro.vc.serialno=123456 \
#		android:latest sh
#	
	docker start con4
	return
	
fi

#qs8550:1 instance4 \

if [ "$BUILD_TYP" = "macvlan" ]; then
    docker create -it  \
        --platform linux/amd64 \
        --name=con4 \
        --hostname=con4 \
        --privileged \
        -v /data/android_data/data_4:/data \
        -v /system_ext:/system_ext \
        -v /metadata:/metadata \
        -v /system_dlkm:/system_dlkm \
        -v /vendor/dsp:/vendor/dsp \
        -v /vendor_dlkm:/vendor_dlkm \
        -v /data/local/build.prop:/product/build.prop \
        --network=macvlan \
        --ip=192.168.11.211 \
        --cpus=6 \
        --memory=5120M \
        --mac-address 02:82:c0:b8:be:38 \
        --dns=114.114.114.114 \
        --env PATH=$PATH \
        --env persist.container.ip=192.168.11.211/21 \
        --env persist.container.gateway=192.168.11.1 \
        --env persist.container.dns1=114.114.114.114 \
        --env persist.container.dns2="114.114.114.114" \
        --env persist.container.is=4 \
        --env ro.vc.serialno=123456 \
        android:latest sh
	docker start con4
	return
fi




