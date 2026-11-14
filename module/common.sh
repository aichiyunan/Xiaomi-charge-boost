# 部分系统（ColorOS 移植等）上 mkdir("/") 返回 EINVAL，busybox/toybox 的 mkdir -p 会从 / 开始逐级创建而直接失败：改为跳过已存在的目录、只创建缺的那级
mkdir(){ if [ "$1" = -p ]; then shift; _r=0; for _d in "$@"; do case $_d in /*) _p=;; *) _p=.;; esac; _o=$IFS; IFS=/; set -f; for _c in $_d; do [ -z "$_c" ] && continue; _p=$_p/$_c; [ -d "$_p" ] || command mkdir "$_p" || { _r=1; break; }; done; set +f; IFS=$_o; done; return $_r; else command mkdir "$@"; fi; }
# 公共函数：定位电池与充电节点
D=/data/adb/mi_charge_boost
mkdir -p $D/sessions 2>/dev/null
find_ps(){
  BAT=""; USB=""
  [ -f /sys/class/power_supply/battery/capacity ] && BAT=/sys/class/power_supply/battery
  for p in /sys/class/power_supply/*; do
    t=$(cat $p/type 2>/dev/null)
    [ -z "$BAT" ] && [ "$t" = "Battery" ] && [ -f $p/capacity ] && BAT=$p
  done
  [ -f /sys/class/power_supply/usb/online ] && USB=/sys/class/power_supply/usb
  if [ -z "$USB" ]; then
    for p in /sys/class/power_supply/*; do
      case "$(cat $p/type 2>/dev/null)" in USB*) USB=$p; break;; esac
    done
  fi
}
