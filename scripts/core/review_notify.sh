#!/usr/bin/env bash
# review_notify.sh
# 每日随机抽取 1 道当天需要复习的错题
# 复习间隔遵循艾宾浩斯曲线：1 2 4 7 15 30 天

# 导入异常处理模块
source scripts/core/exception_handler.sh

# 定位仓库根目录（脚本位于 scripts/core/）
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# 内部固定路径
REVIEW_LOG="$REPO_ROOT/data/logs/review.log"
DATA_DIR="$REPO_ROOT/data"
SUBJECTS_DIR="$DATA_DIR/subjects"


# 若目录不存在则自动创建
mkdir -p "$(dirname "$REVIEW_LOG")"

# ===== 复习间隔常量 =====
INTERVALS=(1 2 4 7 15 30)

# 计算下一复习间隔天数
get_next_review() {
    local id=$1
    local count=$(grep -c "$id" "$REVIEW_LOG" 2>/dev/null || echo 0)
    local idx=$(( count < ${#INTERVALS[@]} ? count : ${#INTERVALS[@]} - 1 ))
    echo "${INTERVALS[$idx]}"
}

# 判断今天是否需要复习该题
needs_review() {
    local id=$1
    local last_date
    last_date=$(grep "$id" "$REVIEW_LOG" | tail -1 | awk '{print $1}')
    [[ -z $last_date ]] && return 0        # 第一次出现，立即复习

    local next_review_date
    next_review_date=$(date -d "$last_date +$(get_next_review "$id") days" +%F)
    [[ $(date +%F) == "$next_review_date" ]]
}

# ===== 主流程 =====
# 收集所有错题
mapfile -t candidates < <(find "$DATA_DIR/subjects" -type f -name "*.txt")

to_review=()
for f in "${candidates[@]}"; do
    id=$(basename "$f" .txt)
    needs_review "$id" && to_review+=("$f")
done

# 没有需要复习的题目
if ((${#to_review[@]} == 0)); then
    msg="[$(date '+%F %T')] 今日无待复习错题"
    echo "$msg" | tee -a "$REVIEW_LOG"
    exit 0
fi

# 随机挑选 1 道
choice=${to_review[$RANDOM % ${#to_review[@]}]}
echo "[$(date '+%F %T')] 今日复习: $(basename "$choice")" >> "$REVIEW_LOG"
cat "$choice"

