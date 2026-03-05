
# host编译
编译流程：
一、编译类型
source envsetup.sh
选择
rockchip_rk3588（42）

如果要编译recovery，就要分类
1.SSD
46. rockchip_rk3588_recovery_ssd
2.emmc（s）
45. rockchip_rk3588_recovery

二、编译版本（ssd、emmc、emmcs）
./build.sh lunch
区分板卡类型
ssd
7. BoardConfig-rk3588-vc-ssd.mk
emmc
6. BoardConfig-rk3588-vc-emmc.mk
emmcs
9. BoardConfig-rk3588s-vc-emmc.mk

三、分别编译kern、uboot、debian
./build.sh kernel
./build.sh uboot
./build.sh debian
debian生成如下文件
/RK3588_linux_ruichi-new/debian/linaro-rootfs.img

四、编译recovery
1、按照一和二切换
./build.sh recovery

五、编译系统
1、按照一和二切换
2、瑞驰部分：
cd sys_pack
sudo ./auto_sys.sh
cd ../rockdev/
sudo umount chroot_pack/ -l/
3、中台部分：
cd sys_pack_zhongtai/
sudo ./auto_sys.sh
cd ../rockdev/
sudo chroot chroot_pack/.
./auto_chroot.sh
exit
sudo umount chroot_pack/ -l

六、编译整包
1、查看打包指令./build.sh shdvdh
2、编译ota
./build.sh otapackage
生成如下
update_ota.img
3、编译烧录包
./build.sh updateimg
生成如下
update_ab.img
4、编译烧录包和ota
./build.sh autopack
生成路径：
/RK3588_linux_ruichi-new/rockdev

# from ymx
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