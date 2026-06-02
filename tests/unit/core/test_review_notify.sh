#!/usr/bin/env bash
# test_review_notify.sh
# 单元测试：复习提醒模块 review_notify.sh

# 颜色定义，用于区分测试结果
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # 恢复默认颜色

# 获取当前脚本所在目录，定位被测试的主脚本
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(dirname $(dirname $(dirname "$SCRIPT_DIR")))
REVIEW_NOTIFY_PATH="$PROJECT_ROOT/scripts/core/review_notify.sh"
EXCEPTION_HANDLER_PATH="$PROJECT_ROOT/scripts/core/exception_handler.sh"

# 初始化测试统计
total=0
passed=0
failed=0

# 测试开始前的准备工作
setup() {
    echo "=== 准备测试环境 ==="
    # 创建临时测试目录
    TEST_TMP="$SCRIPT_DIR/../test_tmp"
    mkdir -p "$TEST_TMP/subjects"
    mkdir -p "$TEST_TMP/logs"

    # 创建测试用错题文件 1：首次添加，未复习
    cat > "$TEST_TMP/subjects/shell_test_001.md" <<EOF
id: 10001
question: 什么是Bash中的特殊变量\$0？
answer: 表示当前脚本的名称。
subject: Linux Shell
review_status: 未复习
review_count: 0
EOF

    # 创建测试用错题文件 2：已经复习过1次，今天刚好到复习日
    cat > "$TEST_TMP/subjects/shell_test_002.md" <<EOF
id: 10002
question: 如何在Bash中获取脚本所在的绝对目录？
answer: 通过cd "\$( dirname "\${BASH_SOURCE[0]}" )" && pwd获取。
subject: Linux Shell
review_status: 未复习
review_count: 1
EOF

    # 提前写入复习日志，让第二题今天需要复习
    REVIEW_LOG="$TEST_TMP/logs/review.log"
    yesterday=$(date -d "1 day ago" +%F)
    echo "[$yesterday 10:00:00] Review today: shell_test_002.md" >> "$REVIEW_LOG"

    echo "测试环境准备完成"
    echo
}

# 单个测试用例断言函数
assert() {
    local test_name="$1"
    local condition="$2"
    total=$((total+1))
    if eval "$condition"; then
        echo -e "${GREEN}✅ 测试通过：$test_name${NC}"
        passed=$((passed+1))
        return 0
    else
        echo -e "${RED}❌ 测试失败：$test_name${NC}"
        failed=$((failed+1))
        return 1
    fi
}

# ===== 测试用例开始 =====

test_01_check_main_script_exists() {
    echo "--- 测试用例1：检查主脚本文件存在 ---"
    assert "主脚本文件存在" "[ -f '$REVIEW_NOTIFY_PATH' ]"
}

test_02_check_exception_handler_exists() {
    echo "--- 测试用例2：检查异常处理模块存在 ---"
    assert "异常处理模块存在" "[ -f '$EXCEPTION_HANDLER_PATH' ]"
}

test_03_test_extract_field() {
    echo "--- 测试用例3：测试字段提取函数 ---"
    # 导入主脚本的函数
    source "$REVIEW_NOTIFY_PATH" >/dev/null 2>&1
    local result=$(extract_field "$TEST_TMP/subjects/shell_test_001.md" "id")
    # 核心修改：加上双引号包裹变量，用正确的Bash字符串比较语法
    assert "正确提取id字段" "[ \"$result\" = '10001' ]"
}

test_04_needs_review_first_question() {
    echo "--- 测试用例4：首次添加的题目应该需要复习 ---"
    # 去掉>/dev/null 2>&1，让错误信息打印出来，就能看到具体问题
    source "$REVIEW_NOTIFY_PATH"
    # 覆盖日志路径为测试临时目录
    REVIEW_LOG="$TEST_TMP/logs/review.log"
    mkdir -p "$(dirname "$REVIEW_LOG")"
    touch "$REVIEW_LOG" # 确保日志文件存在，避免grep执行出错
    needs_review "10001"
    assert "首次题目需要复习" "[ $? -eq 0 ]"
}

test_05_get_next_review_interval() {
    echo "--- 测试用例5：测试艾宾浩斯间隔计算 ---"
    source "$REVIEW_NOTIFY_PATH" >/dev/null 2>&1
<<<<<<< HEAD
    
    # 确保INTERVALS数组已定义
    if [ -z "${INTERVALS+x}" ]; then
        INTERVALS=(1 2 4 7 15 30)
    fi
    
    # 覆盖日志路径为测试临时目录
    REVIEW_LOG="$TEST_TMP/logs/review.log"
    mkdir -p "$(dirname "$REVIEW_LOG")"
    touch "$REVIEW_LOG"
    
    local interval=$(get_next_review "10001")
    # 验证interval是数字且等于1
    if [[ "$interval" =~ ^[0-9]+$ ]] && [ "$interval" -eq 1 ]; then
        assert "复习0次对应间隔1天" "true"
    else
        assert "复习0次对应间隔1天" "false"
    fi
=======
    # 复习0次，间隔应该是1天
    local interval=$(get_next_review "10001")
    assert "复习0次对应间隔1天" "$interval -eq 1"
>>>>>>> a032aecaebf7eea61d189b1ecc57feefec5b98e6
}

test_06_update_markdown_status() {
    echo "--- 测试用例6：测试更新Markdown复习状态 ---"
    source "$REVIEW_NOTIFY_PATH" >/dev/null 2>&1
    REVIEW_LOG="$TEST_TMP/logs/review.log"
    update_markdown_file "$TEST_TMP/subjects/shell_test_001.md" "已复习" "1"
    local new_status=$(grep "review_status:" "$TEST_TMP/subjects/shell_test_001.md" | awk '{print $2}')
    local new_count=$(grep "review_count:" "$TEST_TMP/subjects/shell_test_001.md" | awk '{print $2}')
    assert "复习状态更新正确" "[ \"$new_status\" = '已复习' ]"
    # 最安全的写法：确保变量被正确引用
    assert "复习次数更新正确" "[ \"$new_count\" = \"1\" ]"
}

# 测试收尾清理
teardown() {
    echo
    echo "=== 清理测试环境 ==="
    rm -rf "$TEST_TMP"
    echo "临时文件已清理"
    echo
    echo "=== 测试结果汇总 ==="
    echo "总测试用例：$total"
    echo -e "${GREEN}通过：$passed${NC}"
    echo -e "${RED}失败：$failed${NC}"
}

# ===== 主测试流程 =====
setup
test_01_check_main_script_exists
test_02_check_exception_handler_exists
test_03_test_extract_field
test_04_needs_review_first_question
test_05_get_next_review_interval
test_06_update_markdown_status
teardown

# 如果全部通过，退出码为0，否则为1
if [ $failed -eq 0 ]; then
    exit 0
else
    exit 1
<<<<<<< HEAD
fi 
=======
fi  
>>>>>>> a032aecaebf7eea61d189b1ecc57feefec5b98e6
