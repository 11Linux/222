## 错题录入与编辑模块

## 开发者
刘瑞婷

## 文件说明
| 文件 | 功能 |
|------|------|
| `scripts/core/add_note.sh` | 错题录入模块 |
| `scripts/core/edit_note.sh` | 错题编辑模块 |

---

## 一、录入模块（add_note.sh）
### 功能
- 支持交互式录入错题题干、正确答案、解析、知识点标签
- 自动按科目、日期生成标准化Markdown存储文件
- 实现重复录入检测，避免相同错题重复存储
- 自动生成全局唯一错题ID

### 使用方法
```bash
# 进入脚本目录
cd ~/222/scripts/core

# 运行录入脚本
./add_note.sh

# 按照提示依次选择科目、输入题干、答案、解析和标签即可
```

## 二、编辑模块（edit_note.sh）
### 功能
- 支持按错题 ID 精确搜索并定位错题文件
- 可修改错题的任意字段：题干、正确答案、解析、知识点标签
- 自动备份修改前的版本，支持历史版本回退
- 保留完整的修改历史记录
- 自动更新错题的最后修改时间

## 使用方法
```bash
# 进入脚本目录
cd ~/222/scripts/core

# 编辑指定ID的错题
./edit_note.sh <错题ID>

# 示例：编辑ID为1的错题
./edit_note.sh 1

# 脚本会自动查找并显示当前错题信息
# 按照提示选择要修改的字段序号
# 输入新内容后按回车确认即可完成修改
```

## 错题检索与统计分析模块

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
```

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
```
