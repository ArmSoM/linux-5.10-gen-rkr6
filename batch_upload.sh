#!/bin/bash

# 获取所有未追踪的文件列表
FILES=$(git ls-files --others --exclude-standard)
BATCH_SIZE=50  # 每批次上传的文件数量

echo "开始分批上传文件，每批次 $BATCH_SIZE 个文件..."

# 分批上传
count=0
batch=1
for FILE in $FILES; do
    git add "$FILE"
    count=$((count + 1))

    # 达到批次大小后提交
    if [ "$count" -eq "$BATCH_SIZE" ]; then
        echo "提交批次 $batch..."
        git commit -m "Batch $batch: Upload files"
        git push -u origin main
        count=0
        batch=$((batch + 1))
    fi
done

# 提交剩余文件
if [ "$count" -gt 0 ]; then
    echo "提交剩余文件..."
    git commit -m "Final batch: Upload remaining files"
    git push -u origin main
fi

echo "所有文件已分批上传完成！"

