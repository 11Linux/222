# scripts/utils/template_utils.sh

#!/bin/bash

# 函数：根据模板创建Markdown文件
create_markdown_file() {
    local template_path=$1
    local output_file=$2
    local id=$3
    local subject=$4
    local question=$5
    local answer=$6
    local analysis=$7
    local tags=$8

    # 读取模板内容
    template=$(cat "$template_path")

    # 替换模板中的占位符
    template=$(echo "$template" | sed "s/{{id}/$id/g")
    template=$(echo "$template" | sed "s/{{subject}/$subject/g")
    template=$(echo "$template" | sed "s/{{question}/$question/g")
    template=$(echo "$template" | sed "s/{{answer}/$answer/g")
    template=$(echo "$template" | sed "s/{{analysis}/$analysis/g")
    template=$(echo "$template" | sed "s/{{tags}/$tags/g")

    # 写入Markdown文件
    echo "$template" > "$output_file"
}

# 函数：更新Markdown文件中的复习状态和次数
update_markdown_file() {
    local file_path=$1
    local new_status=$2
    local new_count=$3

    # 读取文件内容
    content=$(cat "$file_path")

    # 更新复习状态和次数
    content=$(echo "$content" | sed "s/review_status: [^ ]*/review_status: $new_status/g")
    content=$(echo "$content" | sed "s/review_count: [^ ]*/review_count: $new_count/g")

    # 写回文件
    echo "$content" > "$file_path"
}
