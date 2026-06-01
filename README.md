# 错题检索与统计分析模块

## 开发者
同学3

## 文件说明

| 文件 | 功能 |
|------|------|
| `scripts/core/query_note.sh` | 错题检索模块 |
| `scripts/core/stat_report.sh` | 错题统计分析模块 |

---

## 一、检索模块 (query_note.sh)

### 功能
支持按科目、标签、日期、关键词搜索错题

### 使用方法

```bash
# 进入脚本目录
cd ~/222/scripts/core

# 列出所有科目
./query_note.sh -l

# 按科目搜索
./query_note.sh -s 数学

# 按标签搜索
./query_note.sh -t 基础概念

# 按日期搜索（格式：YYYY-MM-DD）
./query_note.sh -d 2026-05-24

# 按关键词搜索（在题干中搜索）
./query_note.sh -k 加法

# 查看帮助
./query_note.sh -h

## 二、统计模块 (stat_report.sh)

### 功能
- 统计各科目错题数量（带条形图）
- 统计知识点错误频率 Top 5
- 分析薄弱知识点

### 使用方法

```bash
cd ~/222/scripts/core

# 生成完整报告
./stat_report.sh

# 仅查看科目统计
./stat_report.sh --subject

# 仅查看知识点频率
./stat_report.sh --tag

# 仅查看薄弱点分析
./stat_report.sh --weak

# 查看帮助
./stat_report.sh -h

