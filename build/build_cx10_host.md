

# 下载
git clone ssh://git@192.168.134.9:2222/host-vir-group/cix_csp1/cix_cs8180.git

# 编译
## 编译debian
source build-scripts/envtool.sh
config -b evb -o 1 -l nvme -t optee -S multi-user -K docker -W 16 -T secure-storage
build all
## 编译kernel
source build-scripts/envtool.sh
config -b evb -o 1 -l nvme -t optee -S multi-user -K docker -W 16 -T secure-storage
build kernel


## 5.打包发布
bash build-scripts/build-release.sh
目标文件在：


---------------------

# 1、docker 宿主机设置:
docker pull ubuntu:20.04
#根据需要修改--name lry-ubuntu20.04-stt 以及-p 2225:22
docker run -itd --name lry-ubuntu20.04-stt -e USER=root --hostname lry-ubuntu --privileged -v /home/liurenyi/docker_data:/mnt/shared -p 2225:22 ubuntu:20.04
docker ps
CONTAINER ID   IMAGE          COMMAND       CREATED       STATUS      PORTS                                   NAMES
f311873cd91d   ubuntu:20.04   "/bin/bash"   3 days ago    Up 3 days   0.0.0.0:2225->22/tcp, :::2225->22/tcp   lry-ubuntu20.04-stt
#配置docker qemu arm跨架构运行：
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker start f311873cd91d
#进入docker环境：
docker exec -it f311873cd91d /bin/bash

# 2、docker 环境编译Cix Debian：
#安装debian 编译依赖库：
apt-get -y update
apt-get -y install lsb-release autoconf autopoint bc bison build-essential cpio curl device-tree-compiler dosfstools doxygen fdisk flex gdisk gettext-base git libncurses5 libssl-dev libtinfo5 m4 mtools pkg-config python2 python3 python3-distutils python3-pyelftools rsync snapd unzip uuid-dev wget scons perl libwayland-dev wayland-protocols indent libtool dwarves libarchive-tools xorriso jigdo-file python3-pip vim sudo parted cmake golang libffi-dev u-boot-tools img2simg libxcb-randr0 libxcb-randr0-dev libxcb-present-dev libxau-dev python3-mako libglib2.0-dev-bin binfmt-support qemu qemu-user-static debootstrap multistrap debian-archive-keyring ser2net git-lfs zstd debhelper jq pigz zip kmod
wget https://bootstrap.pypa.io/pip/3.8/get-pip.py
python3 get-pip.py
pip uninstall pyOpenSSL
pip install --upgrade --force-reinstall 'requests==2.31.0' 'urllib3==1.26.0' 'meson==1.3.0' 'ply==3.11' 'cryptography==41.0.7' 'docutils==0.18.1' openpyxl nexus3-cli launchpadlib pyOpenSSL -i https://pypi.tuna.tsinghua.edu.cn/simple
ln -s /usr/bin/python3 /usr/bin/python

# 3、拉取代码
***********

# 4.编译
## 编译debian
source build-scripts/envtool.sh
config -b evb -o 1 -l nvme -t optee -S multi-user -K docker -W 16 -T secure-storage
build all
## 编译kernel
source build-scripts/envtool.sh
config -b evb -o 1 -l nvme -t optee -S multi-user -K docker -W 16 -T secure-storage
build kernel


## 5.打包发布
bash build-scripts/build-release.sh
目标文件在：