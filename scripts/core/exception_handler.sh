#!/bin/bash

# 统一异常处理模块
# 功能：自动捕获所有错误，生成标准化日志，支持错误回溯

# 日志文件路径（自动创建logs目录）
LOG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." &> /dev/null && pwd )/logs"
LOG_FILE="$LOG_DIR/error.log"
mkdir -p "$LOG_DIR"

# 核心错误处理函数
handle_error() {
    local exit_code=$?
    local failed_command="$BASH_COMMAND"
    local line_number="$LINENO"
    local script_name="$0"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # 写入错误日志
    echo "[$timestamp] ERROR in $script_name (line $line_number):" >> "$LOG_FILE"
    echo "  Command: $failed_command" >> "$LOG_FILE"
    echo "  Exit code: $exit_code" >> "$LOG_FILE"
    echo "  ----------------------------------------" >> "$LOG_FILE"

    # 给用户友好提示
    echo "❌ 脚本执行出错！"
    echo "  错误详情已记录到：$LOG_FILE"
    echo "  请查看日志排查问题"

    exit $exit_code
}

# 捕获所有错误信号（只要有命令执行失败，就自动调用handle_error）
trap 'handle_error' ERR

# 开启严格模式（让脚本更健壮）
set -o errexit  # 任何命令失败立即退出
set -o nounset  # 使用未定义变量时报错
set -o pipefail # 管道中任何命令失败，整个管道返回失败
