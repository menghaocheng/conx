

# 下载
git clone http://192.168.32.253:3000/vc_driver/RK3588_linux_ruichi-new.git


# 环境

sudo apt install mtools


# 编译

分支：Virtual_card
编译步骤和命令：
1、编译环境初始化
$ source envsetup.sh
选择 42 rockchip_rk3588
$ ./build.sh lunch
此时选择相对应的配置编译，如下： 
0. default BoardConfig.mk
1. BoardConfig-ab-base.mk
2. BoardConfig-ab-recovery-base.mk
3. BoardConfig-rk3588-evb1-lp4-v10.mk
4. BoardConfig-rk3588-evb3-lp5-v10.mk
5. BoardConfig-rk3588-evb7-lp4-v10.mk
6. BoardConfig-rk3588-vc-emmc.mk //选这个
7. BoardConfig-rk3588-vc-ssd.mk   
8. BoardConfig-rk3588s-evb1-lp4x-v10.mk
9. BoardConfig-rk3588s-vc-emmc.mk
10. BoardConfig-security-base.mk
11. BoardConfig.mk
选择：BoardConfig-rk3588-vc-emmc.mk

./build.sh kernel