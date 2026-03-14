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
- **最终修复**：在 Android 镜像内通过 `init.rc` 完成容器专属 binder 修正
  - 容器启动参数继续传入 `androidboot.conx_binder_fix=1`
  - 容器创建时额外挂载 `/dev/conx_binder`、`/dev/conx_hwbinder`、`/dev/conx_vndbinder`
  - `device/cix/sky1/sky1_evb/init.rc` 在 `ro.boot.conx_binder_fix=1` 分支中保留 Docker 映射，并在 `on init` 时把标准 `/dev/binder*` 重定向到 `/dev/conx_*`
  - servicemanager / hwservicemanager / vndservicemanager 从启动开始就打开正确的 binder 设备，无需宿主脚本再干预

### 3. Cpuset 子 cgroup

- **现象**：cpuset 子目录（foreground/background/top-app 等）的 cpus/mems 为空，进程无法被调度
- **最终修复**：在 Android 镜像内新增一次性 cpuset 修复服务
  - 新增 `device/cix/sky1/sky1_evb/conx_cpuset_fix.sh`
  - 通过 `device/cix/sky1/sky1_evb/init.docker.rc` 在 `on early-boot && property:ro.boot.conx_binder_fix=1` 时启动 `conx_cpuset_fix`
  - 脚本循环等待 cpuset 子目录出现，并把根 cpuset 的 `cpus/mems` 写入 foreground/background/top-app/system-background/restricted
  - 因为服务由容器内 Android `init` 启动，所以容器每次重启都会自动重新执行，无需宿主脚本再跑 `fix_cpuset`

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
| `myt-cx10/mbx_build_cx10_conX.sh` | 去掉 `PATCHED_INIT` 和 init 挂载（源码已修复 hwcheck）；最终版本只负责创建容器并等待 boot，不再做宿主侧 binder/cpuset 修复 |
| `myt-cx10/load_cx10_image.sh` | 简化为直接在当前目录操作（软链接已解决空间问题） |
| `device/cix/sky1/sky1_evb/init.rc` | 新增 `ro.boot.conx_binder_fix=1` 分支，在镜像内完成 binder 定向 |
| `device/cix/sky1/sky1_evb/init.docker.rc` | 新增 `conx_cpuset_fix` 服务和启动触发 |
| `device/cix/sky1/cix_docker_android.mk` | 把 `conx_cpuset_fix.sh` 打包到 `vendor/bin` |

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

## 最终验证结果

- 新镜像已在设备 A 上重新导入，Docker 镜像 `cix_android:10` 更新成功
- 使用**不含宿主侧 binder/cpuset 兜底**的 `myt-cx10/mbx_build_cx10_conX.sh` 重建 `con4` 后：
  - `docker inspect con4` 状态为 `running|true|0`
  - `getprop sys.boot_completed` 返回 `1`
  - `/dev/binder -> /dev/conx_binder`
  - `/dev/hwbinder -> /dev/conx_hwbinder`
  - `/dev/vndbinder -> /dev/conx_vndbinder`
  - `foreground/background/top-app` 的 `cpuset.cpus` 均为 `0-11`
- 额外验证容器 `con6_nofix` 也在完全不执行宿主修复逻辑的情况下成功启动并 `boot_completed=1`

## 备注

- `push_cx10_script-myt.bat` 负责保证 `/data/local -> /mmc/local`，当前已验证工作正常
- 设备侧 `update_image.sh` 使用 `scp` 拉取镜像时依赖设备上的 SSH 凭据；本次验证改为 Windows 主机直接把新包推送到 `/data/local/sky1_evb-10-user-super.img.tgz`
