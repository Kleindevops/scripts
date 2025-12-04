#!/bin/bash
# 个人优化
# default
# 交互式创建新脚本（可在任意目录运行）

clear
echo "================================================="
echo "    BobbyOps 2025 - 交互式脚本生成器"
echo "           （全局可用版）"
echo "================================================="
echo

# 自动定位 Template 目录（关键改动）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$(basename "$SCRIPT_DIR")" == "Template" ]]; then
    TEMPLATE_DIR="$SCRIPT_DIR"
else
    # 向上查找 Template 目录（支持在框架根目录或子目录运行）
    TEMPLATE_DIR="$(cd "$SCRIPT_DIR" && pwd)"
    while [[ "$TEMPLATE_DIR" != "/" && ! -d "$TEMPLATE_DIR/Template" ]]; do
        TEMPLATE_DIR="$(dirname "$TEMPLATE_DIR")"
    done
    TEMPLATE_DIR="$TEMPLATE_DIR/Template"
fi

if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "错误：未找到 Template 目录！请确保脚本在框架内运行"
    read -n1 -p "按任意键退出..."
    exit 1
fi

# 1. 输入脚本名称
while true; do
    read -p "请输入脚本名称（不含 .sh，后缀自动添加）: " name
    [[ -z "$name" ]] && echo "名称不能为空，请重新输入！" && continue
    filename="${name}.sh"
    filepath="$TEMPLATE_DIR/$filename"
    
    if [[ -f "$filepath" ]]; then
        read -p "文件 $filename 已存在，是否覆盖？(y/N): " yn
        [[ "$yn" != "y" && "$yn" != "Y" ]] && echo "已取消" && exit 0
    fi
    break
done

# 2. 输入分类
read -p "请输入一级分类名称（如：系统工具、个人优化）: " category
[[ -z "$category" ]] && category="未分类"

# 3. 选择适配系统
echo
echo "请选择系统适配方式："
echo "   1) default      → 所有系统通用（推荐）"
echo "   2) 当前系统     → 只适配本机系统（$(grep -m1 '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo '未知')）"
echo "   3) 手动输入"
read -p "请选择 [1/2/3]，默认 1: " choice
case "$choice" in
    2) 
        source /etc/os-release 2>/dev/null
        tag="${NAME//\"/}_${VERSION_ID}"
        tag="${tag// /_}"
        ;;
    3) 
        read -p "请输入自定义标签: " tag
        [[ -z "$tag" ]] && tag="default"
        ;;
    *) tag="default" ;;
esac

# 4. 输入描述
read -p "请输入二级菜单显示文字（留空使用脚本名）: " desc
[[ -z "$desc" ]] && desc="$name"

# 生成脚本
cat > "$filepath" << EOF
#!/bin/bash
# $category
# $tag
# $desc

# ================================================
# ↓ 在下方编写你的脚本内容
# ================================================

clear
echo "================================================="
echo "    正在执行：$desc"
echo "================================================="
echo "执行时间：\$(date '+%Y-%m-%d %H:%M:%S')"
echo "执行用户：\$(whoami) @ \$(hostname)"
echo "================================================="

# 在这里写你的代码



EOF

chmod +x "$filepath"

echo
echo "成功创建脚本！"
echo "保存位置：$filepath"
echo "分类     ：$category"
echo "适配     ：$tag"
echo "描述     ：$desc"
echo

echo "正在进入 Template 目录..."
read -n1 -p "脚本创建完成，按任意键进入 Template 目录编写代码..." && cd "$TEMPLATE_DIR" && exec bash
