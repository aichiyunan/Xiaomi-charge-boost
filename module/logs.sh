#!/system/bin/sh
# 部分系统（ColorOS 移植等）上 mkdir("/") 返回 EINVAL，busybox/toybox 的 mkdir -p 会从 / 开始逐级创建而直接失败：改为跳过已存在的目录、只创建缺的那级
mkdir(){ if [ "$1" = -p ]; then shift; _r=0; for _d in "$@"; do case $_d in /*) _p=;; *) _p=.;; esac; _o=$IFS; IFS=/; set -f; for _c in $_d; do [ -z "$_c" ] && continue; _p=$_p/$_c; [ -d "$_p" ] || command mkdir "$_p" || { _r=1; break; }; done; set +f; IFS=$_o; done; return $_r; else command mkdir "$@"; fi; }
# 充电 / 放电调试日志：list | export <名> | del <名...>
D=/data/adb/mi_charge_boost; L=$D/logs; DL=$D/dlogs; mkdir -p $L $DL
OUT=/storage/emulated/0
where(){ [ -f $L/$1.log ] && { echo "$L/$1.log c"; return; }; [ -f $DL/$1.log ] && echo "$DL/$1.log d"; }
case "$1" in
list) cur=$(cat $D/current 2>/dev/null); cur=${cur%.csv}; dc=$(cat $D/dcurrent 2>/dev/null); dc=${dc%.log}
  { ls $L 2>/dev/null | sed 's/$/ c/'; ls $DL 2>/dev/null | sed 's/$/ d/'; } | sort -rn | while read f t; do n=${f%.log}
    [ $t = c ] && p=$L/$f || p=$DL/$f
    e=$(stat -c %Y $p); s=$(stat -c %s $p); lv=0; { [ $t = c ] && [ "$n" = "$cur" ]; } || { [ $t = d ] && [ "$n" = "$dc" ]; } && lv=1
    echo "$n,$e,$s,$lv,$t"; done;;
export) set -- $(where "$2"); [ -n "$1" ] || { echo "! 没有这个日志"; exit 1; }
  n=$(basename $1 .log); dv=$(getprop ro.product.device); fn=$(date -d @$n +%y%m%d_%H%M%S 2>/dev/null || date -r $n +%y%m%d_%H%M%S)_$dv$([ $2 = d ] && echo _放电).log
  cp $1 $OUT/$fn && chmod 0666 $OUT/$fn && echo "已导出到内置存储目录 - \"$fn\"" || echo "! 导出失败";;
del) shift; for n in "$@"; do case "$n" in *[!0-9]*) ;; *) rm -f $L/$n.log $DL/$n.log;; esac; done; echo ok;;
*) echo "用法: logs.sh list|export <名>|del <名...>";;
esac
