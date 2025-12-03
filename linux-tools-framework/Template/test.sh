#!/bin/bash
# 个人优化
# default
# 这条脚本一定能显示出来！用来验证框架是否正常
echo "╔══════════════════════════════════╗"
echo "║        BobbyOps 2025 运行成功！        ║"
echo "║                                      ║"
echo "║   当前系统：$(hostname) @ $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || uname -r)   ║"
echo "║   时间：$(date '+%Y-%m-%d %H:%M:%S')            ║"
echo "║                                      ║"
echo "║   框架一切正常，可以开始扔脚本了！      ║"
echo "╚══════════════════════════════════╝"
sleep 3
