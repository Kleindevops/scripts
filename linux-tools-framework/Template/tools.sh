#!/bin/bash
# 个人优化
# Ubuntu_24.04
# 常用工具

# ================================================
# ↓ 在下方编写你的脚本内容
# ================================================
clear
echo -e "\033[36m╔══════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;36m       即将一键为您安装以下 15 个常用神器       \033[0m"
echo -e "\033[36m╚══════════════════════════════════════════════════╝\033[0m"
echo
echo -e "\033[33m   curl  wget  git  vim  htop  tree\033[0m"
echo -e "\033[33m   unzip  zip  p7zip-full\033[0m"
echo -e "\033[33m   net-tools  tmux  iftop  iotop\033[0m"
echo -e "\033[33m   dnsutils  filezilla\033[0m"
echo
echo -e "\033[32m  ↑ 全部来自官方源，干净无广告 ↑\033[0m"
echo
read -n1 -p "   按任意键开始安装，按 q 取消 ... "
[[ "$REPLY" == "q" || "$REPLY" == "Q" ]] && clear && echo "已取消" && sleep 1 && return

echo -e "\n\033[33m→ 正在更新软件源...\033[0m"
sudo apt update

echo -e "\033[33m→ 正在安装 15 个工具...\033[0m"
sudo apt install -y curl wget git vim htop tree unzip zip p7zip-full net-tools tmux iftop iotop dnsutils filezilla

echo
echo -e "\033[32m╔══════════════════════════════╗\033[0m"
echo -e "\033[1;32m     全部安装完成！\033[0m"
echo -e "\033[32m╚══════════════════════════════╝\033[0m"
