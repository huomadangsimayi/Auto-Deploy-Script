好的，这是您可以直接复制的完整 Markdown 代码。

```markdown
# 一键部署全栈应用环境脚本

这是一个用于在 CentOS 7 服务器上自动化部署和配置完整后端服务环境的 Shell 脚本。该脚本能够自动安装并配置 Nginx、Java (OpenJDK 17)、MySQL 8、Redis 和 MinIO，并设置好相关的系统服务和防火墙规则。

## ✨ 功能特性

*   **环境自动化**：自动安装所有必要的开发工具和依赖项。
*   **Java 后端服务**：安装 Java 17 环境，并为您的后端 JAR 包应用设置 systemd 服务，实现开机自启和进程守护。
*   **数据库与缓存**：安装并配置 MySQL 8 和 Redis，并将其设置为开机自启。
*   **对象存储**：安装并配置 MinIO 服务器，提供 S3 兼容的对象存储服务。
*   **反向代理**：配置 Nginx 作为反向代理，统一通过 80 端口代理前端和后端 API 服务。
*   **服务管理**：为后端应用、MinIO 等关键组件创建并启用 systemd 服务，方便启停和管理。
*   **防火墙配置**：自动配置防火墙，开放 Nginx 和后端服务所需的端口。
*   **日志管理**：创建集中的日志目录，方便排查问题。

## ⚙️ 先决条件

*   一台运行 **CentOS 7** 的服务器。
*   必须拥有 **root** 权限才能执行此脚本。
*   你需要提前准备好打包为 `.jar` 格式的后端应用程序。

## 🚀 如何使用

### 1. 下载脚本

你可以通过 `git` 克隆本仓库，或者直接下载脚本文件。

```bash
# 克隆仓库
git clone <你的仓库地址>
cd <你的仓库目录>

# 或者直接下载
wget https://raw.githubusercontent.com/<你的用户名>/<你的仓库名>/main/deploy.sh
```

### 2. 配置参数

在执行脚本之前，请务必使用文本编辑器（如 `nano` 或 `vim`）打开 `deploy.sh` 文件，修改文件头部的配置参数。

```bash
#!/bin/bash

# 配置参数
BACKEND_PORT=8080               # 后端 Spring Boot 应用的端口
NGINX_PORT=80                   # Nginx 对外暴露的端口
DB_PASSWORD="your_strong_password" # 设置新的 MySQL root 密码
MINIO_ACCESS_KEY="your_minio_access_key" # 设置 MinIO 的 Access Key
MINIO_SECRET_KEY="your_minio_secret_key" # 设置 MinIO 的 Secret Key

# ... 脚本其余部分
```

**请务必将 `￥￥￥` 替换为强密码和安全的密钥！**

### 3. 放置应用文件

脚本会自动创建所需目录，但你需要手动将应用文件放置到正确的位置。

*   **后端应用**: 将你的 Java 应用（例如 `my-app.jar`）上传到服务器，重命名为 `backend.jar` 并移动到 `/opt/app/` 目录下。
    ```bash
    # 如果目录不存在，脚本会自动创建
    # 你需要确保 backend.jar 文件最终位于此路径
    mv /path/to/your/app.jar /opt/app/backend.jar
    ```

*   **前端项目** (可选): 将你的前端静态文件（HTML, CSS, JavaScript 等）放置在 `/usr/share/nginx/html` 目录下。脚本会在这里创建一个简单的占位符页面。

### 4. 执行脚本

授予脚本执行权限并运行。

```bash
chmod +x deploy.sh
./deploy.sh
```

脚本会自动完成所有安装和配置工作。

## ✅ 验证部署

脚本执行完毕后，会输出各个服务的状态和访问地址。

### 查看服务状态

你可以随时通过以下命令检查核心服务的运行状态：

```bash
systemctl status nginx
systemctl status backend
systemctl status mysqld
systemctl status redis
systemctl status minio
```

### 访问应用

部署完成后，你可以通过以下地址访问：

*   **前端应用**: `http://<你的服务器IP>`
*   **后端 API**: `http://<你的服务器IP>/api`
*   **MinIO 控制台**: `http://<你的服务器IP>:9000` (使用你配置的 `MINIO_ACCESS_KEY` 和 `MINIO_SECRET_KEY` 登录)

## 📜 日志管理

为了方便调试，脚本将关键日志软链接到了 `/var/log/app-logs/` 目录。

*   **查看后端应用日志**:
    ```bash
    tail -f /var/log/app-logs/backend.log
    ```
*   **查看 Nginx 访问日志**:
    ```bash
    tail -f /var/log/app-logs/frontend-access.log
    ```

## ⚠️ 注意事项

*   本脚本专为 CentOS 7 设计，在其他操作系统上可能无法正常运行。
*   为了安全起见，强烈建议不要在生产环境中直接使用 root 密码和默认密钥，请务必修改为复杂且唯一的凭证。
*   脚本会自动从 MySQL 的初始日志中提取临时密码来设置新密码，请确保 `/var/log/mysqld.log` 文件可读。
*   在生产环境中，建议进行更详细的安全加固，例如为应用创建非 root 用户、配置更严格的防火墙规则等。

## 📄 许可证

本项目采用 MIT 许可证。详情请参阅 `LICENSE` 文件。```
