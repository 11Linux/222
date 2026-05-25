#!/usr/bin/env bash
DATA_DIR="$(dirname "$0")/../data"
REVIEW_LOG="$DATA_DIR/logs/review.log"
id=$1
[[ -z $id ]] && { echo "用法: $0 <错题id>"; exit 1; }
echo "[$(date '+%F %T')] 已完成复习: $id" >> "$REVIEW_LOG"
echo "✅ 已打卡"
