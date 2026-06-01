#!/bin/bash
# 导入异常处理模块
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXCEPTION_HANDLER_PATH="$SCRIPT_DIR/exception_handler.sh"

if [ -f "$EXCEPTION_HANDLER_PATH" ]; then
    source "$EXCEPTION_HANDLER_PATH"
else
    echo "警告: exception_handler.sh 未找到，跳过异常处理"
fi
# ============================================
# 错题统计分析模块
# 用法：./stat_report.sh
# ============================================

# 仓库根目录
REPO_ROOT="/home/2511803104/222"
DATA_DIR="${REPO_ROOT}/data/subjects"

# 颜色美化
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

# 从文件中提取字段
extract_field() {
    grep "^$2:" "$1" | head -1 | sed 's/^[^:]*: //' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# 获取科目名
get_subject() {
    echo "$1" | sed 's|.*/data/subjects/||' | cut -d'/' -f1
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

# 主入口
case $1 in
    --subject)
        stats_subject
        ;;
    --tag)
        stats_tags
        ;;
    --weak)
        analyze_weak
        ;;
    --full|"")
        full_report
        ;;
    -h|--help)
        show_help
        ;;
    *)
        echo "未知选项: $1"
        show_help
        ;;
esac
