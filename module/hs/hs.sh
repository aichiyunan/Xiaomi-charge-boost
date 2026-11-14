#!/system/bin/sh
# 部分系统（ColorOS 移植等）上 mkdir("/") 返回 EINVAL，busybox/toybox 的 mkdir -p 会从 / 开始逐级创建而直接失败：改为跳过已存在的目录、只创建缺的那级
mkdir(){ if [ "$1" = -p ]; then shift; _r=0; for _d in "$@"; do case $_d in /*) _p=;; *) _p=.;; esac; _o=$IFS; IFS=/; set -f; for _c in $_d; do [ -z "$_c" ] && continue; _p=$_p/$_c; [ -d "$_p" ] || command mkdir "$_p" || { _r=1; break; }; done; set +f; IFS=$_o; done; return $_r; else command mkdir "$@"; fi; }
D=/data/adb/mi_charge_boost; mkdir -p $D
case "$1" in
status) echo "{\"want\":$([ "$(cat $D/hs 2>/dev/null)" = 1 ] && echo 1 || echo 0)}";;
set) [ "$2" = 1 ] && echo 1 > $D/hs || echo 0 > $D/hs
  { [ -f $D/hs.pid ] && kill -0 $(cat $D/hs.pid) 2>/dev/null; } || nohup sh ${0%/*}/daemon.sh >/dev/null 2>&1 &
  echo "$(date '+%m-%d %H:%M:%S' 2>/dev/null || /system/bin/toybox date '+%m-%d %H:%M:%S') 自动重试握手$([ "$2" = 1 ] && echo 开 || echo 关)" >> $D/hs.log; sh $0 status;;
log) tail -n 20 $D/hs.log 2>/dev/null || echo 暂无;;
esac
