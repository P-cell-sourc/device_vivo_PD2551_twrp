# TWRP Device Tree — iQOO Z11 (PD2551)

> 基于官方全量包逆向参数重建的 TWRP 设备树
> 固件：`2026102202052126bf8bcc2539c42962ab93fde7f4e5be.zip`
> 版本：`PD2551_A_16.0.17.1.W10.V000L1` / `BP2A.250605.031.A3` / Android 16 (SDK 36) / OriginOS 6

## 1. 设备信息

| 项目 | 参数 | 来源 |
| --- | --- | --- |
| 机型 | iQOO Z11（中国版） | 官方固件 |
| 项目代号 | PD2551（硬件 PD2551MA） | `META-INF/com/android/metadata` |
| 平台 | MediaTek **MT6899**（天玑 9500，3nm） | `vendor_boot` DTB `mediatek,MT6899` |
| 主板 | **k6899v1_64** | `lk.img` 字符串 |
| 内核 | **6.6.127**（GKI；模块 vermagic `6.6.127-android15-8-gbd39053f6565-4k`） | `boot.img` / `*.ko` 的 vermagic |
| 屏幕 | 6.31" AMOLED **1216 × 2640**，460ppi，density 560 | `default.prop` / 官方参数 |
| 分区方案 | A/B + Virtual A/B + 动态分区(erofs) | `fstab.mt6899` |
| boot 分区 | 96 MiB (100663296) | 官方 `boot.img` 尺寸 |
| vendor_boot | 128 MiB (134217728) | 官方 `vendor_boot.img` 尺寸 |
| init_boot | 8 MiB (8388608) | 官方 `init_boot.img` 尺寸 |

## 2. 目录结构

```
device/vivo/PD2551/
├── Android.bp / Android.mk / AndroidProducts.mk
├── BoardConfig.mk                     # 全部硬件参数（已按官方镜像校准）
├── device.mk
├── twrp_PD2551.mk                     # lunch 入口：twrp_PD2551-eng
├── system.prop                        # MT6899 / density 560
├── prebuilt/
│   ├── Image                          # 官方 boot.img 中的内核（原样提取）
│   └── dtb.img                        # 官方 vendor_boot.img 中的 DTB（原样提取）
├── recovery/root/
│   ├── first_stage_ramdisk/
│   │   ├── fstab.mt6899               # 官方一阶段 fstab（原样）
│   │   └── system/{bin,lib64}         # 官方一阶段工具链（原样）
│   ├── init.recovery.mt6899.rc        # 显式 import /system/etc/init 下的 HAL 服务 rc
│   ├── init.recovery.touch.rc         # 官方触摸初始化（原样）
│   ├── init.recovery.usb.rc
│   ├── init.recovery.trustonic.rc
│   ├── lib/modules/6.6-gki/*.ko       # 官方 300+ 个内核模块（原样）
│   ├── system/
│   │   ├── bin/prepdecrypt.sh         # 挂载 persist + 触发 crypto.ready
│   │   ├── etc/init/*.rc              # trustonic/tee/gatekeeper/keymint/boot/vibrator 服务定义
│   │   └── etc/recovery.fstab         # 为 PD2551 重写的 TWRP fstab
│   └── vendor/                        # ★ 从官方 vendor 分区提取（108 个文件）
│       ├── app/mcRegistry/            # Trustonic (Kinibi) TEE 固件 63 个（tlbin/drbin/tabin）
│       ├── bin/mcDriverDaemon         # Mobicore 守护进程
│       ├── bin/hw/                    # boot-service.mtk / gatekeeper / keymint / tee-service / vibrator
│       ├── etc/vintf/                 # VINTF 清单（manifest.xml + 6 个片段）
│       ├── firmware/                  # PD2551 触摸固件 + 马达/触感固件（14 个）
│       └── lib64/                     # HAL 依赖库（gatekeeper/keymint/boot/vibrator/libMcClient 等）
```

## 3. 编译

```bash
repo init --depth=1 -u https://github.com/nebrassy/platform_manifest_twrp_aosp.git -b twrp-14.0
repo sync -j$(nproc --all) --force-sync

# 把本目录放到 device/vivo/PD2551
cp -r device_vivo_PD2551  <源码根>/device/vivo/PD2551

source build/envsetup.sh
lunch twrp_PD2551-eng
mka vendorbootimage        # 只出 vendor_boot.img（本机型无独立 recovery 分区）
```

产物：`out/target/product/PD2551/vendor_boot.img`

> 若提示找不到 `bootctrl.mt6899`，把 `device.mk` 里那两行 `bootctrl.*` 注释掉即可，
> 不影响 recovery 正常启动（fastbootd 会回退到通用实现）。

