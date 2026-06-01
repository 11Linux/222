#!/bin/bash
mkdir -p data/subjects/数学/2026/06/01

for i in $(seq 1 1000); do
    cat > data/subjects/数学/2026/06/01/test_${i}.md << 'EOF'
---
id: 1000
subject: 数学
tags: 测试
create_time: 2026-06-01 10:00:00
update_time: 2026-06-01 10:00:00
review_status: 未复习
review_count: 0
---

# 题干
这是测试错题

# 正确答案
答案

# 解析
解析内容

# 错误原因
错误原因
EOF
    # 替换每条的id为实际序号
    sed -i "s/id: 1000/id: $i/" data/subjects/数学/2026/06/01/test_${i}.md
done

echo "✅ 已生成1000条测试数据"
