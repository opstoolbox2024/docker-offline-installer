#!/bin/bash

# 清华镜像站的基础地址
BASE_URL="https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable"

# 定义架构和对应文件夹
ARCH_LIST=("x86_64" "aarch64")
DOWNLOAD_DIR="./docker-binaries"

# 函数：验证 Docker 版本是否有效
check_version() {
    local version=$1
    local success=0

    # 遍历架构并检查文件是否可以下载
    for ARCH in "${ARCH_LIST[@]}"; do
        DOWNLOAD_URL="${BASE_URL}/${ARCH}/docker-${version}.tgz"
        
        # 使用 curl --head 检查文件是否存在
        if curl --head --silent --fail "$DOWNLOAD_URL" >/dev/null; then
            success=1
        fi
    done

    # 返回是否成功
    if [[ $success -eq 1 ]]; then
        return 0  # 版本有效
    else
        return 1  # 版本无效
    fi
}

# 提示用户输入 Docker 版本号，直到下载文件有效
while true; do
    read -p "请输入需要下载的 Docker 版本号（例如 24.0.6）： " DOCKER_VERSION

    # 验证输入是否为空
    if [[ -z "$DOCKER_VERSION" ]]; then
        echo "版本号不能为空，请重新输入有效的版本号！"
        continue
    fi

    # 检查版本是否有效
    check_version "$DOCKER_VERSION"

    if [[ $? -eq 0 ]]; then
        echo "版本号 $DOCKER_VERSION 有效，开始下载 Docker 二进制包。"
        break
    else
        echo "找不到版本号 $DOCKER_VERSION 的 Docker 二进制包，请重新输入有效的版本号！"
    fi
done

# 检查并删除已存在的文件夹
for ARCH in "${ARCH_LIST[@]}"; do
    TARGET_DIR="${DOWNLOAD_DIR}/${ARCH}"
    
    # 如果文件夹已经存在，先删除再创建
    if [[ -d "$TARGET_DIR" ]]; then
        echo "文件夹 $TARGET_DIR 已存在，准备删除并重新创建。"
        rm -rf "$TARGET_DIR"
    fi
    
    # 创建文件夹
    mkdir -pv "$TARGET_DIR"
done

# 遍历架构并下载文件
for ARCH in "${ARCH_LIST[@]}"; do
    TARGET_FILE="${DOWNLOAD_DIR}/${ARCH}/docker.tgz"
    DOWNLOAD_URL="${BASE_URL}/${ARCH}/docker-${DOCKER_VERSION}.tgz"

    echo "准备下载 ${ARCH} 架构的 Docker 二进制包：$DOWNLOAD_URL"

    # 使用 curl 进行下载
    curl -L -o "$TARGET_FILE" "$DOWNLOAD_URL"

    if [[ $? -eq 0 ]]; then
        echo "Docker 二进制包下载成功，文件保存在 ${TARGET_FILE}"
    else
        echo "下载失败：${DOWNLOAD_URL}，请检查版本号或网络连接。"
        exit 1
    fi
done

echo "所有架构的 Docker 二进制包下载完成！"
