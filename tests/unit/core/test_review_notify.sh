#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../../"  # 切换到项目根目录
source scripts/core/exception_handler.sh
mkdir -p data/subjects
echo -e "题干：求极限\n错误：直接代入\n正解：洛必达" > data/subjects/lim01.txt
out=$(./scripts/core/review_notify.sh)
grep -q "题干：求极限" <<< "$out" || { handle invalid_param "抽题失败"; exit 1; }
echo "✅ review_notify.sh 单元测试通过"

