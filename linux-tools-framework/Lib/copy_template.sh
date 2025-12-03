#!/bin/bash
# 模块：负责把 Template 里的脚本按规则拷贝到系统目录
# 输入：$1 = FULL_DIR  $2 = DIR
# 这就是你以前最稳的「拷贝 Template 脚本」核心代码段
# 可以直接粘到 main.sh 里，或者单独保存为 copy_template.sh 也行

shopt -s nullglob
for f in "$DIR"/Template/*.sh; do
    # 第2行 = 分类名（菜单显示的名字）
    category=$(sed -n '2p' "$f" | sed 's/^ *# *//; s/ *$//')
    [[ -z "$category" ]] && category="未分类"

    # 第3行 = 识别标签
    tag=$(sed -n '3p' "$f" | sed 's/^ *# *//; s/ *$//' | xargs)

    # 只有写 default 或者精确等于 Ubuntu_24.04 才被拷贝
    if [[ "$tag" == "default" || "$tag" == "$SYS_DIR" ]]; then
        mkdir -p "$FULL_DIR/$category"
        cp -f "$f" "$FULL_DIR/$category/"
    fi
done
shopt -u nullglob
