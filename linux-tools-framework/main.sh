#!/bin/bash
# main.sh - 极简入口（2025 最终版）

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 开场系统信息
clear
"$DIR/SysInfo/show.sh"

# 识别系统并创建临时目录
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    SYS_NAME=$(echo "$NAME" | sed 's/"//g')
    SYS_VER="$VERSION_ID"
    SYS_DIR="${SYS_NAME}_${SYS_VER}"
else
    echo "无法识别系统"; exit 1
fi

FULL_DIR="$DIR/$SYS_DIR"
rm -rf "$FULL_DIR" 2>/dev/null
mkdir -p "$FULL_DIR"

# 检查 Template 是否为空
[[ -z "$(ls -A "$DIR/Template"/*.sh 2>/dev/null)" ]] && {
    clear; echo "Template 目录为空！"; sleep 3; exit 1
}

# 调用拷贝模块
source "$DIR/Lib/copy_template.sh"

# 检查是否有可用脚本
[[ -z "$(find "$FULL_DIR" -mindepth 2 -type f -name '*.sh' 2>/dev/null)" ]] && {
    clear
    echo "暂无适用于当前系统的脚本"
    echo "请在 Template 脚本第3行写 default 或 $SYS_DIR"
    sleep 4
}

# 调用菜单引擎（无限循环在这里面）
source "$DIR/Lib/menu_engine.sh"
while :; do
    show_main_menu || sleep 1
done
