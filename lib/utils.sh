#!/bin/bash

# 1. 日志打印函数 (统一格式)
log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

# 2. 检查文件是否存在
check_file_exists() {
    if [ ! -f "$1" ]; then
        log_error "文件不存在: $1"
        return 1
    fi
    return 0
}
# 3. 简单的分隔线
print_separator() {
    echo "----------------------------------------"
}
