# Auto-Deploy-Script

> 一键部署脚本 —— 在 CentOS 上快速安装并配置 JDK17、MySQL、Redis、MinIO、Nginx，以及应用服务反向代理。

---

## ✨ 功能特点

- **环境准备**：自动更新系统并安装 `wget`、`nano`、`unzip`、`tmux`
- **JDK 17**：自动安装 OpenJDK 17
- **MySQL 8**：自动安装并初始化 root 密码
- **Redis**：一键安装并启动
- **MinIO**：下载二进制，配置 systemd 服务，自动创建数据目录
- **Nginx**：安装并生成前后端反向代理配置
- **Java 后端**：将 `backend.jar` 部署为 systemd 服务，自动启动并开机自启
- **防火墙**：开启必要端口（80、后端端口、9000）
- **日志管理**：统一软链接日志到 `/var/log/app-logs`
- **部署验证**：脚本结束后打印各服务状态及访问 URL 提示

---

## 📦 使用方法

```bash
# 克隆项目
git clone https://github.com/huomadangsimayi/Auto-Deploy-Script.git
cd Auto-Deploy-Script

# 给脚本赋予可执行权限
chmod +x Deploy.sh

# 使用 root 权限运行
sudo ./Deploy.sh
