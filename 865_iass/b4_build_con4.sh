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
	if [ "$(docker network ls|grep bridge_new)" == "" ]; then
	    echo "create bridge_new"
		docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_new
	fi
	#docker run -d -h con3 --name con3 --restart=always --network bridge_new --ip=192.168.15.100 -p 5003:5555 -v /data/local/lxc_instance3:/data android:latest instance3 11:26 ro.boot.virtdroid_width=1020 ro.boot.virtdroid_height=2280
	#docker run -d -h con4 --name con4 --restart=always --network bridge_new --ip=192.168.15.101 -p 5004:5555 -v /data/local/lxc_instance4:/data android:latest instance4 11:26 ro.boot.virtdroid_width=1020 ro.boot.virtdroid_height=2280
	#docker run -d -h con4 --name con5 --restart=always --network bridge_new -p 5004:5555 -v /data/local/lxc_instance5:/data android:latest instance5
	
	docker run -d -h con4 \
		--name con4 \
		--restart=always \
		--network bridge_new \
		--ip=192.168.15.100 \
		-v /data/local/con4:/data \
		-v /var/lib/lxcfs/proc/cpuinfo:/proc/cpuinfo:rw  \
		-v /var/lib/lxcfs/proc/diskstats:/proc/diskstats:rw   \
		-v /var/lib/lxcfs/proc/meminfo:/proc/meminfo:rw   \
		-v /var/lib/lxcfs/proc/stat:/proc/stat:rw  \
		-v /var/lib/lxcfs/proc/swaps:/proc/swaps:rw  \
		-v /var/lib/lxcfs/proc/uptime:/proc/uptime:rw \
		-p 5004:5555 \
		android:latest instance4

 #ro.boot.virtdroid_width=1920 ro.boot.virtdroid_height=1080

#-p 5004:5555 \
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


if [ "$BUILD_TYP" = "ipvlan" ]; then
	/data/bin/agent_getinfo Set_network_mode ipvlan
	
	con_ip=192.168.11.99/24 \
	con_gateway=192.168.11.1  \
	docker container create -h con4 \
	--name con4 \
	--restart=always \
	--network ipvlan \
	-v /data/local/con4:/data \
	android:latest instance4 \

	docker start con4

fi

if [ "$BUILD_TYP" = "macvlan" ]; then
    /data/bin/agent_getinfo Set_network_mode macvlan
	
	con_ip=192.168.11.211/24 \
	con_gateway=192.168.203.1 \
	con_dns1=8.8.8.8 \
	con_dns2=114.114.114.114 \
	docker container create \
		-h con4 --name con4 \
		--ip 192.168.11.211 \
		--mac-address=02:82:c0:b8:be:38 \
		--restart=always \
		--network macvlan \
		-v /data/local/con4:/data \
		android:latest instance1

	docker start con4
	return
fi


