#!/bin/bash
# 帮助
# default
# git命令

# ================================================
# ↓ 在下方编写你的脚本内容
# ================================================

clear
echo "================================================="
echo "    正在执行：git命令"
echo "================================================="
echo "执行时间：$(date '+%Y-%m-%d %H:%M:%S')"
echo "执行用户：$(whoami) @ $(hostname)"
echo "================================================="

clear
echo -e "\033[36m╔══════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;36m           Git 开发 → 测试 → 提交 → 合并 一条龙流程         \033[0m"
echo -e "\033[36m╚══════════════════════════════════════════════════════╝\033[0m"
echo
echo -e "\033[33m【1】确认在 dev 分支\033[0m"
echo "   git branch"
echo
echo -e "\033[33m【2】先临时提交（防止脚本把自己删了）\033[0m"
echo "   git add -A"
echo "   git commit -m \"test: 准备测试脚本（临时提交）\""
echo
echo -e "\033[33m【3】现在随便执行脚本测试\033[0m"
echo "   bash Template/你的脚本.sh"
echo "   # 或者直接 ./Template/你的脚本.sh"
echo
echo -e "\033[33m【4】测试完后看一眼状态（临时文件不会提交）\033[0m"
echo "   git status"
echo
echo -e "\033[33m【5】测试没问题 → 正式提交并合并到 main（4 行秒完）\033[0m"
echo "   git checkout main"
echo "   git pull origin main"
echo "   git merge dev"
echo "   git push origin main"
echo
echo -e "\033[33m【6】（推荐）删除远程 dev 分支，保持仓库干净\033[0m"
echo "   git push origin --delete dev"
echo
echo -e "\033[32m╔══════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;32m   以后每次写完脚本，只需要照着 1→2→3→4→5→6 敲就行！\033[0m"
echo -e "\033[32m╚══════════════════════════════════════════════════════╝\033[0m"
echo
echo -e "\033[37m   提示：最常用的就是这三连：\033[0m"
echo -e "\033[1;37m   git add -A && git commit -m \"xxx\" && git push\033[0m"
echo

