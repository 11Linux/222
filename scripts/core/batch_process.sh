#!/bin/bash

# --- 配置区 ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DATA_DIR="$PROJECT_ROOT/data"
MISTAKE_FILE="$DATA_DIR/mistakes.txt"
BACKUP_FILE="$MISTAKE_FILE.bak"

# --- 帮助信息 ---
usage() {
    echo "=========================================="
    echo "  错题批量处理工具 (Batch Process Core)"
    echo "=========================================="
    echo "用法: $0 -k <关键词> -t <新标签>"
    echo ""
    echo "参数:"
    echo "  -k, --keyword   要搜索的题目关键词 (例如: '勾股')"
    echo "  -t, --tag       要添加的新标签 (例如: '几何')"
    echo ""
    echo "示例:"
    echo "  $0 -k '函数' -t '高中数学'"
    exit 1
}

# --- 解析参数 ---
KEYWORD=""
NEW_TAG=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -k|--keyword) KEYWORD="$2"; shift ;;
        -t|--tag) NEW_TAG="$2"; shift ;;
        *) echo "❌ 未知参数: $1"; usage ;;
    esac
    shift
done

if [ -z "$KEYWORD" ] || [ -z "$NEW_TAG" ]; then
    usage
fi

# --- 检查环境 ---
if [ ! -f "$MISTAKE_FILE" ]; then
    echo "❌ 错误: 找不到错题文件 $MISTAKE_FILE"
    echo "💡 提示: 请确认 data/mistakes.txt 是否存在"
    exit 1
fi

# --- 自动备份 (安全网) ---
cp "$MISTAKE_FILE" "$BACKUP_FILE"
echo "🛡️ 已自动备份原文件至: $BACKUP_FILE"

echo "🔍 正在搜索包含 '$KEYWORD' 的错题..."

# --- 核心处理逻辑 (AWK) ---
# 假设格式: 日期|科目|题目|答案|标签 (共5列，标签在第5列)
# 如果你的数据列数不同，请修改下面的 $5

awk -F' *\\| *' -v keyword="$KEYWORD" -v tag="$NEW_TAG" 'BEGIN{OFS="|"; count=0}
{
    # 检查第3列(题目)是否包含关键词
    if ($3 ~ keyword) {
        # 如果已经有标签，就追加；如果没有，就直接赋值
        if ($5 != "") {
            # 防止重复添加同一个标签 (简单检查)
            if ($5 !~ tag) {
                $5 = $5 "," tag;
            } else {
                # 如果标签已存在，虽然不修改，但也算匹配到了
                print "⚠️ 跳过 (标签已存在): " $3 > "/dev/stderr"
            }
        } else {
            $5 = tag;
        }
        count++;
        print "✅ 已更新: " $3 " -> 标签变为: " $5 > "/dev/stderr"; # 输出进度到屏幕
    }
    print $0 # 无论是否修改，都输出这一行到标准输出
}
END {
    print "\n🎉 处理完成! 共更新了 " count " 条错题。" > "/dev/stderr"
}' "$MISTAKE_FILE" > "$MISTAKE_FILE.tmp"

# --- 安全替换 ---
# 只有当临时文件生成成功且不为空时，才覆盖原文件
if [ -s "$MISTAKE_FILE.tmp" ]; then
    mv "$MISTAKE_FILE.tmp" "$MISTAKE_FILE"
    echo "💾 文件已保存。"
else
    rm -f "$MISTAKE_FILE.tmp"
    echo "⚠️ 警告: 似乎没有生成有效内容，操作已取消。"
    echo "💡 原文件未变动，如需回滚请手动检查备份文件。"
fi
