#!/bin/bash
# Lib/menu_engine.sh
# 纯粹的菜单引擎（不包含系统识别、拷贝、清理等逻辑）

show_main_menu() {
    clear
    echo "============== BobbyOps 2025 =============="
    "$DIR/SysInfo/show.sh"
    echo "============================================"

    mapfile -t categories < <(find "$FULL_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
    [[ ${#categories[@]} -eq 0 ]] && { echo "无分类可用"; sleep 2; return 1; }

    for i in "${!categories[@]}"; do
        printf " %3d. %s\n" $((i+1)) "$(basename "${categories[i]}")"
    done
    echo "============================================"
    read -p " 请选择分类（q 退出并清理）: " choice

    [[ "$choice" == "q" || "$choice" == "Q" ]] && {
        rm -rf "$FULL_DIR"; clear; echo "已清理临时目录，拜拜！"; exit 0
    }

    ((choice >= 1 && choice <= ${#categories[@]})) || return 1
    selected_cat="${categories[$((choice-1))]}"

    # 二级菜单（已按你最终要求精简）
    while :; do
        clear
        echo "========== $(basename "$selected_cat") =========="
        mapfile -t scripts < <(ls "$selected_cat"/*.sh 2>/dev/null | sort)
        [[ ${#scripts[@]} -eq 0 ]] && { echo "此分类为空"; sleep 2; break; }

        for i in "${!scripts[@]}"; do
            desc=$(sed -n '4p' "${scripts[i]}" 2>/dev/null | sed 's/^# *//; s/ *$//')
            [[ -z "$desc" ]] && desc="$(basename "${scripts[i]}" .sh)"
            printf " %3d. %s\n" $((i+1)) "$desc"
        done
        echo "============================================"
        read -p " 请选择脚本（q 返回主菜单）: " num

        [[ "$num" == "q" || "$num" == "Q" ]] && break
        ((num >= 1 && num <= ${#scripts[@]})) || continue

        clear
        echo "正在执行: $(basename "${scripts[$((num-1))]}")"
        echo "按 q 强制中断，按任意键由脚本决定是否暂停..."
        bash "${scripts[$((num-1))]}"
        read -n1 -p "执行完成，按任意键继续..."
    done
}
