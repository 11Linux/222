#!/usr/bin/env bash
set -euo pipefail
LOG_DIR="$(dirname "$0")/../../data/logs"
ERR_LOG="$LOG_DIR/system.log"
mkdir -p "$LOG_DIR"

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
