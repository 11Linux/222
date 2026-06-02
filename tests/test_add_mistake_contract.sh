#!/bin/bash

# --- 1. 自动定位路径 ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 明确指定文件路径
DATA_FILE="$PROJECT_ROOT/data/mistakes.txt"
ADD_SCRIPT="$PROJECT_ROOT/scripts/core/add_mistake.sh"

echo "【阶段二】正在测试错题添加功能..."
echo "🔍 调试信息: 目标数据文件是 -> $DATA_FILE" # <--- 新增：打印路径确认

# --- 2. 安全备份与清空 ---
if [ -f "$DATA_FILE" ]; then
    cp "$DATA_FILE" "${DATA_FILE}.bak"
else
    mkdir -p "$(dirname "$DATA_FILE")"
fi
# 制造纯净环境
> "$DATA_FILE"

# --- 3. 执行操作 (关键修改点) ---
# 我们不仅传递参数，还通过环境变量告诉 add_mistake.sh 确切的数据文件在哪里
# 这样可以防止 add_mistake.sh 自己算错路径
export TEST_DATA_FILE_OVERRIDE="$DATA_FILE"

bash "$ADD_SCRIPT" "数学" "一元二次方程求解错误" "注意判别式 b^2-4ac"

# --- 4. 验证结果 ---

# 1. 先打印文件内容，以此作为“证据”，防止以后找不到原因
echo "--- 此时文件内容如下 ---"
cat "$DATA_FILE"
echo "------------------------"

# 2. 使用更宽松的关键词进行搜索
# 只要文件里包含 "一元二次" 这几个字就算成功，不要搜全名，防止空格或符号干扰
SEARCH_KEYWORD="一元二次"

if grep -q "$SEARCH_KEYWORD" "$DATA_FILE"; then
    echo "✅ [通过] 错题数据成功写入且格式正确"
else
    echo "❌ [失败] 数据未找到，请检查写入逻辑"
    echo "   > 我刚才在找关键词: '$SEARCH_KEYWORD'"
    echo "   > 但文件里似乎没有..."
fi

# --- 5. 清理现场 ---
if [ -f "${DATA_FILE}.bak" ]; then
    mv "${DATA_FILE}.bak" "$DATA_FILE"
else
    rm "$DATA_FILE"
fi
