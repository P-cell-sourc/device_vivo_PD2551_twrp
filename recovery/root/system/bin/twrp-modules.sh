#!/system/bin/sh
# [twrp-builder-fix] 由 twrp-builder 生成：加载 /lib/modules/<kver>/ 下的 vendor 内核模块
# 不加载它们的话：没有 mediatek-drm.ko → 无显示；没有 extcon-mtk-usb.ko → 无 adb。
#
# 为什么需要这个脚本：
#   MTK 把 .ko 放在 /lib/modules/6.6-gki/ 下，而 AOSP first stage init 只认
#   /lib/modules/<name>.ko 这种平铺路径，报 "module bootprof can't be loaded"，
#   结果 recovery 里一个模块都没加载，TWRP 初始化图形失败后 exit(1)。
#   构建期把原 286 条清单按 modules.dep 拓扑排序后写成 modules.load.twrp，
#   first stage 那份被精简成 3 条（避免 missing .ko 直接 panic），这里按
#   modules.load.twrp 的顺序加载 —— 依赖一定在前，否则会一路 Unknown symbol。

# init 的 exec 子进程 stdout 通常已是 /dev/kmsg，再显式指一次，防止被丢进 /dev/null
[ -e /dev/kmsg ] && exec 1>/dev/kmsg 2>&1

log() { echo "[twrp-fix] $*"; }

# ── 1. 找模块目录与清单
#   顺序很重要：first stage 会把 modules.load.recovery 精简成 3 条（否则 init
#   加载失败直接 panic），全量清单被写成 modules.load.twrp，所以必须先找它。
D=""
L=""
for d in /lib/modules/*/ ; do
    [ -d "$d" ] || continue
    for f in modules.load.twrp modules.load.recovery modules.load; do
        if [ -f "$d$f" ]; then
            D="$d"; L="$d$f"; break 2
        fi
    done
done
# 兜底：清单直接平铺在 /lib/modules/ 下
if [ -z "$L" ]; then
    for f in modules.load.twrp modules.load.recovery modules.load; do
        if [ -f "/lib/modules/$f" ]; then
            L="/lib/modules/$f"; D=/lib/modules/; break
        fi
    done
fi

if [ -z "$L" ]; then
    log "no modules.load under /lib/modules — 跳过"
    exit 0
fi
log "begin: list=$L dir=$D"

# ── 2. 逐个 insmod
#   清单已在构建期按 modules.dep 拓扑排序（依赖在前），这里只负责按序加载 + 记账。
#   每个模块都打一行日志：万一某个 .ko 在 insmod 时把内核准打崩，从 ramoops 最后
#   一行就能直接看出是谁，不用再猜。
t0=$(date +%s)
total=0; ok=0; skip=0; fail=0; failed=""
while IFS= read -r m || [ -n "$m" ]; do
    m=$(echo "$m" | tr -d '\r')
    case "$m" in ''|'#'*) continue ;; esac
    total=$((total+1))
    # 已知会 BUG()/panic 的模块，运行期再兜一层（万一清单是旧的）
    case "$m" in
        fp_dispatch_event.ko)
            skip=$((skip+1))
            log "[$total] skip $m (blacklisted: BUG on insmod)"
            continue
            ;;
    esac
    err=$(insmod "$D$m" 2>&1); rc=$?
    if [ $rc -eq 0 ]; then
        ok=$((ok+1))
        log "[$total] ok $m"
    else
        case "$err" in
            # 已内建或已被依赖链加载过，不算失败
            *"File exists"*|*"already"*)
                skip=$((skip+1))
                log "[$total] skip $m (already loaded)"
                ;;
            *)
                fail=$((fail+1))
                [ $fail -le 20 ] && failed="$failed $m"
                log "[$total] FAIL $m: $(echo "$err" | head -1 | cut -c1-110)"
                ;;
        esac
    fi
done < "$L"

t1=$(date +%s)
log "summary: total=$total ok=$ok skip=$skip fail=$fail ($((t1-t0))s) from $L"
[ -n "$failed" ] && log "failed:$failed"

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
