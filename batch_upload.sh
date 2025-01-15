#!/bin/bash

# 目录列表（按实际需要修改）
DIRS=(./buildroot ./debian ./external/a* ./external/c* ./external/d* ./external/g*  ./external/l* ./external/m* ./external/r* ./external ./u-boot ./app ./yocto ./rkbin ./uefi ./kernel ./docs ./tools ./device ./prebuilts)  # 替换为实际的目录名称
BRANCH="main"  # 替换为你的分支名称

for DIR in "${DIRS[@]}"; do
    echo "正在上传目录：$DIR"
    git add "$DIR"
    git commit -m "Add files from $DIR"
    git push -u origin "$BRANCH"
done

echo "所有目录已分批上传完成！"