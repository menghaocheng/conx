#!/bin/sh


docker rm -f con1 con2 con3 con4 con5

IMAGE=192.168.50.18:5000/cur10:1.0.9
IMAGE=192.168.50.18:5000/caic:2.0.73

#IMAGE=192.168.50.18:5000/menghc:1.0.11

#IMAGE=192.168.110.14:5000/lfl:1.0.test

BUILD_TYP="bridge"
USE_PAUSE="--use-pause 1"

if [ "$1" = "1" ]; then
    BUILD_TYP="ipvlan"
elif [ "$1" = "2" ]; then
	BUILD_TYP="maclan"
fi

#RESTART="--restart no"
RESTART="--restart always"
#RESTART="--restart unless-stopped"
VOLUME="--volume /vendor/bin/busybox:/vendor/bin/busybox --volume /system/bin/ethtool:/system/bin/ethtool "

if [ "$BUILD_TYP" = "bridge" ]; then
	docker run -d -h con3 --name con3 --restart=always --network bridge_new --ip=192.168.15.100 -p 5003:5555 -v /data/local/lxc_instance3:/data android:latest instance3
	docker run -d -h con4 --name con4 --restart=always --network bridge_new --ip=192.168.15.101 -p 5004:5555 -v /data/local/lxc_instance4:/data android:latest instance4
	return
fi

if [ "$BUILD_TYP" = "ipvlan" ]; then
	start_caic.sh -I $IMAGE -i 1 $RESTART $USE_PAUSE --net ipvlannet --ip 192.168.110.101/24 --gateway 192.168.110.1
	start_caic.sh -I $IMAGE -i 2 $RESTART $USE_PAUSE --net ipvlannet --ip 192.168.110.102/24 --gateway 192.168.110.1
	start_caic.sh -I $IMAGE -i 3 $RESTART $USE_PAUSE --net ipvlannet --ip 192.168.110.103/24 --gateway 192.168.110.1
	start_caic.sh -I $IMAGE -i 4 $RESTART $USE_PAUSE --net ipvlannet --ip 192.168.110.104/24 --gateway 192.168.110.1
	start_caic.sh -I $IMAGE -i 5 $RESTART $USE_PAUSE --net ipvlannet --ip 192.168.110.105/24 --gateway 192.168.110.1
fi

