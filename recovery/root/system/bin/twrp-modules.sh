#!/system/bin/sh
# [twrp-builder-fix] 由 twrp-builder 生成：加载 /lib/modules/<kver>/ 下的 vendor 内核模块
# 不加载它们的话：没有 mediatek-drm.ko → 无显示；没有 extcon-mtk-usb.ko → 无 adb。
#
# 为什么需要这个脚本：
#   MTK 把 .ko 放在 /lib/modules/6.6-gki/ 下，而 AOSP first stage init 只认
#   /lib/modules/<name>.ko 这种平铺路径，报 "module bootprof can't be loaded"，
#   结果是 recovery 里一个模块都没加载，TWRP 初始化图形失败后 exit(1)。
#   MTK 自己给 recovery 备了一份 286 条的 modules.load.recovery，这里按它加载。

# init 的 exec 子进程 stdout 通常已是 /dev/kmsg，再显式指一次，防止被丢进 /dev/null
[ -e /dev/kmsg ] && exec 1>/dev/kmsg 2>&1

log() { echo "[twrp-fix] $*"; }

# ── 1. 找模块目录与清单：优先 modules.load.recovery，其次 modules.load
D=""
L=""
for d in /lib/modules/*/ ; do
    if [ -f "$d/modules.load.recovery" ]; then
        D="$d"; L="${d}modules.load.recovery"; break
    fi
done
if [ -z "$L" ]; then
    for d in /lib/modules/*/ ; do
        if [ -f "$d/modules.load" ]; then
            D="$d"; L="${d}modules.load"; break
        fi
    done
fi
# 兜底：清单直接平铺在 /lib/modules/ 下
if [ -z "$L" ]; then
    if [ -f /lib/modules/modules.load.recovery ]; then
        L=/lib/modules/modules.load.recovery; D=/lib/modules/
    elif [ -f /lib/modules/modules.load ]; then
        L=/lib/modules/modules.load; D=/lib/modules/
    fi
fi

if [ -z "$L" ]; then
    log "no modules.load under /lib/modules — 跳过"
    exit 0
fi

# ── 2. 逐个 insmod
t0=$(date +%s)
total=0; ok=0; skip=0; fail=0; failed=""
while IFS= read -r m || [ -n "$m" ]; do
    m=$(echo "$m" | tr -d '\r')
    case "$m" in ''|'#'*) continue ;; esac
    total=$((total+1))
    err=$(insmod "$D$m" 2>&1); rc=$?
    if [ $rc -eq 0 ]; then
        ok=$((ok+1))
    else
        case "$err" in
            # 已内建或已被依赖链加载过，不算失败
            *"File exists"*|*"already"*) skip=$((skip+1)) ;;
            *)
                fail=$((fail+1))
                [ $fail -le 8 ] && failed="$failed $m"
                ;;
        esac
    fi
done < "$L"

t1=$(date +%s)
log "modules from $L: total=$total ok=$ok skip=$skip fail=$fail ($((t1-t0))s)"
[ -n "$failed" ] && log "insmod failed:$failed"

# ── 3. 关键节点自检：这几个是"能不能显示 / 能不能 adb"的判据
sleep 1
if [ -e /dev/graphics/fb0 ]; then
    log "/dev/graphics/fb0 present"
else
    log "/dev/graphics/fb0 MISSING"
fi
if [ -e /dev/dri/card0 ]; then
    log "/dev/dri/card0 present"
else
    log "/dev/dri/card0 MISSING"
fi
u=$(ls /sys/class/udc 2>/dev/null | tr '\n' ' ')
if [ -n "$u" ]; then
    log "udc: $u"
else
    log "udc: NONE"
fi
exit 0
