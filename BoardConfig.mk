# Copyright (C) 2026 The TWRP Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# vivo X300 (PD2551) / MT6899 (Dimensity 9500) / Android 16 (OriginOS 6)
# 所有硬件参数均取自官方全量包：
#   2026102202052126bf8bcc2539c42962ab93fde7f4e5be.zip
#   (PD2551_A_16.0.17.1.W10.V000L1 / BP2A.250605.031.A3 / SDK 36)

DEVICE_PATH := device/vivo/PD2551

# For building with minimal manifest
ALLOW_MISSING_DEPENDENCIES := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_PLUGIN_VALIDATION      := soong-libaosprecovery_defaults soong-libguitwrp_defaults soong-libminuitwrp_defaults soong-vold_defaults

# A/B + Virtual A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    system \
    system_ext \
    vendor \
    product \
    odm \
    odm_dlkm \
    system_dlkm \
    vendor_dlkm \
    boot \
    init_boot \
    dtbo \
    vbmeta_system \
    vbmeta_vendor \
    lk \
    vendor_boot

BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_USES_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
TARGET_NO_RECOVERY := true

# Architecture (CPU: 1x4.21G C1-Ultra + 3x3.5G + 4x2.7G, ARMv9.2)
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a55

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# Bootloader  (lk.img 内字符串确认为 k6899v1_64)
TARGET_BOOTLOADER_BOARD_NAME := k6899v1_64
TARGET_NO_BOOTLOADER := true
TARGET_USES_UEFI := true

# Display  6.31" AMOLED 1216x2640 460ppi / ro.sf.lcd_density=560
TARGET_SCREEN_DENSITY := 560
TARGET_SCREEN_WIDTH := 1216
TARGET_SCREEN_HEIGHT := 2640

# Platform
BOARD_USES_MTK_HARDWARE := true
TARGET_BOARD_PLATFORM := mt6899
PLATFORM_SECURITY_PATCH := 2099-12-31
PLATFORM_VERSION := 99.87.36
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)

# Vendor Security Patch
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

# Kernel
# stock boot.img: kernel_addr 0x40000000, ramdisk_addr 0x66F00000, tags/dtb 0x47C80000
BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_BASE := 0x3fff8000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x26f08000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_TAGS_OFFSET := 0x07c88000
BOARD_DTB_OFFSET := 0x07c88000
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2
BOARD_KERNEL_CMDLINE += erofs.reserved_pages=256
BOARD_KERNEL_CMDLINE += product.version=PD2551_A_16.0.17.1.W10
# 官方 vendor_boot 内 cmdline 实际仍是 15/AP3A...（厂商未随 A16 同步），此处与其保持逐字一致
BOARD_KERNEL_CMDLINE += fingerprint.abbr=15/AP3A.240905.015.A2
BOARD_KERNEL_CMDLINE += region_ver=W10
BOARD_KERNEL_CMDLINE += product.solution=MTK
BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)
BOARD_RAMDISK_USE_LZ4 := true
BOARD_KERNEL_IMAGE_NAME := Image

# Kernel / DTB - prebuilt (从官方 boot.img / vendor_boot.img 提取)
TARGET_FORCE_PREBUILT_KERNEL := true
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
BOARD_MKBOOTIMG_ARGS += --dtb $(TARGET_PREBUILT_DTB)
BOARD_KERNEL_SEPARATED_DTBO := true
BOARD_INCLUDE_DTB_IN_BOOTIMG :=

# Filesystem
BOARD_HAS_LARGE_FILESYSTEM := true
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_EROFS := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs

# Partitions  (boot/vendor_boot/init_boot 大小取自官方镜像实际尺寸)
BOARD_FLASH_BLOCK_SIZE := 262144 # (kernel_pagesize * 64)
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 134217728
BOARD_INIT_BOOTIMAGE_PARTITION_SIZE := 8388608
BOARD_DTBOIMG_PARTITION_SIZE := 8388608

# Dynamic Partition
BOARD_SUPER_PARTITION_SIZE := 13421772800
BOARD_SUPER_PARTITION_GROUPS := main
BOARD_MAIN_SIZE := 13419675648
BOARD_MAIN_LIST := \
    system \
    system_ext \
    vendor \
    product \
    odm

