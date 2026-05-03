(以上from zhutao)

代码仓库：

le部分：

ssh://git@192.168.134.9:2222/android-vir-group/qcom8550/thunder\_8550/android13\_le.git

qssi部分：

ssh://git@192.168.134.9:2222/android-vir-group/qcom8550/thunder\_8550/android13\_qssi.git

vendor部分：

ssh://git@192.168.134.9:2222/android-vir-group/qcom8550/thunder\_8550/android13\_vendor.git

容器分支：main

宿主分支：main\_host

编译步骤参考：[http://192.168.31.65:9090/pages/viewpage.action?pageId=3113029](http://192.168.31.65:9090/pages/viewpage.action?pageId=3113029)

注：8550代码需要在容器内编译

git clone ssh://git@192.168.134.9:2222/android-vir-group/qcom8550/thunder_8550/android13_le.git

# 一、下载

#下载

```
git clone ssh://git@192.168.134.9:2222/android-vir-group/qcom8550/thunder_8550/android13_le.git le
git clone ssh://git@192.168.134.9:2222/android-vir-group/qcom8550/thunder\_8550/android13\_qssi.git qssi
git clone ssh://git@192.168.134.9:2222/android-vir-group/qcom8550/thunder\_8550/android13\_vendor.git vendor
```

#切换分支

```
cd le && git checkout master&& cd -
cd qssi && git checkout main&& cd -
cd vendor && git checkout main && cd -
cd vendor
```

#创建连接

```
ln -sf ../le/LE.UM.6.3.3 LE.UM.6.3.3
ln -sf ../qssi/LA.QSSI.13.0 LA.QSSI.13.0
mkdir BP-CODE && cd BP-CODE

ln -sf ../../qssi/LA.QSSI.13.0 LA.QSSI.13.0
ln -sf ../../le/LE.UM.6.3.3 LE.UM.6.3.3
ln -sf ../LA.VENDOR.13.2.6 LA.VENDOR.13.2.6
ln -sf ../turbox/tools/build_script/device/build_c8550_ap.sh build_c8550_ap.sh
```

# 二、编译

## 编译容器

```
make_image.sh --build mp
```

## 编译宿主

#全量编译
cd vendor/BP-CODE
echo "./build_c8550_ap.sh --all 2>&1 | tee all_build.log" > make.sh
chmod 777 make.sh
#编译vendor部分
./build_c8550_ap.sh --vendor_target 2>&1 | tee vendor_build.log
#编译qssi部分
./build_c8550_ap.sh --qssi 2>&1 | tee qssi_build.log
#单编模块示例
make -j16 framework-minus-apex
#打包刷机包
cd vendor
./packVersion.sh
生成的镜像在：outVersion/VC.2024XXXX.XXX

# 三、打包

```
cd vendor
./packVersion.sh
```
最终，上述步骤打包的文件将放在outVersion 路径，名称以build/make/core/build\_id.mk 中的BUILD\_ID 为基准
