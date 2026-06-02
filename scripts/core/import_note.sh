#!/bin/bash

# ==========================================
# 脚本名称: import_note.sh (对应分工计划中的批量导入模块)
# 功能描述: 支持从 txt/markdown 文件批量导入错题
# 用法: ./import_note.sh <文件路径> [科目名称]
# ==========================================

# 1. 获取当前脚本所在的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# 引入公共库 (根据你的目录结构，尝试加载 utils.sh)
if [ -f "$PROJECT_ROOT/lib/utils.sh" ]; then
    source "$PROJECT_ROOT/lib/utils.sh"
fi

# 2. 定义颜色变量
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 3. 检查参数
if [ -z "$1" ]; then
    echo -e "${YELLOW}用法:${NC} $0 <file_path> [subject]"
    echo "示例: $0 math_notes.txt 数学"
    exit 1
fi

INPUT_FILE="$1"
SUBJECT="${2:-默认科目}" # 默认科目

# 4. 检查文件是否存在
if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}错误: 找不到文件 -> $INPUT_FILE${NC}"
    exit 1
fi

echo "=========================================="
echo "🚀 开始批量导入错题..."
echo "📂 源文件: $INPUT_FILE"
echo "🏷️ 目标科目: $SUBJECT"
echo "=========================================="

SUCCESS_COUNT=0
FAIL_COUNT=0
LINE_NUM=0

# 5. 核心循环：逐行读取
while IFS= read -r line || [ -n "$line" ]; do
    LINE_NUM=$((LINE_NUM + 1))

    # 跳过空行或纯空格行
    if [[ -z "${line// /}" ]]; then
        continue
    fi

    # --- 关键逻辑：调用现有的单条录入逻辑 ---
    # 假设你的单条录入脚本叫 add_note.sh
    # 注意：这里我们调用同目录下的 add_note.sh
    # 如果你没有 add_note.sh，你需要在这里直接写保存文件的逻辑

    # 1. 定义你的错题存储文件路径 (请根据实际情况修改这个文件名)
MISTAKE_DB_FILE="$PROJECT_ROOT/data/mistakes.txt"

# 2. 确保文件存在，如果不存在就创建一个
if [ ! -f "$MISTAKE_DB_FILE" ]; then
    touch "$MISTAKE_DB_FILE"
fi

echo "DEBUG: 正在处理第 $line_num 行..."

# 3. 【可选】简单的查重逻辑 (防止导入重复数据)
# 如果你的题目格式很特殊，这里可能需要更复杂的 grep 写法
if grep -qF "$question" "$MISTAKE_DB_FILE"; then
    echo "⚠️ [跳过] 第 $line_num 行: 题目已存在 -> $question"
else
    # 4. 直接写入！(模拟 add_note.sh 的功能)
    # 注意：这里的格式 "时间|科目|题目|答案" 需要和你原本 add_note.sh 写入的格式保持一致
    # 否则以后查看错题时可能会乱码或格式不对
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $SUBJECT | $question | $answer" >> "$MISTAKE_DB_FILE"

    if [ $? -eq 0 ]; then
        echo "✅ [成功] 第 $line_num 行: 写入成功"
        RESULT=0
    else
        echo "❌ [失败] 第 $line_num 行: 写入文件出错"
        RESULT=1
    fi
fi

    # 检查结果
    if [ $RESULT -eq 0 ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        # 打印进度，只显示前 20 个字符避免刷屏
        echo -e "  ${GREEN}✔ 成功${NC} | 第 $LINE_NUM 行: ${line:0:30}..."
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo -e "  ${RED}✘ 失败${NC} | 第 $LINE_NUM 行: 写入出错"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Line $LINE_NUM: $line" >> "$PROJECT_ROOT/data/logs/error.log"
    fi

done < "$INPUT_FILE"

# 6. 输出最终报告
echo "=========================================="
echo "🏁 导入完成！"
echo "📊 总计扫描: $LINE_NUM 行"
echo -e "${GREEN}✅ 成功入库: $SUCCESS_COUNT 条${NC}"
if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "${RED}❌ 导入失败: $FAIL_COUNT 条${NC} (查看 data/logs/error.log)"
fi
echo "=========================================="