# Workaround for error copying vendor and product files to recovery ramdisk
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm
TARGET_COPY_OUT_ODM := odm

# Metadata
BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata

# System as root
BOARD_SUPPRESS_SECURE_ERASE := true

# AVB
# AVB 保持开启：vendor_boot 必须带 AVB footer。
# MTK 的 lk 在加载 vendor_boot 时依赖 footer 判断镜像完整性，
# 缺 footer 会直接判定镜像无效，连 bootloader 阶段都过不去。
# hash 与原厂 vbmeta 不匹配的问题，靠刷入 flags=3 的 vbmeta.img 解决
# （bootloader 会跳过 hashtree 与 verification 两项校验）。
# 注意：下面这些 chained 变量要保留，删掉会让 fsgen 在 bootstrap 阶段
# 报 "No key found for chained avb partition"，那是另一个错误。
BOARD_AVB_ENABLE := true
# flags 位：1 = hashtree 校验关闭，2 = verification 关闭，3 = 两者都关
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3

# !! system 不能写进 BOARD_AVB_VBMETA_SYSTEM !!
#   build/make/core/Makefile 的 check-and-set-avb-args：
#     若分区既定义了 BOARD_AVB_<P>_KEY_PATH，又出现在 chained vbmeta 列表里 →
#       error: Chaining partition "system" in chained VBMeta image is not supported
#   AOSP 的约定是 system 由**顶层** vbmeta 直接 chain（见下面的 BOARD_AVB_SYSTEM_*），
#   BOARD_AVB_VBMETA_SYSTEM 只列真正住在 vbmeta_system 里的分区（system_ext/product 等）。
#   本设备只产出 vendor_boot.img，vbmeta_system 不参与刷机，留空最稳。
# chained partition 自身仍需 KEY_PATH + ALGORITHM，否则 soong bootstrap 阶段会报
#   fsgen: No key found for chained avb partition "vbmeta_system"
BOARD_AVB_VBMETA_SYSTEM :=
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 1

# system：顶层 vbmeta 直接 chain（不在 vbmeta_system 里）
BOARD_AVB_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_VENDOR_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VENDOR_BOOT_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VENDOR_BOOT_ROLLBACK_INDEX := 0
BOARD_AVB_VENDOR_BOOT_ROLLBACK_INDEX_LOCATION := 3

# TWRP specific build flags
TW_THEME := portrait_hdpi
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TW_EXTRA_LANGUAGES := true
TW_DEFAULT_LANGUAGE := zh_CN
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_EXCLUDE_APEX := true
TW_USE_TOOLBOX := true
TW_INCLUDE_REPACKTOOLS := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true

TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true
TW_DEVICE_VERSION := IQOO Z11
TW_SCREEN_BLANK_ON_BOOT := true
TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_HAS_MTP := true
RECOVERY_SDCARD_ON_DATA := true
TW_EXCLUDE_TWRPAPP := true
TW_INCLUDE_FB2PNG := true
TARGET_USES_MKE2FS := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 2047

# FastbootD
TW_INCLUDE_FASTBOOTD := true

# Fuse
TW_INCLUDE_NTFS_3G    := true
TW_INCLUDE_FUSE_EXFAT := true
TW_INCLUDE_FUSE_NTFS  := true

# Props
TARGET_SYSTEM_PROP := $(DEVICE_PATH)/system.prop

# Crypto
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
TW_PREPARE_DATA_MEDIA_EARLY := true
# Android 12+ 的 /data 使用 fscrypt policy v2；漏掉这行会表现为输入密码后
# 一直转圈或直接挂载失败，而不是明确报错
TW_USE_FSCRYPT_POLICY := 2

# StatusBar
TW_STATUS_ICONS_ALIGN := center
TW_CUSTOM_CLOCK_POS := 590

# AIDL
TW_SUPPORT_INPUT_AIDL_HAPTICS := true

# Fix fastboot reboot
TW_NO_FASTBOOT_BOOT := true
