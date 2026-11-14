#!/system/bin/sh
# 已适配机型表（v8.4.9 起多机型）：代号 → 参数
# MN 机型名  MI 原厂快充电流(mA)  MX 模块允许的电流上限  SC 单电荷泵分支上限(div_single_curr)
# VQ 满电 FFC 截止电压(mV，模块不改，只用于重构表/显示)  V0 原厂关机电压  PW0 原厂私有协议功率  PWO 可选协议功率
# SOC 处理器代号（dtbo 模板目录）  HZ 1=支持屏幕超频 165Hz/高刷切换（只有小米15 华星 o3_42 屏）  DEFT 非原厂底包时用的模板
MODELS="dada haotian miro annibale warsaw pudding pandora popsicle nezha byron myron athens songyuan hongkong madrid"
# SOC 处理器代号 = dtbo/<SOC>/ 模板目录（v8.7.0）：8750 骁龙8至尊版 / 8850 第五代骁龙8至尊版 / 8950、8975 小米18 系列（6.18 内核）
# 6.12/6.18 内核机型（v8.7.0）：模板按 OS4 官方卡刷包里的原厂 dtbo 自动生成；私有协议节点布局与旧机型不同，不提供可选档位
model_info(){
  case "$1" in
    dada)     MN=小米15;            SOC=8750; MI=15500; MX=20500; SC=20000; VQ=4580; V0=3050; PW0=90;  PWO="100 120"; HZ=1; DEFT=dada;;
    haotian)  MN="小米15 Pro";      SOC=8750; MI=15600; MX=20500; SC=20000; VQ=4580; V0=3050; PW0=90;  PWO="100 120"; HZ=0; DEFT=haotian_os4;;
    miro)     MN="红米K80 Pro";     SOC=8750; MI=20500; MX=22000; SC=20500; VQ=4550; V0=3050; PW0=120; PWO="";        HZ=0; DEFT=miro_os4;;
    annibale) MN=红米K90;           SOC=8750; MI=17600; MX=20500; SC=20000; VQ=4550; V0=2850; PW0=100; PWO="120";     HZ=0; DEFT=annibale_os4;;
    warsaw)   MN=红米K90至尊版;     SOC=8750; MI=17600; MX=20500; SC=20000; VQ=4560; V0=2850; PW0=100; PWO="120";     HZ=0; DEFT=warsaw_os4b;;
    pudding)  MN=小米17;            SOC=8850; MI=18400; MX=20500; SC=20000; VQ=4560; V0=3030; PW0=100; PWO="";        HZ=0; DEFT=pudding_os4;;
    pandora)  MN="小米17 Pro";      SOC=8850; MI=18000; MX=20500; SC=20000; VQ=4520; V0=3030; PW0=100; PWO="";        HZ=0; DEFT=pandora_os4;;
    popsicle) MN="小米17 Pro Max";  SOC=8850; MI=18000; MX=20500; SC=20000; VQ=4535; V0=3030; PW0=100; PWO="";        HZ=0; DEFT=popsicle_os4;;
    nezha)    MN="小米17 Ultra";    SOC=8850; MI=15600; MX=20500; SC=20000; VQ=4530; V0=2850; PW0=90;  PWO="";        HZ=0; DEFT=nezha_os4;;
    byron)    MN="小米17 Max";      SOC=8850; MI=18400; MX=20500; SC=20000; VQ=4580; V0=2850; PW0=100; PWO="";        HZ=0; DEFT=byron_os4;;
    myron)    MN="红米K90 Pro Max"; SOC=8850; MI=18400; MX=20500; SC=20000; VQ=4550; V0=3030; PW0=100; PWO="";        HZ=0; DEFT=myron_os4;;
    athens)   MN="红米K100 Pro";    SOC=8850; MI=18400; MX=20500; SC=20000; VQ=4580; V0=2850; PW0=100; PWO="";        HZ=0; DEFT=athens_os4;;
    songyuan) MN="红米K100 Pro Max";SOC=8850; MI=18400; MX=20500; SC=20000; VQ=4580; V0=2850; PW0=100; PWO="";        HZ=0; DEFT=songyuan_os4;;
    hongkong) MN="小米18 Pro";      SOC=8950; MI=18200; MX=20500; SC=20000; VQ=4590; V0=2850; PW0=100; PWO="";        HZ=0; DEFT=hongkong_os4;;
    madrid)   MN="小米18 Pro Max";  SOC=8975; MI=18000; MX=20500; SC=20000; VQ=4580; V0=2850; PW0=100; PWO="";        HZ=0; DEFT=madrid_os4;;
    *) return 1;;
  esac
  MODNAME="${MN}充电加速模块"; return 0
}
# 通用加载（v8.5.9）：已适配机型用表内参数；未适配机型只识别型号、不拦截，按通用参数运行
# GEN=1 表示未适配机型：电流上限 20500、无私有协议档位、无屏幕超频，FFC 截止电压等一律保持本机原厂（dtbo 逐项比对，只写原厂值吻合的项）
model_load(){
  if model_info "$1"; then GEN=0; return 0; fi
  GEN=1; MN=$(sh ${MCB_ROOT:-${0%/*}}/sysinfo.sh 2>/dev/null | sed -n 1p); [ -n "$MN" ] || MN=$(getprop ro.product.marketname); [ -n "$MN" ] || MN=小米
  MI=15500; MX=20500; SC=20000; VQ=0; V0=3000; PW0=0; PWO=""; HZ=0; DEFT=""; SOC=$(soc_code)
  MODNAME="${MN}充电加速模块"; return 0
}
model_names(){ echo "小米15 / 小米15 Pro / 红米K80 Pro / 红米K90 / 红米K90至尊版 / 小米17 / 17 Pro / 17 Pro Max / 17 Ultra / 17 Max / 红米K90 Pro Max / 红米K100 Pro / K100 Pro Max / 小米18 Pro / 18 Pro Max"; }
# 未适配机型的处理器代号：ro.soc.model（SM8850 → 8850），读不到为空（逐项比对时用全部模板）
soc_code(){ for k in ro.soc.model ro.vendor.soc.model ro.boot.hardware.sku; do v=$(getprop $k); case "$v" in SM[0-9][0-9][0-9][0-9]*) v=${v#SM}; echo ${v%%[!0-9]*}; return;; esac; done; }
# 识别机型代号：sysinfo.sh（移植系统优先读 vendor/odm）→ 其它属性 → 分区 build.prop
detect_code(){
  c=$(sh ${MCB_ROOT:-${0%/*}}/sysinfo.sh 2>/dev/null | sed -n 2p)
  model_info "$c" >/dev/null 2>&1 && { echo $c; return 0; }
  for k in ro.product.vendor.device ro.product.odm.device ro.product.device ro.product.board ro.product.vendor.name ro.product.mod_device ro.build.product; do
    v=$(getprop $k); v=${v%%_*}; model_info "$v" >/dev/null 2>&1 && { echo $v; return 0; }; done
  for m in $MODELS; do
    grep -qE "^ro\.product\.(vendor\.)?(device|name)=${m}(_|\$)" /vendor/build.prop /odm/etc/build.prop 2>/dev/null && { echo $m; return 0; }; done
  echo "${c:-unknown}"; return 1
}
# 运行时取机型：安装时写入 $MCB_ROOT/model，没有再现场识别
model_code(){ r=${MCB_ROOT:-/data/adb/modules/mi_charge_boost}; c=$(cat $r/model 2>/dev/null)
  model_info "$c" >/dev/null 2>&1 && { echo $c; return 0; }; MCB_ROOT=$r detect_code; }
