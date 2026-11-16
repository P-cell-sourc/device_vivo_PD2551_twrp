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

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/embedded.mk)
$(call inherit-product, vendor/twrp/config/common.mk)
$(call inherit-product, device/vivo/PD2551/device.mk)

PRODUCT_DEVICE := PD2551
PRODUCT_NAME := twrp_PD2551
PRODUCT_BRAND := vivo
PRODUCT_MODEL := vivo X300
PRODUCT_MANUFACTURER := vivo
PRODUCT_RELEASE_NAME := PD2551

PRODUCT_GMS_CLIENTID_BASE := android-vivo

TARGET_VENDOR := vivo
TARGET_VENDOR_PRODUCT_NAME := PD2551
TARGET_VENDOR_DEVICE_NAME := PD2551
