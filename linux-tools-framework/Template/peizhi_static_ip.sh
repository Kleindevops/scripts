#!/bin/bash
# 个人优化
# Rocky Linux
# 配置静态ip - 自动或手动选择

# ================================================
# ↓ 在下方编写你的脚本内容
# ================================================

clear
echo -e "\033[36m╔══════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;36m 配置静态IP - 自动或手动选择（永久生效） \033[0m"
echo -e "\033[36m╚══════════════════════════════════════════════════╝\033[0m"
echo

# 检查是否 root 运行
if [[ $EUID -ne 0 ]]; then
    echo -e "\033[31m请使用 root 权限运行此脚本（sudo bash $0）\033[0m"
    exit 1
fi

echo -e "\033[33m正在自动检测有 IPv4 地址且已 UP 的网卡...\033[0m"
echo

# 获取 UP 状态的以太网接口（排除 lo 和无线）
mapfile -t INTERFACES < <(ip -o link show | awk -F': ' '/state UP/ && $2 != "lo" && $2 !~ /^wl/ {print $2}' | sort)

if [[ ${#INTERFACES[@]} -eq 0 ]]; then
    echo -e "\033[31m错误：没有找到任何已 UP 的有线网卡！\033[0m"
    echo "请检查网络连接，或手动启用网卡后重试。"
    read -n1 -p "按任意键退出..." && exit 1
fi

echo -e "\033[33m找到以下可用网卡：\033[0m"
for i in "${!INTERFACES[@]}"; do
    iface="${INTERFACES[i]}"
    current_ip=$(ip -o -4 addr show dev "$iface" | awk '{print $4}' | head -1 || echo "无 IPv4")
    printf " %d. %-10s 当前IP: %s\n" $((i+1)) "$iface" "$current_ip"
done
echo

# 自动选择或手动选择网卡
if [[ ${#INTERFACES[@]} -eq 1 ]]; then
    IFACE="${INTERFACES[0]}"
    echo -e "\033[32m只有一个可用网卡，自动选择：$IFACE\033[0m"
else
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

# 选择配置方式
echo -e "\033[33m请选择配置方式：\033[0m"
echo " 1 = 自动配置（使用当前 IP + 掩码 + 网关 + DNS 转为静态并永久生效）"
echo " 2 = 手动配置（自己输入 IP、网关、DNS 并永久生效）"
read -p "请输入 1 或 2 （默认 1）： " choice
[[ -z "$choice" ]] && choice="1"

IP=""
PREFIX=""
GATEWAY=""
DNS=""

if [[ "$choice" == "1" ]]; then
    echo -e "\033[32m→ 自动获取当前配置...\033[0m"

    IP_CIDR=$(ip -o -4 addr show dev "$IFACE" | awk '{print $4}' | head -1)
    if [[ -z "$IP_CIDR" ]]; then
        echo -e "\033[31m自动获取失败（无 IP），请切换到手动模式\033[0m"
        choice="2"
    else
        IP=$(echo "$IP_CIDR" | cut -d/ -f1)
        PREFIX=$(echo "$IP_CIDR" | cut -d/ -f2)
        GATEWAY=$(ip route show default dev "$IFACE" | awk '/default/ {print $3}' | head -1)

        # 修复 DNS 获取
        DNS=$(nmcli device show "$IFACE" | grep '^IP4.DNS' | awk '{print $2}' | tr '\n' ' ' | xargs)
        if [[ -z "$DNS" ]]; then
            DNS=$(grep '^nameserver' /etc/resolv.conf | awk '{print $2}' | head -2 | tr '\n' ' ' | xargs)
        fi
        [[ -z "$DNS" ]] && DNS="8.8.8.8 8.8.4.4"

        echo -e "\033[32m自动获取到：\033[0m"
        echo " IP/子网 : ${IP}/${PREFIX}"
        echo " 网关    : $GATEWAY"
        echo " DNS     : $DNS"
        echo
    fi
fi

if [[ "$choice" == "2" ]]; then
    echo -e "\033[33m手动输入配置：\033[0m"

    while true; do
        read -p "请输入静态IP（例: 192.168.1.100）： " IP
        if [[ $IP =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then break; else echo -e "\033[33mIP 格式错误，请重新输入\033[0m"; fi
    done

    read -p "请输入子网前缀（例: 24）： " PREFIX
    [[ -z "$PREFIX" ]] && PREFIX="24"

    while true; do
        read -p "请输入网关（例: 192.168.1.1）： " GATEWAY
        if [[ $GATEWAY =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then break; else echo -e "\033[33m网关格式错误\033[0m"; fi
    done

    read -p "请输入主DNS（例: 8.8.8.8）： " DNS1
    [[ -z "$DNS1" ]] && DNS1="8.8.8.8"

    read -p "请输入备DNS（可选，回车跳过）： " DNS2

    DNS="$DNS1"
    [[ -n "$DNS2" ]] && DNS="$DNS1 $DNS2"
fi

# 最终配置
IPADDR="${IP:-$(echo "$IP_CIDR" | cut -d/ -f1)}"
PREFIX="${PREFIX:-$(echo "$IP_CIDR" | cut -d/ -f2)}"
GATEWAY="${GATEWAY:-$GATEWAY}"
DNS="${DNS:-8.8.8.8 8.8.4.4}"

echo
echo -e "\033[33m最终配置预览：\033[0m"
echo " 网卡     : $IFACE"
echo " IP地址   : $IPADDR"
echo " 子网前缀 : $PREFIX"
echo " 网关     : $GATEWAY"
echo " DNS      : $DNS"
echo

read -n1 -p "确认开始永久配置？（直接回车确定 / q 取消）： " confirm
echo
[[ "$confirm" == "q" || "$confirm" == "Q" ]] && { clear; echo -e "\033[33m已取消\033[0m"; exit 0; }

# 备份原有配置
IFCFG_FILE="/etc/sysconfig/network-scripts/ifcfg-$IFACE"
if [[ -f "$IFCFG_FILE" ]]; then
    sudo cp "$IFCFG_FILE" "${IFCFG_FILE}.bak-$(date +%Y%m%d-%H%M%S)"
    echo -e "\033[32m已备份原有配置文件 → ${IFCFG_FILE}.bak-xxx\033[0m"
fi

# 写入新配置
cat << EOF | sudo tee "$IFCFG_FILE" >/dev/null
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
NAME=$IFACE
DEVICE=$IFACE
ONBOOT=yes
IPADDR=$IPADDR
PREFIX=$PREFIX
GATEWAY=$GATEWAY
DNS1=$(echo "$DNS" | awk '{print $1}')
$( [ "$(echo "$DNS" | wc -w)" -ge 2 ] && echo "DNS2=$(echo "$DNS" | awk '{print $2}')")
EOF

echo -e "\033[32m已写入配置文件：$IFCFG_FILE\033[0m"

# 使配置生效
echo -e "\n\033[33m正在应用配置...\033[0m"

CONNECTION=$(nmcli -g NAME connection show --active | grep -m1 "$IFACE" | head -1)
if [[ -n "$CONNECTION" ]]; then
    sudo nmcli connection reload
    sudo nmcli connection up "$CONNECTION" 2>/dev/null || {
        sudo nmcli connection modify "$CONNECTION" \
            ipv4.method manual \
            ipv4.addresses "${IPADDR}/${PREFIX}" \
            ipv4.gateway "$GATEWAY" \
            ipv4.dns "$DNS" && \
        sudo nmcli connection up "$CONNECTION"
    }
else
    # 如果没有 NM 连接，回退重启服务
    sudo systemctl restart NetworkManager
fi

sleep 3

# 检查结果
echo -e "\033[32m配置完成！当前状态：\033[0m"
ip -brief -color addr show "$IFACE"
ip route show default
echo
echo -e "\033[33m如果网络不通，请检查：\033[0m"
echo "1. cat $IFCFG_FILE"
echo "2. sudo nmcli device status"
echo "3. sudo systemctl restart NetworkManager"
echo "4. 或重启系统"

read -n1 -p "完成，按任意键返回菜单..."