## 4. 刷入

```bash
fastboot flash vendor_boot out/target/product/PD2551/vendor_boot.img
fastboot reboot recovery
```

**不要刷 boot.img**：本机型内核在 `boot` 分区，TWRP 只替换 `vendor_boot` 里的恢复 ramdisk，
保留官方内核 = 最稳的开机组合。

如果开机卡在 logo / 红字验证失败，先关闭 AVB 校验（会清空 userdata，请先备份）：

```bash
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
```

## 5. 核对本机 USB 参数（init.recovery.usb.rc）

`init.recovery.usb.rc` 决定机器在 recovery 下被电脑识别成什么设备。本机真实值如下：

| 项目 | 本机值 | 出处 |
| --- | --- | --- |
| recovery VID | `18D1`（Google） | 官方 recovery ramdisk `default.prop` 的 `ro.recovery.usb.vid` |
| adb PID | `D001` | `ro.recovery.usb.adb.pid` |
| fastbootd PID | `4EE0` | `ro.recovery.usb.fastboot.pid` |
| MTP+ADB PID | `4EE2` | Google 通用值（TWRP 内置） |
| UDC 控制器 | `11201000.usb0` | 官方 `vendor/etc/init/hw/init.mt6899.usb.rc` |

三种查看方式：

```bash
# A. 从官方固件包（不用上机，最直接）
unzip -p 官方包.zip payload.bin > /dev/null   # 或直接解包 vendor_boot 的 ramdisk
grep -aE "ro\.recovery\.usb" default.prop

# B. 在 TWRP 里用 adb 读实机
adb shell getprop | grep -iE "usb"
adb shell cat /init.recovery.usb.rc          # 当前生效的 rc（ramdisk 根目录）
adb shell getprop sys.usb.controller         # 应为 11201000.usb0
adb shell ls /sys/class/udc                  # 列出现有 UDC 名
adb shell cat /sys/class/udc/*/uevent        # 当前 gadget 状态/速率

# C. 在电脑端看枚举结果
lsusb | grep -iE "18d1|2d95|google|vivo"     # Linux
# Windows：设备管理器 → 该设备 → 属性 → 详细信息 → 硬件 ID
#          正常 recovery 应为 USB\VID_18D1&PID_D001（adb）或 VID_18D1&PID_4EE0（fastbootd）
```

> 文件里的 VID/PID 已改为引用属性变量（`0x${ro.recovery.usb.vid}` 等），
> 与 TWRP 官方 `init.rc` 的做法一致，避免写死。若你换了平台/机型，只需改
> `system.prop` 或 ramdisk 的 `default.prop`，不用动 rc。

## 6. 解密链路说明（trustonic vendor 组件）

`recovery/root/vendor/` 全部取自官方固件的 **vendor 分区**（erofs 解包），作用是让
TWRP 里的 `/vendor` 拥有与官方 recovery 相同的 Trustonic 解密环境：

1. `prepdecrypt.sh`（`on fs` 触发）挂载 `persist` 分区并置 `crypto.ready=1`；
2. `crypto.ready=1` 启动 `mobicore`（mcDriverDaemon，加载 30 个官方 drbin 清单）、
   `vendor.gatekeeper-default`、`vendor.keymint-trustonic`；
3. gatekeeper/keymint 服务运行在 `/vendor/bin/hw/`，依赖库由 `vendor/lib64` 提供，
   rc 均已适配为 `user root + seclabel u:r:recovery:s0 + LD_LIBRARY_PATH=/vendor/lib64`。

已知差异：官方 `trustonic.rc` 引用 30 个 drbin，但 vendor 分区只带 12 个（其余在设备
`/mnt/vendor/persist/mcRegistry` 里，不随 OTA 分发）；mcDriverDaemon 对缺失的 `-r` 文件
只记日志不退出，与官方行为一致，无需修改。

## 7. 已知限制

- **解密**：官方使用 trustonic + metadata 加密（`fbe.metadata.wrappedkey=true`），
  TWRP 的 FBE 解密需要与 OS6 keystore 匹配，未实测，可能只能读不能解密 `/data`。
- **AVB**：重新打包后签名失效，需解锁 BL 并关闭校验。
- **super 分区大小**：`BOARD_SUPER_PARTITION_SIZE` 沿用 12.5 GiB 估值（官方 GPT 未在 OTA 中提供），
  仅影响生成 super 镜像，TWRP 运行时会从设备实际读取。
- 屏幕/触摸均为双供应商（BOE RM69260 / VSN IL97605A），`panel_common.ko` 已包含两者。
