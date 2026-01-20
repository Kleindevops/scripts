#!/bin/bash
# 个人优化
# Ubuntu_24.04
# 国内源

# ================================================
# ↓ 在下方编写你的脚本内容
# ================================================

clear
echo "================================================="
echo "    正在执行：国内源"
echo "================================================="
echo "执行时间：$(date '+%Y-%m-%d %H:%M:%S')"
echo "执行用户：$(whoami) @ $(hostname)"
echo "================================================="
clear
echo -e "\033[36m╔══════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;36m         Ubuntu 一键换国内高速源（支持24/22/20）      \033[0m"
echo -e "\033[36m╚══════════════════════════════════════════════════╝\033[0m"
echo
echo -e "\033[33m  1. 清华大学（最快、最稳、官方推荐）\033[0m"
echo -e "\033[33m  2. 中国科技大学（超快，24.04 已完美支持）\033[0m"
echo -e "\033[33m  3. 阿里云（稳定，大厂维护）\033[0m"
echo -e "\033[33m  4. 华为云（超稳，专为 Ubuntu 优化）\033[0m"
echo -e "\033[33m  5. 恢复官方源（出问题时回滚用）\033[0m"
echo
read -p "  请选择要更换的源 [1-5]: " choice

case $choice in
    1)  SOURCE_NAME="清华大学"
        SOURCE_URL="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
        ;;
    2)  SOURCE_NAME="中国科技大学"
        SOURCE_URL="https://mirrors.ustc.edu.cn/ubuntu/"
        ;;
    3)  SOURCE_NAME="阿里云"
        SOURCE_URL="https://mirrors.aliyun.com/ubuntu/"
        ;;
    4)  SOURCE_NAME="华为云"
        SOURCE_URL="https://repo.huaweicloud.com/ubuntu/"
        ;;
    5)  SOURCE_NAME="官方源（回滚）"
        SOURCE_URL="http://archive.ubuntu.com/ubuntu/"
        ;;
    *)  echo "输入错误，已取消" ; sleep 2 ; return ;;
esac

echo -e "\n\033[33m→ 正在备份原始 sources.list...\033[0m"
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak_$(date +%Y%m%d_%H%M%S)

echo -e "\033[33m→ 正在写入 $SOURCE_NAME 源...\033[0m"
sudo tee /etc/apt/sources.list > /dev/null <<EOF
# $SOURCE_NAME 源（由 BobbyOps 一键生成于 $(date '+%Y-%m-%d %H:%M')）
deb $SOURCE_URL $(lsb_release -sc) main restricted universe multiverse
deb $SOURCE_URL $(lsb_release -sc)-updates main restricted universe multiverse
deb $SOURCE_URL $(lsb_release -sc)-backports main restricted universe multiverse
deb $SOURCE_URL $(lsb_release -sc)-security main restricted universe multiverse
EOF

echo -e "\033[33m→ 正在更新软件源（第一次会稍慢）...\033[0m"
sudo apt update

echo
echo -e "\033[32m╔══════════════════════════════════════════╗\033[0m"
echo -e "\033[1;32m    成功换成 $SOURCE_NAME 源！\033[0m"
echo -e "\033[32m    现在 apt update/install 将起飞！\033[0m"
echo -e "\033[32m    原文件已备份到 /etc/apt/sources.list.bak_*\033[0m"
echo -e "\033[32m╚══════════════════════════════════════════╝\033[0m"

