#!/bin/bash

# 引入我们的工具库
# source 命令相当于把 utils.sh 的代码在这里展开运行
source ./lib/utils.sh

echo "=== 错题本项目启动 ==="

# 测试 1：打印日志
log_info "系统初始化完成..."

# 测试 2：检查文件
# 我们先故意检查一个不存在的文件，看看报错是否漂亮
check_file_exists "data/notes.txt"

if [ $? -ne 0 ]; then
    log_error "检测到数据文件缺失，请检查路径！"
else
    log_info "数据文件加载成功。"
fi

print_separator
echo "测试结束。"
