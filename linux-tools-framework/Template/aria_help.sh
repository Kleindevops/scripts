#!/bin/bash
# 帮助
# default
# aria操作命令

# ================================================
# ↓ 在下方编写你的脚本内容
# ================================================

clear
echo "================================================="
echo "    正在执行：aria操作命令"
echo "================================================="
echo "执行时间：$(date '+%Y-%m-%d %H:%M:%S')"
echo "执行用户：$(whoami) @ $(hostname)"
echo "================================================="

clear
echo -e "\033[36m╔══════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;36m               aria2 最强命令速查表（直接复制）           \033[0m"
echo -e "\033[36m╚══════════════════════════════════════════════════════╝\033[0m"
echo
echo -e "\033[33m1. 普通猛下载（推荐）\033[0m   aria2c -x16 -s16 -k1M 链接"
echo -e "\033[33m2. 极致提速（暴力）\033[0m     aria2c -x100 -s100 -k1M 链接"
echo -e "\033[33m3. 指定路径+改名\033[0m        aria2c -x16 -d ~/Downloads -o 名字.mp4 链接"
echo -e "\033[33m4. 磁力/BT\033[0m              aria2c magnet:?xt=...   或   aria2c xxx.torrent"
echo -e "\033[33m5. 后台 RPC（uGet 必备）\033[0m  aria2c --enable-rpc --rpc-listen-all -D"
echo -e "\033[33m6. 限速 10MB/s\033[0m          aria2c -x16 --max-download-limit=10M 链接"
echo -e "\033[33m7. 选文件下（BT）\033[0m       aria2c --select-file=2,5 xxx.torrent"
echo -e "\033[33m8. 剪贴板一键下\033[0m         aria2c -x16 \$(xclip -o)"
echo -e "\033[33m9. 下完自动关机\033[0m         aria2c -x16 链接 && poweroff"
echo
echo -e "\033[32m  提示：常用就记住这一个 →  aria2c -x16 -s16 链接\033[0m"
echo -e "\033[32m        其余的直接点这个菜单抄就行！\033[0m"
echo


