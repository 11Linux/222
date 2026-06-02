#!/bin/bash

# ==========================================
# 脚本名称: remove_tag.sh
# 功能描述: 批量删除错题中的指定标签
# 用法示例: ./scripts/core/remove_tag.sh -t "初中数学"
# ==========================================

# --- 1. 初始化变量 ---
TAG=""
DATA_FILE="data/mistakes.txt"

# --- 2. 解析参数 ---
while getopts "t:" opt; do
    case $opt in
        t) TAG="$OPTARG" ;;
        *) echo "❌ 用法错误: $0 -t <要删除的标签>" && exit 1 ;;
    esac
done

if [ -z "$TAG" ]; then
    echo "❌ 请提供要删除的标签！例如: -t '初中数学'"
    exit 1
fi

# --- 3. 安全检查 ---
if [ ! -f "$DATA_FILE" ]; then
    echo "❌ 找不到数据文件: $DATA_FILE"
    exit 1
fi

echo "🧹 正在从文件中移除标签 '$TAG' ..."

# --- 4. 核心处理逻辑 (AWK) ---
# 使用临时文件处理，防止直接写入导致数据丢失
TEMP_FILE=$(mktemp)

awk -F'|' -v tag_to_remove="$TAG" '
BEGIN { OFS="|" }
{
    # 获取第5列（标签列）
    tags = $5

    # 只有当这一行包含该标签时才进行处理
    if (index(tags, tag_to_remove) > 0) {

        # --- 复杂的字符串清洗逻辑 ---
        # 1. 替换 "标签," (标签在开头或中间)
        gsub(tag_to_remove ",", "", tags)
        # 2. 替换 ",标签" (标签在结尾)
        gsub("," tag_to_remove, "", tags)
        # 3. 替换 "标签" (标签是唯一的，没有逗号)
        gsub(tag_to_remove, "", tags)

        # 更新第5列
        $5 = tags

        print "✅ 已移除: " $3 " -> 新标签: [" tags "]"
    }

    # 打印所有行（无论是否修改）到临时文件
    print $0
}
' "$DATA_FILE" > "$TEMP_FILE"

# --- 5. 覆盖原文件 ---
mv "$TEMP_FILE" "$DATA_FILE"

echo "💾 处理完成！文件已更新。"
