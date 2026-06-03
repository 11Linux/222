#!/bin/bash
set +u

# 导入异常处理模块
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXCEPTION_HANDLER_PATH="$SCRIPT_DIR/exception_handler.sh"

if [ -f "$EXCEPTION_HANDLER_PATH" ]; then
    source "$EXCEPTION_HANDLER_PATH"
else
    echo "警告: exception_handler.sh 未找到，跳过异常处理"
fi

<<<<<<< HEAD
# 仓库根目录
# --- 开始替换 ---

# 1. 自动获取当前脚本所在的绝对路径 (例如: .../scripts/core)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2. 向上回退两级，找到项目根目录 (即 scripts 的上一级)
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# 3. 拼接出数据目录的路径
DATA_DIR="$PROJECT_ROOT/data"

# --- 结束替换 ---

ARG1="${1:-}"
=======
REPO_ROOT="/home/2511803104/222"
DATA_DIR="${REPO_ROOT}/data/subjects"
>>>>>>> a032aecaebf7eea61d189b1ecc57feefec5b98e6

# 颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
<<<<<<< HEAD
BLUE='\033[0;34m'
NC='\033[0m' 

# 从文件中提取字段
extract_field() {
    grep "^$1:" "$ARG1" | head -1 | sed 's/^[^:]*: //' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# 获取科目名
get_subject() {
    echo "$ARG1" | sed 's|.*/data/subjects/||' | cut -d'/' -f1
}

# 1. 统计各科目错题数量（条形图）
stats_subject() {
    echo -e "${GREEN}📊 各科目错题数量统计${NC}"
    echo "========================================="
    
    declare -A count_map
    local total=0
    
    # 遍历所有md文件
    while IFS= read -r file; do
        local subject=$(get_subject "$file")
        : "${count_map:=}"
        ((count_map["$subject"]++))
        ((total++))
    done < <(find "$DATA_DIR" -name "*.md")
    
    # 找出最大值用于比例
    local max=0
    for c in "${count_map[@]}"; do
        if (( c > max )); then max=$c; fi
    done
    
    # 输出条形图（每道题显示一个█）
    for subject in "${!count_map[@]}"; do
        local cnt=${count_map["$subject"]}
        # 如果最大数量小于10，每个█代表1道题；否则按比例缩放
        local bar_len=$cnt
        if (( max > 20 )); then
            bar_len=$(( cnt * 20 / max ))
        fi
        # 保证至少显示1个█
        if (( bar_len == 0 && cnt > 0 )); then bar_len=1; fi
        
        local bar=$(printf "%${bar_len}s" | tr ' ' '█')
        printf "%-8s %3d  %s\n" "$subject" "$cnt" "$bar"
    done
    
    echo "-----------------------------------------"
    echo -e "📝 总计: ${YELLOW}${total}${NC} 道错题"
    echo ""
}

# 2. 统计知识点错误频率（Top 5）
stats_tags() {
    echo -e "${GREEN}🏷️  知识点错误频率统计 (Top 5)${NC}"
    echo "========================================="
    
    declare -A tag_count
    
    while IFS= read -r file; do
        local tags=$(extract_field "$file" "tags")
        # 遍历多个标签（如果存在）
        IFS=',' read -ra tag_arr <<< "$tags"
        for t in "${tag_arr[@]}"; do
            # 去除空格
            t=$(echo "$t" | xargs)
            if [[ -n "$t" ]]; then
                ((tag_count["$t"]++))
            fi
        done
    done < <(find "$DATA_DIR" -name "*.md")
    
    # 排序取前5
    local rank=1
    for tag in $(printf "%s\n" "${!tag_count[@]}" | sort -nr -k1 | head -5); do
        local cnt=${tag_count["$tag"]}
        echo "$rank. $tag (错 $cnt 次)"
        ((rank++))
    done
    echo ""
}

# 3. 薄弱知识点分析（找出错最多的模块）
analyze_weak() {
    echo -e "${RED}⚠️  薄弱知识点分析${NC}"
    echo "========================================="
    
    declare -A tag_count
    local total=0
    
    while IFS= read -r file; do
        local tags=$(extract_field "$file" "tags")
        IFS=',' read -ra tag_arr <<< "$tags"
        for t in "${tag_arr[@]}"; do
            t=$(echo "$t" | xargs)
            if [[ -n "$t" ]]; then
                ((tag_count["$t"]++))
                ((total++))
            fi
        done
    done < <(find "$DATA_DIR" -name "*.md")
    
    # 找出错误率最高的1个（薄弱点）
    local max_tag=""
    local max_cnt=0
    for tag in "${!tag_count[@]}"; do
        if (( ${tag_count["$tag"]} > max_cnt )); then
            max_cnt=${tag_count["$tag"]}
            max_tag=$tag
        fi
    done
    
    if [[ -n "$max_tag" ]]; then
        local percent=$(( max_cnt * 100 / total ))
        echo -e "🔥 最薄弱知识点: ${RED}${max_tag}${NC}"
        echo "   错误次数: $max_cnt 次 (占比 ${percent}%)"
        echo -e "   建议: 优先复习 ${YELLOW}${max_tag}${NC} 相关知识"
    else
        echo "暂无数据"
    fi
    echo ""
}

# 4. 生成完整报告
full_report() {
    echo "========================================="
    echo -e "   📋 错题本统计分析报告"
    echo "   生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================="
    echo ""
    stats_subject
    stats_tags
    analyze_weak
    echo "========================================="
    echo -e "${GREEN}✅ 分析完成${NC}"
}
=======
NC='\033[0m'
>>>>>>> a032aecaebf7eea61d189b1ecc57feefec5b98e6

# 显示帮助
show_help() {
    echo "错题统计分析工具"
    echo "用法: ./stat_report.sh [选项]"
    echo "选项:"
    echo "  --subject   仅查看科目统计"
    echo "  --tag       仅查看知识点频率"
    echo "  --weak      仅查看薄弱点分析"
    echo "  -h, --help  显示帮助"
}

<<<<<<< HEAD
# 主入口
case ${1:-help} in
=======
# 1. 科目统计（带条形图）
stats_subject() {
    echo -e "${GREEN}📊 各科目错题数量统计${NC}"
    echo "========================================="
    
    # 临时文件存储统计结果
    tmp_file=$(mktemp)
    find "$DATA_DIR" -name "*.md" 2>/dev/null | sed 's|.*/data/subjects/||' | cut -d'/' -f1 | sort | uniq -c > "$tmp_file"
    
    if [ ! -s "$tmp_file" ]; then
        echo "暂无数据"
        rm -f "$tmp_file"
        return
    fi
    
    # 找出最大数量用于比例
    max=$(awk '{print $1}' "$tmp_file" | sort -rn | head -1)
    
    while read cnt subject; do
        # 每个█代表1道题，如果数量太多就按比例缩小
        if [ $max -le 20 ]; then
            bar_len=$cnt
        else
            bar_len=$(( cnt * 20 / max ))
        fi
        [ $bar_len -eq 0 ] && bar_len=1
        bar=$(printf "%${bar_len}s" | tr ' ' '█')
        printf "%-8s %3d  %s\n" "$subject" "$cnt" "$bar"
    done < "$tmp_file"
    
    total=$(awk '{sum+=$1} END {print sum}' "$tmp_file")
    echo "-----------------------------------------"
    echo -e "📝 总计: ${YELLOW}${total}${NC} 道错题"
    rm -f "$tmp_file"
}

# 2. 知识点频率统计
stats_tag() {
    echo -e "${GREEN}🏷️ 知识点错误频率统计 (Top 5)${NC}"
    echo "========================================="
    
    tmp_file=$(mktemp)
    find "$DATA_DIR" -name "*.md" 2>/dev/null -exec grep "^tags: " {} \; | sed 's/^tags: //' | tr ',' '\n' | sed 's/^ //' | sort | uniq -c | sort -rn | head -5 > "$tmp_file"
    
    if [ ! -s "$tmp_file" ]; then
        echo "暂无数据"
        rm -f "$tmp_file"
        return
    fi
    
    rank=1
    while read cnt tag; do
        echo "$rank. $tag (错 $cnt 次)"
        rank=$((rank + 1))
    done < "$tmp_file"
    rm -f "$tmp_file"
}

# 3. 薄弱点分析
stats_weak() {
    echo -e "${RED}⚠️ 薄弱知识点分析${NC}"
    echo "========================================="
    
    # 找出错最多的标签
    top_tag=$(find "$DATA_DIR" -name "*.md" 2>/dev/null -exec grep "^tags: " {} \; | sed 's/^tags: //' | tr ',' '\n' | sed 's/^ //' | sort | uniq -c | sort -rn | head -1)
    
    if [ -z "$top_tag" ]; then
        echo "暂无数据"
        return
    fi
    
    cnt=$(echo "$top_tag" | awk '{print $1}')
    tag=$(echo "$top_tag" | awk '{print $2}')
    
    # 计算总题数
    total=$(find "$DATA_DIR" -name "*.md" 2>/dev/null | wc -l)
    if [ $total -eq 0 ]; then
        echo "暂无数据"
        return
    fi
    
    percent=$(( cnt * 100 / total ))
    echo -e "🔥 最薄弱知识点: ${RED}${tag}${NC}"
    echo "   错误次数: $cnt 次 (占比 ${percent}%)"
    echo -e "   建议: 优先复习 ${YELLOW}${tag}${NC} 相关知识"
}

case ${1:-""} in
>>>>>>> a032aecaebf7eea61d189b1ecc57feefec5b98e6
    --subject)
        stats_subject
        ;;
    --tag)
        stats_tag
        ;;
    --weak)
        stats_weak
        ;;
    -h|--help)
        show_help
        ;;
    *)
<<<<<<< HEAD
        echo "未知选项: $ARG1"
        show_help
=======
        echo "未知选项，使用 -h 查看帮助"
>>>>>>> a032aecaebf7eea61d189b1ecc57feefec5b98e6
        ;;
esac
