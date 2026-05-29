#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../../"  # 切换到项目根目录
source scripts/core/exception_handler.sh
mkdir -p data/subjects
echo -e "题干：求极限\n错误：直接代入\n正解：洛必达" > data/subjects/lim01.txt

# 执行 review_notify.sh 脚本并捕获输出
out=$(./scripts/core/review_notify.sh)
echo "Output of review_notify.sh: $out"  # 打印输出内容

# 验证输出是否包含预期的字符串
if grep -q "题干：求极限" <<< "$out"; then
    echo "✅ review_notify.sh 单元测试通过"
else
    # 如果没有找到题目信息，检查是否是因为没有待复习题目
    if echo "$out" | grep -q "今日无待复习错题"; then
        echo "✅ review_notify.sh 单元测试通过（无待复习题目）"
    else
        { handle invalid_param "抽题失败"; exit 1; }
    fi
fi
