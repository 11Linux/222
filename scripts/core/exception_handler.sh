#!/usr/bin/env bash
set -euo pipefail

# 获取脚本所在的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../../data/logs"
ERR_LOG="$LOG_DIR/error.log"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 检查日志文件的权限
if [[ ! -w "$ERR_LOG" ]]; then
    echo "Error: No write permission to log file $ERR_LOG" >&2
    exit 1
fi

log_info() {
    echo "[$(date '+%F %T')] INFO: $*" >> "$ERR_LOG"
}
log_error() {
    echo "[$(date '+%F %T')] ERROR: $*" >> "$ERR_LOG"
}

handle() {
    local type="$1"
    local msg="$2"
    case "$type" in
        file_not_found) log_error "file_not_found: $msg" ;;
        permission_denied) log_error "permission_denied: $msg" ;;
        invalid_param) log_error "invalid_param: $msg" ;;
        *) log_error "unknown: $type $msg" ;;
    esac
}

# 当被直接执行时给出提示
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Usage: source $(basename "$0")"
    echo "       handle <type> <message>"
    exit 0
fi
