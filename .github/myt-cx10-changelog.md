# MYT-CX10 容器方案修改记录

## 背景

在 MYT 硬件设备 A（192.168.11.40:5555）上运行 `cix_android:10` Docker 容器。
该镜像原本只能在 CIX 硬件设备 B（192.168.11.25:5555）上运行。

## 核心问题及修复

### 1. hwcheck 硬件检查（已在源码层面修复）

- **现象**：init 进程调用 `hwcheck()` 检测硬件平台，MYT 硬件检查失败 → init 直接退出
- **早期方案**：二进制补丁 init（NOP 掉 0x2417c、0x24180），通过 `-v /data/local/cix_init_patched:/system/bin/init` 挂载
- **最终方案**：在 Android 源码中屏蔽 hwcheck，重新编译镜像，无需补丁和挂载

### 2. Binder 设备隔离

- **现象**：`--privileged` 模式暴露宿主所有 binder 设备（72+个），容器内 servicemanager 打开错误的全局 `/dev/binder`（minor 119），导致服务注册冲突、crash 循环
- **修复**：容器启动后立即替换 binder 设备节点为容器专属设备，并重启 servicemanager
  - 删除所有泄漏的 `/dev/binder*` 设备
  - 用 `mknod` 创建正确的 binder/hwbinder/vndbinder（从 `/proc/misc` 获取 minor 号）
  - `setprop ctl.restart servicemanager/hwservicemanager/vndservicemanager` 强制重新打开正确的 binder fd

### 3. Cpuset 子 cgroup

- **现象**：cpuset 子目录（foreground/background/top-app 等）的 cpus/mems 为空，进程无法被调度
- **修复**：从父 cpuset 读取 cpus/mems 填充到所有子目录

### 4. 磁盘空间不足

- **现象**：根分区 `/` 仅 5.8G，导入镜像时解压 865MB tgz + mount img 超出剩余空间
- **修复**：创建软链接 `/data/local` → `/mmc/local`，利用 NVMe 分区（463G）

## 文件变更清单

### 新增

| 文件 | 说明 |
|------|------|
| `myt-cx10/` 目录 | MYT 硬件专用脚本目录（从 cx10/ 分离） |
| `myt-cx10/mbx_build_cx10_conX.sh` | 核心创建脚本，参数化容器编号，包含 binder/cpuset 修复 |
| `myt-cx10/mb1~mb15_build_cx10_conN.sh` | 各容器的 wrapper 脚本，调用 `./mbx_build_cx10_conX.sh N` |
| `myt-cx10/update_image.sh` | 从编译服务器 scp 获取镜像包 |
| `myt-cx10/load_cx10_image.sh` | 解压 super.img 并 docker import 为 cix_android:10 |
| `push_cx10_script-myt.bat` | Windows 端推送脚本，含自动创建 `/data/local` → `/mmc/local` 软链接 |

### 修改

| 文件 | 变更 |
|------|------|
| `ip_port.txt` | 更新为 `192.168.11.40:5555` |
| `myt-cx10/mbx_build_cx10_conX.sh` | 去掉 `PATCHED_INIT` 和 init 挂载（源码已修复 hwcheck） |
| `myt-cx10/load_cx10_image.sh` | 简化为直接在当前目录操作（软链接已解决空间问题） |

## 容器参数计算规则

`create_container N` 自动计算：

| 参数 | 公式 | 示例 (N=4) |
|------|------|------------|
| 名称 | `conN` | con4 |
| ADB 端口 | `5000 + N` | 5004 |
| MAC | `f0:d7:af:c4:65:(0x40+N)` | f0:d7:af:c4:65:44 |
| binder | `binder[(N-1)*3+1]` | binder10 |
| hwbinder | `binder[(N-1)*3+2]` | binder11 |
| vndbinder | `binder[(N-1)*3+3]` | binder12 |
| 数据目录 | `/data/local/conN:/data` | /data/local/con4:/data |

## 部署步骤

```bash
# 1. Windows 端推送脚本（自动创建软链接）
push_cx10_script-myt.bat

# 2. 设备上导入镜像
cd /data/local
./update_image.sh      # scp 获取 super.img.tgz
./load_cx10_image.sh   # 解压并 docker import

# 3. 创建容器
./mb4_build_cx10_con4.sh   # 或直接 ./mbx_build_cx10_conX.sh 4
```
