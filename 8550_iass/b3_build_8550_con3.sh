#!/bin/sh

create_container() {
    local num=$1
    local name="con$num"
    local innstance="instance$num"
    local adb_port=$((5000 + num))
    local con_ip="192.168.15.$((100 + num))"
    
    docker rm -f "$name" 2>/dev/null
    docker network create --driver=bridge --subnet=192.168.15.0/24 bridge_new 2>/dev/null
    #rm -fr "/data/local/$name"
    
    docker run -d \
        --hostname=${name} \
        --name ${name} \
        --restart=always \
        --memory 8G\
        --memory-swap 10G \
        --platform linux/amd64 \
        --network bridge_new \
        --ip=${con_ip} \
        -p ${adb_port}:5555 \
        -v /data/local/${name}:/data \
        android:latest ${innstance} \
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

}

create_container 3

