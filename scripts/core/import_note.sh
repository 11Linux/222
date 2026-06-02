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

# 获取当前时间 (用于生成 create_time)
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
DATE_DIR=$(date '+%Y/%m/%d') # 用于文件夹路径

# 5. 核心循环：逐行读取
while IFS= read -r line || [ -n "$line" ]; do
    LINE_NUM=$((LINE_NUM + 1))

    # --- A. 数据清洗 ---
    # 1. 去除首尾空格
clean_line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    # 2. 跳过空行
    if [[ -z "$clean_line" ]]; then
        continue
    fi

    # 3. 使用 "|" 分隔符切割数据
    # 假设格式为：科目|题目|答案|解析|原因
    IFS='|' read -r RAW_SUBJECT Q_TITLE Q_ANSWER Q_ANALYSIS Q_REASON <<< "$clean_line"
    
    # 4. 确定最终使用的科目
    # 逻辑：如果运行脚本时手动指定了科目(如 ./import.sh file.txt 数学)，则优先用指定的；
    #       否则，使用文档里第一列写的科目；
    #       如果文档里也没写，就用“默认科目”。
    if [[ -n "$SUBJECT" && "$SUBJECT" != "默认科目" ]]; then
        FINAL_SUBJECT="$SUBJECT"
    elif [[ -n "$RAW_SUBJECT" ]]; then
        FINAL_SUBJECT="$RAW_SUBJECT"
    else
        FINAL_SUBJECT="默认科目"
    fi 
    # 5. 设置默认值 (防止某一项为空导致格式错乱)
    Q_TITLE="${Q_TITLE:-未命名题目}"
    Q_ANSWER="${Q_ANSWER:-待补充}"
    Q_ANALYSIS="${Q_ANALYSIS:-暂无解析}"
    Q_REASON="${Q_REASON:-待分析}"

    # --- B. 确定存储路径 (严格匹配截图中的目录结构) ---
    # 结构: data/subjects/{科目}/{日期}/
    TARGET_DIR="$PROJECT_ROOT/data/subjects/${FINAL_SUBJECT}/${DATE_DIR}"

    # 确保目录存在
    mkdir -p "$TARGET_DIR"

    # --- C. 生成唯一文件名 ---
    # 使用时间戳+随机数防止重名覆盖，例如: 1716543210_abc.md
    FILE_NAME="${RANDOM}_${LINE_NUM}.md"
    TARGET_FILE="$TARGET_DIR/$FILE_NAME"

    # --- D. 写入标准格式内容 (关键步骤) ---
    cat > "$TARGET_FILE" <<EOF
---
id: $RANDOM
subject: ${FINAL_SUBJECT}
tags: 批量导入
create_time: ${CURRENT_TIME}
update_time: ${CURRENT_TIME}
review_status: 未复习
review_count: 0
---

## 题干
${Q_TITLE}

## 正确答案
${Q_ANSWER}

## 解析
${Q_ANALYSIS}

## 错误原因
${Q_REASON}

EOF

    # --- E. 检查写入结果 ---
    if [ $? -eq 0 ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        echo -e "  ${GREEN}✔ 成功${NC} | 已生成: $TARGET_FILE"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo -e "  ${RED}✘ 失败${NC} | 无法写入: $TARGET_FILE"
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
