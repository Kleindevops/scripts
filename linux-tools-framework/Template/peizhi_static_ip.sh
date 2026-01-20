#!/bin/bash
# 个人优化
# Rocky Linux
# 配置静态ip

# ================================================
# ↓ 在下方编写你的脚本内容
# ================================================
clear
echo -e "\033[36m╔══════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;36m       配置静态IP - 自动或手动选择       \033[0m"
echo -e "\033[36m╚══════════════════════════════════════════════════╝\033[0m"
echo

echo -e "\033[33m正在自动检测有 IPv4 地址且已 UP 的网卡...\033[0m"
echo

# 自动获取所有 UP 且有 IPv4 的网卡（排除 lo）
mapfile -t INTERFACES < <(ip -o link show | awk -F': ' '/state UP/ && $2 != "lo" {print $2}' | sort)

if [[ ${#INTERFACES[@]} -eq 0 ]]; then
    echo -e "\033[31m错误：没有找到任何已 UP 且有 IPv4 的网卡！\033[0m"
    echo "请检查网络连接，或手动启用网卡后重试。"
    read -n1 -p "按任意键退出..." && exit 1
fi

# 显示所有符合条件的网卡 + 当前 IP
echo -e "\033[33m找到以下可用网卡：\033[0m"
for i in "${!INTERFACES[@]}"; do
    iface="${INTERFACES[i]}"
    current_ip=$(ip -o -4 addr show dev "$iface" | awk '{print $4}' | head -1 || echo "无 IPv4")
    printf "  %d. %-10s   当前IP: %s\n" $((i+1)) "$iface" "$current_ip"
done
echo

# 如果只有一个网卡，直接用它
if [[ ${#INTERFACES[@]} -eq 1 ]]; then
    IFACE="${INTERFACES[0]}"
    echo -e "\033[32m只有一个可用网卡，自动选择：$IFACE\033[0m"
    echo
else
    # 多个网卡，让用户选
    while true; do
        read -p "请输入序号选择网卡（1-${#INTERFACES[@]}）： " num
        if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#INTERFACES[@]} )); then
            IFACE="${INTERFACES[$((num-1))]}"
            break
        else
            echo -e "\033[33m请输入有效的序号\033[0m"
        fi
    done
fi

echo -e "\033[32m选定网卡：$IFACE\033[0m"
echo

# 选择自动或手动
echo -e "\033[33m请选择配置方式：\033[0m"
echo "  1 = 自动配置（使用当前 IP + 掩码 + 网关 + DNS 转为静态）"
echo "  2 = 手动配置（自己输入 IP、网关、DNS）"
read -p "请输入 1 或 2 （默认 1）： " choice
[[ -z "$choice" ]] && choice="1"

IP_CIDR=""
GATEWAY=""
DNS=""

if [[ "$choice" == "1" ]]; then
    echo -e "\033[32m→ 自动获取当前配置...\033[0m"
    
    IP_CIDR=$(ip -o -4 addr show dev "$IFACE" | awk '{print $4}' | head -1)
    GATEWAY=$(ip route show default dev "$IFACE" | awk '/default/ {print $3}' | head -1)
    DNS=$(grep '^nameserver' /etc/resolv.conf | awk '{print $2}' | tr '\n' ' ' | xargs)

    if [[ -z "$IP_CIDR" || -z "$GATEWAY" ]]; then
        echo -e "\033[31m自动获取失败（无 IP 或网关），请切换到手动模式\033[0m"
        choice="2"
    else
        echo -e "\033[32m自动获取到：\033[0m"
        echo "  IP/子网   : $IP_CIDR"
        echo "  网关      : $GATEWAY"
        echo "  DNS       : ${DNS:-无}"
        echo
    fi
fi

if [[ "$choice" == "2" ]]; then
    echo -e "\033[33m手动输入配置：\033[0m"
    read -p "请输入静态IP/子网（例: 192.168.1.100/24）： " IP_CIDR
    read -p "请输入网关（例: 192.168.1.1）： " GATEWAY
    read -p "请输入DNS（多个用空格分隔，例: 8.8.8.8 114.114.114.114）： " DNS

    [[ -z "$IP_CIDR"  ]] && IP_CIDR="192.168.1.100/24"
    [[ -z "$GATEWAY"  ]] && GATEWAY="192.168.1.1"
    [[ -z "$DNS"      ]] && DNS="8.8.8.8 8.8.4.4"
fi

echo
echo -e "\033[33m最终配置预览：\033[0m"
echo "  网卡      : $IFACE"
echo "  IP/子网    : $IP_CIDR"
echo "  网关      : $GATEWAY"
echo "  DNS       : $DNS"
echo
#read -n1 -p "确认开始配置？（按 q 取消）： " confirm
read -n1 -p "确认开始配置？（直接回车或任意键确定 / q 取消）： " confirm
echo
[[ "$confirm" == "q" || "$confirm" == "Q" ]] && { clear; echo -e "\033[33m已取消\033[0m"; sleep 1; exit 0; }

echo -e "\n\033[33m→ 正在应用临时配置...\033[0m"

sudo ip addr flush dev "$IFACE" 2>/dev/null
sudo ip addr replace  "$IP_CIDR" dev "$IFACE"

sudo ip link set "$IFACE" up
sudo ip route replace default via "$GATEWAY" dev "$IFACE" 2>/dev/null

sudo bash -c "> /etc/resolv.conf"
for ns in $DNS; do
    echo "nameserver $ns" | sudo tee -a /etc/resolv.conf >/dev/null
done

sleep 2

echo -e "\033[32m临时配置已生效！\033[0m"
ip -brief -color addr show "$IFACE"

echo -e "\n\033[33m永久生效建议：\033[0m"
echo "sudo nano /etc/sysconfig/network-scripts/ifcfg-$IFACE"
echo "内容示例："
cat << EOF
TYPE=Ethernet
BOOTPROTO=none
NAME=$IFACE
DEVICE=$IFACE
ONBOOT=yes
IPADDR=$(echo "$IP_CIDR" | cut -d/ -f1)
PREFIX=$(echo "$IP_CIDR" | cut -d/ -f2)
GATEWAY=$GATEWAY
DNS1=$(echo "$DNS" | awk '{print $1}')
$( [ "$(echo "$DNS" | wc -w)" -ge 2 ] && echo "DNS2=$(echo "$DNS" | awk '{print $2}')" )
EOF

echo
echo "保存后：sudo systemctl restart network  或 重启系统"
echo

read -n1 -p "完成，按任意键返回菜单..."
