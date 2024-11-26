#!/bin/bash

# 检查系统是否已安装 Docker
if ! command -v docker &>/dev/null; then
    echo "系统中未检测到 Docker，无法执行卸载操作。"
    exit 0
fi

# 提示用户确认卸载，并默认选择 "no"
read -p "确定要卸载 Docker 吗？（yes/no，默认：no）: " uninstall_input
uninstall_input=${uninstall_input:-no} # 如果用户未输入，默认值为 "no"

# 将用户输入转换为小写
uninstall_input=$(echo "$uninstall_input" | tr '[:upper:]' '[:lower:]')

case $uninstall_input in
    yes|y)
        echo "开始卸载 Docker..."

        # 检查是否存在 Docker 服务文件
        if systemctl list-units --all | grep -q docker.service; then
            echo "正在停止 Docker 服务..."
            systemctl stop docker
        else
            echo "Docker 服务未运行或未找到。"
        fi

        # 移除 Docker 服务文件
        echo "正在移除 docker.service 和 docker.socket..."
        rm -f /etc/systemd/system/docker.service
        rm -f /etc/systemd/system/docker.socket
        rm -f /etc/systemd/system/multi-user.target.wants/docker.service
        # 删除 Docker 可执行文件
        echo "正在移除 Docker 可执行文件..."
        rm -rf /usr/bin/docker*

        # 重新加载系统守护进程配置
        echo "正在重新加载系统守护进程配置..."
        systemctl daemon-reload

        echo "Docker 已成功卸载。"
        ;;
    no|n)
        echo "卸载已取消。"
        exit 0
        ;;
    *)
        echo "输入无效，请重新运行脚本并输入有效选项（yes 或 no）。"
        exit 1
        ;;
esac

