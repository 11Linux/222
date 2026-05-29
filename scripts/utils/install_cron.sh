#!/usr/bin/env bash
REPO_PATH=\"\$(cd \"\$(dirname \"\$0\")/../..\" && pwd)\"
CRON_JOB=\"0 8 * * * \$REPO_PATH/scripts/core/review_notify.sh | wall\"
(crontab -l 2>/dev/null; echo \"\$CRON_JOB\") | crontab -
echo "已安装每日 08:00 终端提醒"
