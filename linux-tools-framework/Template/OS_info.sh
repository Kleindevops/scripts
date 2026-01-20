#!/bin/bash
# 一级菜单        
# Ubuntu_24.04
# 显示系统详细信息
clear
echo "========== 系统信息 =========="
echo "主机名    : $(hostname)"
echo "系统版本  : $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "内核版本  : $(uname -r)"
echo "架构      : $(arch)"
echo "内网IP    : $(ip route get 1 | awk '{print $7;exit}')"
echo "负载      : $(uptime | awk -F'load average:' '{print $2}')"
echo "内存使用  : $(free -h | awk '/^Mem:/ {print $3"/"$2}')"
echo "根分区    : $(df -h / | awk 'NR==2 {print $3"/"$2" ("$5")"}')"
#echo "当前用户  : $(whoami)"
echo "运行时间  : $(uptime -p)"
echo "==============================="
read -n1 -p "按任意键返回主菜单..."
