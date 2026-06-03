#!/usr/bin/env bash
# review_notify.sh
# 每日按优先级抽取当天需要复习的错题，复习间隔遵循艾宾浩斯曲线+掌握度自适应调整
# 增强特性：权重抽题+自适应间隔+原子更新+异常处理接入

# 导入异常处理模块和配置（先确保路径正确）
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
EXCEPTION_HANDLER_PATH="$SCRIPT_DIR/exception_handler.sh"
CONFIG_PATH="$SCRIPT_DIR/../../config/global.conf"

# 检查文件并使用异常处理模块
if [ -f "$EXCEPTION_HANDLER_PATH" ]; then
    source "$EXCEPTION_HANDLER_PATH"
else
    echo "Error: exception_handler.sh not found at $EXCEPTION_HANDLER_PATH" >&2
    exit 1
fi

if [ -f "$CONFIG_PATH" ]; then
    source "$CONFIG_PATH"
else
    handle_error "CONFIG_MISSING" "Config file not found at $CONFIG_PATH"
    exit 1
fi

# 从 MD 文件中提取字段（和检索模块统一规则）
extract_field() {
    grep "^$2:" "$1" | head -1 | sed 's/^[^:]*: //' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# 定位仓库根目录（脚本位于 scripts/core/）
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# 内部固定路径
REVIEW_LOG="$REPO_ROOT/data/logs/review.log"
DATA_DIR="$REPO_ROOT/data"
SUBJECTS_DIR="$DATA_DIR/subjects"

# 若目录不存在则自动创建
mkdir -p "$(dirname "$REVIEW_LOG")"

# ===== 增强1：自适应复习间隔（支持掌握度调整）=====
# 基础艾宾浩斯间隔，错一次重置，掌握越好间隔越长
BASE_INTERVALS=(1 2 4 7 15 30)
# 掌握度系数：1=需要重点复习，5=完全掌握，系数越大间隔越长
DIFFICULTY_FACTOR=(0.5 0.75 1.0 1.5 2.0)

# 计算下一复习间隔天数（自适应调整）
get_next_review() {
    local note_id=$1
    local difficulty=$2
    # 获取已复习次数
    local count=$(grep -c "$note_id" "$REVIEW_LOG" 2>/dev/null || echo 0)
    local base_idx=$(( count < ${#BASE_INTERVALS[@]} ? count : ${#BASE_INTERVALS[@]} - 1 ))
    local base_interval=${BASE_INTERVALS[$base_idx]}
    # 按难度调整间隔：难度越高（越难），间隔越短，增加复习频率
    local difficulty_idx=$(( difficulty - 1 ))
    local factor=${DIFFICULTY_FACTOR[$difficulty_idx]}
    echo $(( base_interval * factor )) | awk '{print int($1+0.5)}'
}

# 判断今天是否需要复习该题
needs_review() {
    local note_id=$1
    local last_date
    last_date=$(grep "$note_id" "$REVIEW_LOG" | tail -1 | awk '{print $1}' | sed 's/\[//; s/\]//')

    # 第一次出现，立即复习
    [[ -z $last_date ]] && return 0

    # 验证日期合法性
    if ! date -d "$last_date" +%F > /dev/null 2>&1; then
        handle_error "INVALID_DATE" "Invalid last review date '$last_date' for note $note_id"
        return 1
    fi

    # 读取本题难度，计算复习日期
    local difficulty=$2
    [[ -z "$difficulty" ]] && difficulty=3 # 默认中等难度
    local interval=$(get_next_review "$note_id" "$difficulty")

    if ! [[ "$interval" =~ ^[0-9]+$ ]]; then
        handle_error "INVALID_INTERVAL" "Invalid interval '$interval' for note $note_id"
        return 1
    fi

    next_review_date=$(date -d "$last_date + $interval days" +%F)
    [[ $(date +%F) == "$next_review_date" ]] && return 0
    return 1
}

# ===== 增强2：带权重的随机抽题（优先抽难/久未复习的题）=====
weighted_pick() {
    local -n notes=$1 # 传入待复习题目数组
    local total_weight=0
    local -A weights=()

    # 为每个题目计算权重
    for note in "${notes[@]}"; do
        # 难度越低（越难）权重越高；复习次数越少权重越高
        difficulty=$(extract_field "$note" "difficulty")
        [[ -z "$difficulty" ]] && difficulty=3
        count=$(grep -c "$(extract_field "$note" "id")" "$REVIEW_LOG" 2>/dev/null || echo 0)
        weight=$(( (6 - difficulty) * (6 - count) )) # 权重范围 1~25
        weights["$note"]=$weight
        total_weight=$(( total_weight + weight ))
    done

    # 按权重随机抽取
    local rand=$(( RANDOM % total_weight + 1 ))
    local current=0
    for note in "${notes[@]}"; do
        current=$(( current + weights["$note"] ))
        if (( current >= rand )); then
            echo "$note"
            return
        fi
    done

    # 兜底：如果随机失败返回第一个
    echo "${notes[0]}"
}

# ===== 增强3：原子化更新Markdown状态（避免文件损坏）=====
update_markdown_file() {
    local file_path=$1
    local new_status=$2
    local new_count=$3
    local new_next_date=$4

    # 临时文件用于原子更新
    local temp_file="${file_path}.tmp.$$"

    # 逐行更新对应字段，保留其他内容不变
    awk -v status="$new_status" -v count="$new_count" -v next_date="$new_next_date" '
        /^review_status:/ { printf "review_status: %s\n", status; next }
        /^review_count:/ { printf "review_count: %d\n", count; next }
        /^next_review_date:/ { printf "next_review_date: %s\n", next_date; next }
        1
    ' "$file_path" > "$temp_file"

    # 更新成功才替换原文件
    if [ $? -eq 0 ] && [ -s "$temp_file" ]; then
        mv "$temp_file" "$file_path"
        return 0
    else
        rm -f "$temp_file"
        handle_error "FILE_UPDATE_FAILED" "Failed to update markdown file $file_path"
        return 1
    fi
}

# ===== 主流程 =====
handle_info "START_REVIEW" "Starting daily review check"

# 收集所有错题
mapfile -t all_notes < <(find "$DATA_DIR/subjects" -type f -name "*.md")

to_review=()
for f in "${all_notes[@]}"; do
    id=$(extract_field "$f" "id")
    difficulty=$(extract_field "$f" "difficulty")
    if needs_review "$id" "$difficulty"; then
        to_review+=("$f")
    fi
done

# 没有需要复习的题目
if [ ${#to_review[@]} -eq 0 ]; then
    msg="[$(date '+%F %T')] No questions to review today"
    echo "$msg" | tee -a "$REVIEW_LOG"
    [ -x "$(command -v xmessage)" ] && xmessage -center "🎉 No questions to review today, well done!"
    exit 0
fi

# 增强：按权重随机抽取，优先复习难题/新题
choice=$(weighted_pick to_review)
echo "[$(date '+%F %T')] Review today: $(basename "$choice")" >> "$REVIEW_LOG"
subject_name=$(basename "$choice" .md)
echo "🔔 Today's review question: $subject_name"
[ -x "$(command -v xmessage)" ] && xmessage -center "Today's review: $subject_name"

# 显示题目内容（增强体验）
echo "---------- Question Content ----------"
grep -v '^[a-z_]*:' "$choice" | sed '/^$/d'
echo "--------------------------------------"

# 复习打卡功能
read -p "✅ Have you finished reviewing? (y/n): " completed
if [[ $completed == "y" ]]; then
    echo "[$(date '+%F %T')] Finished reviewing: $(basename "$choice")" >> "$REVIEW_LOG"
    [ -x "$(command -v xmessage)" ] && xmessage -center "✅ Finished reviewing: $subject_name"

    # 读取原有复习信息，增加容错处理
    review_status=$(extract_field "$choice" "review_status")
    review_count=$(extract_field "$choice" "review_count")
    difficulty=$(extract_field "$choice" "difficulty")
    [[ -z "$review_count" ]] && review_count=0
    [[ -z "$difficulty" ]] && difficulty=3

    # 更新状态：未复习 → 已复习，复习次数+1
    new_status="已复习"
    ((review_count++))
    id=$(extract_field "$choice" "id")
    next_interval=$(get_next_review "$id" "$difficulty")
    next_review_date=$(date -d "$(date +%F) + $next_interval days" +%F)

    # 更新Markdown文件
    if update_markdown_file "$choice" "$new_status" "$review_count" "$next_review_date"; then
        echo "✅ Review checked, next review on $next_review_date"
    else
        echo "⚠️  Failed to update review status, please check manually"
    fi
else
    echo "[$(date '+%F %T')] Deferred reviewing: $(basename "$choice")" >> "$REVIEW_LOG"
    [ -x "$(command -v xmessage)" ] && xmessage -center "⏳ Review deferred: $subject_name"
    exit 1
fi

handle_info "REVIEW_COMPLETE" "Daily review finished successfully"
exit 0

