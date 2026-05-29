#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../../"  # 切换到项目根目录
source scripts/core/exception_handler.sh
handle file_not_found "test_file.txt"
grep "test_file.txt" $( dirname "$0" )/../../data/logs/error.log && echo "✅ 异常日志记录正常"
