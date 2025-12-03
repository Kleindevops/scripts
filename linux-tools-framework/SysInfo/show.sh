#!/bin/bash
clear
echo -e "\033[33m╔══════════════════════════════════════╗\033[0m"
echo -e "\033[33m║          当前系统环境信息            ║\033[0m"
echo -e "\033[33m╚══════════════════════════════════════╝\033[0m"
echo

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    OS_NAME="${NAME//\"/}"
    OS_VER="$VERSION_ID"
    PRETTY="${PRETTY_NAME//\"/}"
else
    OS_NAME="Unknown"; OS_VER="Unknown"; PRETTY="Unknown"
fi

echo -e "执行时间   : \033[32m$(date '+%Y-%m-%d %H:%M:%S')\033[0m"
echo -e "主机名     : \033[32m$(hostname)\033[0m"
echo -e "系统       : \033[32m$PRETTY\033[0m"
echo -e "内核       : \033[32m$(uname -r)\033[0m"
echo -e "架构       : \033[32m$(arch)\033[0m"
echo -e "主IP       : \033[32m$(hostname -I | awk '{print $1}' 2>/dev/null || echo "N/A")\033[0m"
echo -e "当前用户   : \033[32m$(whoami)\033[0m"
echo -e "框架目录   : \033[32m$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)\033[0m"
echo
echo
echo
echo
