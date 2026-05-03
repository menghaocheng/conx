# adbd TCP 安装包说明

这个安装包用于在目标设备上安装可用的 `adbd` 二进制，并将其配置为开机自动以 TCP 模式启动，默认监听端口为 `5555`。

## 包含文件

- `install.sh`：安装 `adbd` 并配置开机自启动
- `uninstall.sh`：卸载开机自启动配置
- `bin/adbd`：已经验证可用的 arm64 `adbd` 二进制
- `lib/libresolv.so.2`：为 glibc 版 `adbd` 提供的随包运行库
- `services/openrc/adbd-tcp`：用于 Alpine/OpenRC 环境的服务脚本
- `services/systemd/adbd-tcp.service`：systemd 环境下的备用服务文件

## 手工使用方法

1. 将整个目录或压缩包推送到目标设备。
2. 如果上传的是压缩包，先解压。
3. 执行 `chmod +x install.sh uninstall.sh`。
4. 使用 `sudo ./install.sh`，或者先执行 `su -` 再执行 `./install.sh`。
5. 在主机侧执行 `adb connect <设备IP>:5555` 验证是否可连。

## Windows 一键脚本

- 可以直接运行 `deploy_adbd_tcp_package.bat`，完成上传、安装和验证。
- 可以直接运行 `uninstall_adbd_tcp_package.bat`，完成上传、卸载和关闭验证。
- 默认目标 IP 从工作区根目录的 `ip.txt` 读取。
- 其余默认参数为：`user myt myt 5555`
- 安装脚本可选参数：`deploy_adbd_tcp_package.bat <host> <ssh-user> <ssh-password> <root-password> <adb-port>`
- 卸载脚本可选参数：`uninstall_adbd_tcp_package.bat <host> <ssh-user> <ssh-password> <root-password> <adb-port>`

## 说明

- 安装脚本会优先使用 OpenRC，其次尝试 systemd，最后回退到 `/etc/local.d`。
- 如果目标设备上已经存在 `/usr/bin/adbd`，且内容不同，安装脚本会先备份旧文件。
- 安装时会把真实二进制放到 `/usr/local/libexec/adbd-tcp/adbd.real`，并在 `/usr/bin/adbd` 安装一个带 `LD_LIBRARY_PATH` 的 wrapper。