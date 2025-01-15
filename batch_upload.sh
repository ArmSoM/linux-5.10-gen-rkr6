#!/bin/bash

# 目录列表（按实际需要修改）
DIRS=(./buildroot ./debian ./external/a* ./external/c* ./external/d* ./external/g*  ./external/l* ./external/m* ./external/r* ./external ./u-boot ./app ./yocto ./rkbin ./uefi ./kernel ./docs ./tools ./device ./prebuilts)  # 替换为实际的目录名称
BRANCH="main"  # 替换为你的分支名称

# 初始化 git-lfs（确保你已经安装了 git-lfs）
git lfs install

for DIR in "${DIRS[@]}"; do
    echo "正在处理目录：$DIR"
    
    # 检查目录中的大文件
    LARGE_FILES=$(find "$DIR" -type f -size +100M)
    
    if [ -n "$LARGE_FILES" ]; then
        echo "检测到大文件："
        echo "$LARGE_FILES"
        
        # 使用 git-lfs 处理大文件
        for FILE in $LARGE_FILES; do
            echo "正在添加到 git-lfs: $FILE"
            git lfs track "$FILE"
            git add "$FILE"
        done
    fi
    
    # 上传普通文件
    git add "$DIR"
    git commit -m "Add files from $DIR"
    git push -u origin "$BRANCH"
done

# 提交 git-lfs 的变更
echo "提交 git-lfs 变更..."
git add .gitattributes
git commit -m "Track large files with git-lfs"
git push -u origin "$BRANCH"

echo "所有目录及大文件已分批上传完成！"