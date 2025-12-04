#!/bin/bash
# 系统工具
# Ubuntu_24.04
# 下载工具

# ================================================
# ↓ 在下方编写你的脚本内容
# ================================================

clear
echo "================================================="
echo "    正在执行：下载工具"
echo "================================================="
echo "执行时间：$(date '+%Y-%m-%d %H:%M:%S')"
echo "执行用户：$(whoami) @ $(hostname)"
echo "================================================="

# 在这里写你的代码
# 依赖检查与自动安装（只装一次）
if ! command -v aria2c >/dev/null || ! command -v uget-gtk >/dev/null; then
    clear
    echo -e "\033[36m正在自动安装 aria2 + uGet + 浏览器整合插件...\033[0m"
    sudo apt update
    sudo apt install -y aria2 uget uget-integrator
    echo -e "\033[32m依赖安装完成！\033[0m\n"
fi

clear
echo -e "\033[36m╔══════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;36m      aria2 + uGet 超级下载器 已就绪！          \033[0m"
echo -e "\033[36m  特点：20-100 线程秒开 | 后台常驻 | uGet 图形管理  \033[0m"
echo -e "\033[36m╚══════════════════════════════════════════════════╝\033[0m"
echo

# 确保 aria2 后台常驻（只启动一次）
if ! pgrep -f "aria2c.*--enable-rpc" >/dev/null; then
    echo -e "\033[33m→ 正在启动 aria2 后台 RPC 服务（常驻）...\033[0m"
    # 创建一个不会重复启动的会话
    nohup aria2c \
        --enable-rpc --rpc-listen-all \
        --max-concurrent-downloads=20 \
        --max-connection-per-server=16 \
        --split=16 \
        --min-split-size=1M \
        --continue=true \
        --dir=$HOME/Downloads \
        --max-overall-download-limit=0 \
        -q >/dev/null 2>&1 &
    sleep 2
    echo -e "\033[32maria2 已启动（默认下载到 ~/Downloads）\033[0m"
else
    echo -e "\033[32maria2 已在后台运行\033[0m"
fi

echo
echo -e "\033[37m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[1;37m   使用方法（复制下面任意一条命令即可）：\033[0m"
echo
echo -e "\033[33m1. 快速下载（推荐）\033[0m"
echo -e "   \033[36muget-gtk \"%(链接)\" --folder=$HOME/Downloads\033[0m"
echo
echo -e "\033[33m2. 浏览器右键 → “使用 uGet 下载” 或 “使用 uGet 下载全部链接”\033[0m"
echo -e "   （已自动整合到 Chrome/Firefox）\033[0m"
echo
echo -e "\033[33m3. 手动添加链接到 uGet 界面（最直观）\033[0m"
echo -e "   直接打开 uGet → 新建 → 粘贴链接 → 开始\033[0m"
echo -e "\033[37m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo
echo -e "\033[32m  提示：aria2 常驻后台，uGet 就是你的“下载列表管理器”\033[0m"
echo -e "\033[32m        关机前记得在 uGet 里点暂停哦～\033[0m"
echo


