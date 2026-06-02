#!/bin/bash

# 这是一个简单的日志打印函数
log_message() {
    local level="$1"
    local msg="$2"
    # 输出格式：[级别] 消息内容
    echo "[$level] $msg"
}
