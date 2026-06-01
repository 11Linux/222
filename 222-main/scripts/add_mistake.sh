#!/bin/bash

# 1. 定义数据存放的目录（根据你刚才建的目录结构）
DATA_DIR="../data"

# 2. 提示用户输入信息
echo "--------------------------"
echo "   欢迎使用错题录入系统"
echo "--------------------------"

# 读取科目
read -p "请输入科目 (如 数学/英语): " subject

# 读取标签
read -p "请输入错误标签 (如 粗心/概念不清): " tag

# 读取题目描述
read -p "请输入题目内容 (简要题干): " description

# 读取正确解法
read -p "请输入正确解法/解析: " solution

# 3. 自动生成文件名（使用日期时间戳，防止重名）
# 格式如：20260525_1400_math.txt
timestamp=$(date +%Y%m%d_%H%M%S)
filename="${timestamp}_${subject}.txt"

# 4. 将内容写入文件
# 我们把它保存到 data 目录下
cat <<EOF > "${DATA_DIR}/${filename}"
科目: $subject
标签: $tag
时间: $(date "+%Y-%m-%d %H:%M:%S")
--------------------------------
【错误描述】:
$description

【正确解法】:
$solution
--------------------------------
EOF

echo "✅ 录入成功！文件已保存为：${DATA_DIR}/${filename}"
