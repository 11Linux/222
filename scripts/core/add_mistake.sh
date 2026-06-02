#!/bin/bash

# --- 1. 智能定位路径 (确保在任何目录下运行都能找到文件) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DATA_FILE="$PROJECT_ROOT/data/mistakes.txt"

# 确保目录存在
mkdir -p "$(dirname "$DATA_FILE")"

# --- 2. 获取输入 (优先使用参数，否则交互输入) ---
if [ -n "$1" ]; then SUBJECT="$1"; else read -p "请输入科目: " SUBJECT; fi
if [ -n "$2" ]; then CONTENT="$2"; else read -p "请输入错题内容: " CONTENT; fi
if [ -n "$3" ]; then NOTE="$3"; else read -p "请输入备注: " NOTE; fi

# --- 3. 格式化并写入 (关键修复点) ---
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 【注意】竖线 | 两边必须各有一个空格，这是测试脚本识别的关键
echo "${TIMESTAMP} | ${SUBJECT} | ${CONTENT} | ${NOTE}" >> "$DATA_FILE"

echo "✅ 错题已录入！[${SUBJECT}] -> 新标签：[${NOTE}]"
