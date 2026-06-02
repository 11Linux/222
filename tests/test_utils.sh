#!/bin/bash

# --- 核心修改：自动获取脚本所在目录 ---
# 这行代码的意思是：获取当前脚本(test_utils.sh)所在的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 基于脚本目录，向上推导项目根目录 (假设 tests 在根目录下)
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 使用绝对路径引入工具库
source "$PROJECT_ROOT/lib/utils.sh"
# ----------------------------------

echo "【步骤1/1】正在测试日志工具函数..."

# 调用函数并捕获结果
output=$(log_message "INFO" "这是一条测试日志")

# 判断结果对不对
if [[ "$output" == *"[INFO]"* ]] && [[ "$output" == *"测试日志"* ]]; then
    echo "✅ 测试通过！函数工作正常。"
else
    echo "❌ 测试失败！请检查函数逻辑。"
    echo "实际输出: $output"
    exit 1
fi
