#!/bin/bash

# ==========================================
# 脚本名称: export_mistakes.sh
# 功能描述: 根据标签批量导出错题到指定文件
# 用法示例: ./scripts/core/export_mistakes.sh -t "几何" -o data/exports/geometry_review.txt
# ==========================================

# --- 1. 初始化变量 ---
TAG=""
OUTPUT_FILE=""
DATA_FILE="data/mistakes.txt" # 默认数据源路径

# --- 2. 解析命令行参数 ---
while getopts "t:o:" opt; do
    case $opt in
        t) TAG="$OPTARG" ;;   # -t 指定要导出的标签
        o) OUTPUT_FILE="$OPTARG" ;; # -o 指定导出文件的保存路径
        \?) echo "❌ 无效选项: -$OPTARG" >&2; exit 1 ;;
        :) echo "❌ 选项 -$OPTARG 需要一个参数." >&2; exit 1 ;;
    esac
done

# --- 3. 参数校验 ---
if [ -z "$TAG" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "📖 用法说明:"
    echo "   $0 -t <标签名> -o <导出路径>"
    echo ""
    echo "   -t : 必填，要筛选的标签 (例如: 数学, 重点)"
    echo "   -o : 必填，导出文件的保存路径 (例如: exports/math.txt)"
    exit 1
fi

# 检查源数据文件是否存在
if [ ! -f "$DATA_FILE" ]; then
    echo "❌ 错误：找不到数据文件 $DATA_FILE"
    exit 1
fi

# --- 4. 准备导出环境 ---
# 获取导出文件的目录部分
EXPORT_DIR=$(dirname "$OUTPUT_FILE")

# 如果目录不存在，则自动创建
if [ ! -d "$EXPORT_DIR" ]; then
    echo "📂 导出目录不存在，正在创建: $EXPORT_DIR ..."
    mkdir -p "$EXPORT_DIR"
fi

echo "🔍 正在搜索标签包含 '${TAG}' 的错题..."
echo "💾 准备导出至: ${OUTPUT_FILE}"
echo "----------------------------------------"

# --- 5. 核心逻辑 (AWK) ---
# 逻辑说明：
# 1. -F' *\\| *' : 允许竖线前后有空格，增强兼容性
# 2. match($5, ...) : 在第5列(标签列)中查找关键词
# 3. \\b : 单词边界，防止 "数" 匹配到 "数学" (可选，视需求而定)
# 4. print > file : 将匹配行写入新文件

awk -F' *\\| *' -v tag="$TAG" -v outfile="$OUTPUT_FILE" '
BEGIN {
    count = 0;
}
{
    # 检查第5列是否包含目标标签
    # 这里使用简单的 index 函数进行模糊匹配
    # 如果你需要精确匹配（比如搜"数"不匹配"数学"），请改用正则 match($5, "(^|,)tag(,|$)")
    if ($5 ~ tag) {
        print $0 >> outfile;
        count++;
    }
}
END {
    if (count > 0) {
        print "✅ 导出成功！共找到 " count " 条相关错题。";
        print "📄 文件已保存至: " outfile;
    } else {
        print "⚠️ 未找到包含标签 [" tag "] 的错题。";
        print "💡 提示：请检查标签拼写，或运行 list_tags.sh 查看现有标签。";
    }
}
' "$DATA_FILE"
