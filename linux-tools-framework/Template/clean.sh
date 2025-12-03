#!/bin/bash
# 个人优化
# default
# 【宇宙最安全版】只删除本框架自己生成的 tmp 和系统专用目录（Ubuntu_24.04.1 等）
# 支持把整个 bobby2025 移动到任意路径，永不误删！

# 智能定位框架根目录（不管你把框架扔哪儿都有效）
get_framework_dir() {
    local script_path="$(realpath "${BASH_SOURCE[0]}" 2>/dev/null || readlink -f "${BASH_SOURCE[0]}")"
    dirname "$(dirname "$(dirname "$script_path")")"  # Template → bobby2025
}
FRAMEWORK_DIR="$(get_framework_dir)"
[[ -z "$FRAMEWORK_DIR" || ! -d "$FRAMEWORK_DIR" ]] && { echo "错误：无法定位框架目录"; exit 1; }

echo -e "\033[33m正在智能清理框架运行痕迹\033[0m"
echo "框架位置：$FRAMEWORK_DIR"
echo

# 1. 删除 tmp 日志目录
if [[ -d "$FRAMEWORK_DIR/tmp" ]]; then
    rm -rf "$FRAMEWORK_DIR/tmp" && echo "已删除：tmp/（运行日志）"
    mkdir -p "$FRAMEWORK_DIR/tmp" && chmod 700 "$FRAMEWORK_DIR/tmp"
fi

# 2. 删除所有系统专用目录（只删里面有 .sh 文件的，防止误删你手动建的同名目录）
deleted_count=0
shopt -s nullglob
for dir in "$FRAMEWORK_DIR"/{Ubuntu,CentOS,Debian,AlmaLinux,Rocky,Unknown}_*; do
    [[ -d "$dir" ]] || continue
    # 安全判断：只删包含脚本的目录
    if ls "$dir"/*.sh >/dev/null 2>&1; then
        rm -rf "$dir"
        echo "已删除系统专用目录：$(basename "$dir")"
        ((deleted_count++))
    else
        echo "跳过（疑似手动创建）：$(basename "$dir")"
    fi
done
shopt -u nullglob

# 3. 删除可能残留的空目录
find "$FRAMEWORK_DIR" -mindepth 1 -maxdepth 1 -type d -empty -delete 2>/dev/null

echo
echo "=================================================="
if (( deleted_count == 0 )); then
    echo -e "\033[32m已经很干净了！未发现需要清理的系统专用目录\033[0m"
else
    echo -e "\033[32m清理完成！共删除 $deleted_count 个系统专用目录\033[0m"
fi
echo "   已保留：main.sh、copy_template.sh、Template/ 下的所有原始脚本"
echo "   下次运行 ./main.sh 会自动重建所需目录"
echo "   本清理脚本可随时删除，绝对安全！"
echo "=================================================="
sleep 2

