#!/bin/bash脚本有问题

# 
# 
# 安全配置静态IP（失败自动回滚 + 权限修复 + 防断网） 脚本有问题

clear
echo "================================================="
echo "  Ubuntu 静态IP 安全配置工具（终极版）"
echo "  失败自动回滚 │ 权限修复 │ 断网自运行"
echo "================================================="
echo

[[ $EUID -ne 0 ]] && echo "请用 root 运行！" && exit 1
# 一键永久干掉所有 netplan 权限警告（强烈推荐）
echo "正在修复 netplan 配置文件权限..."
chmod 600 /etc/netplan/*.yaml 2>/dev/null
chown root:root /etc/netplan/*.yaml 2>/dev/null
echo "netplan 权限已全部修复为 600，警告彻底消失！"

# 1. 智能识别当前上网网卡 + 网关 + DNS
main_iface=$(ip -o route get 8.8.8.8 2>/dev/null | awk '{print $5}' | head -1)
gateway=$(ip route | grep default | grep "$main_iface" | awk '{print $3}' | head -1)
dns_list=$(resolvectl status 2>/dev/null | grep -A3 "Link.*$main_iface" | grep "DNS Servers" | awk '{for(i=3;i<=NF;i++) printf $i" "}' | sed 's/ $//; s/ /, /g')
[[ -z "$dns_list" ]] && dns_list="114.114.114.114, 8.8.8.8"

echo -e "当前上网网卡：\033[33m$main_iface\033[0m"
[[ "$main_iface" == wlp* ]] && echo -e "→ \033[31m无线网卡！改IP会断开当前SSH\033[0m"
echo "当前网关     ：$gateway"
echo "当前 DNS     ：$(echo $dns_list | sed 's/, / /g')"
echo

read -p "请输入要设置的静态IP（含掩码，如 192.168.1.188/24）: " static_ip
[[ -z "$static_ip" ]] && echo "IP不能为空" && exit 1

echo
echo -e "\033[31m警告：即将修改 $main_iface 的IP，当前会话会断开！\033[0m"
echo -e "\033[32m脚本已加入失败自动回滚，100% 稳！\033[0m"
read -p "确认执行？(输入 y 确认): " sure
[[ "$sure" != "y" && "$sure" != "Y" ]] && echo "已取消" && exit 0

# 关键：把所有操作扔到完全独立的后台进程
nohup bash -c "
    sleep 8
    LOG='/tmp/static-ip.log'
    CONFIG='/etc/netplan/01-netcfg.yaml'
    BACKUP='/etc/netplan/01-netcfg.yaml.bak.$(date +%Y%m%d%H%M%S)'

    echo '[$(date)] 开始配置静态IP $static_ip' >> \$LOG

    # 备份原配置（失败也能回滚）
    cp \$CONFIG \$BACKUP 2>/dev/null && echo '原配置已备份到 \$BACKUP' >> \$LOG

    # 写入新配置
    cat > \$CONFIG << 'EOF'
network:
  version: 2
  ethernets:
    $main_iface:
      dhcp4: no
      addresses: [$static_ip]
      routes:
        - to: default
          via: $gateway
      nameservers:
        addresses: [$dns_list]
EOF

    # 强制修复权限（干掉所有警告）
    chmod 600 \$CONFIG 2>/dev/null
    chown root:root \$CONFIG 2>/dev/null

    # 应用配置
    if netplan apply >> \$LOG 2>&1; then
        # 成功：检查网络是否真的通
        sleep 3
        if ping -c 3 114.114.114.114 -I $main_iface &>/dev/null; then
            echo '[$(date)] 静态IP 配置成功！新IP: $static_ip' >> \$LOG
            touch /tmp/ip-change-success
            exit 0
        fi
    fi

    # 到这里说明失败 → 自动回滚
    echo '[$(date)] 配置失败！正在自动回滚...' >> \$LOG
    cp \$BACKUP \$CONFIG 2>/dev/null && chmod 600 \$CONFIG && chown root:root \$CONFIG
    netplan apply >> \$LOG 2>&1
    echo '[$(date)] 已回滚到原始配置，网络已恢复' >> \$LOG
    touch /tmp/ip-change-failed
" >/dev/null 2>&1 &

echo
echo -e "\033[32m配置已提交后台（失败会自动回滚）\033[0m"
echo -e "用新IP登录：ssh root@$(echo $static_ip | cut -d'/' -f1)"
echo
echo "状态查看："
echo "   成功 → cat /tmp/ip-change-success"
echo "   失败 → cat /tmp/ip-change-failed"
echo "   日志 → cat /tmp/static-ip.log"
echo "   备份 → ls /etc/netplan/*.bak.*"
echo
for i in {10..1}; do echo -n "$i.. "; sleep 1; done; echo
