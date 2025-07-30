# FreshDeploy

本项目提供一键式自动部署shell脚本，适用于在 **CentOS 7 (笔者使用的是Rocky9.6)** 上搭建完整的 Web 应用后端基础环境，包括数据库、缓存、对象存储、Nginx 反向代理与 Java 运行环境等组件。

---

## 功能预览

该脚本将自动安装和配置以下服务：

- **JDK 17**
- **MySQL 8**（可设置 root 密码）
- **Redis**
- **MinIO**（对象存储）
- **Nginx**（含 API 代理配置）
- **Spring Boot 后端服务**
- **前端静态页面**
- **开放必要防火墙端口**
- **日志管理配置**

---

## 使用说明

### 1. 克隆项目

```bash
git clone https://github.com/huomadangsimayi/Auto-Deploy-Script.git
cd Auto-Deploy-Script
````

### 2. 配置参数

编辑 `deploy.sh` 文件顶部的变量，填写你自己的密码和端口配置：

```bash
# 配置参数
BACKEND_PORT=8080                          # 后端服务端口
NGINX_PORT=80                              # Nginx 对外端口
DB_PASSWORD="your_strong_password"         # MySQL root 密码
MINIO_ACCESS_KEY="your_minio_access_key"   # MinIO Access Key
MINIO_SECRET_KEY="your_minio_secret_key"   # MinIO Secret Key
```

**注意：请务必替换默认密码和密钥，防止安全风险！**

---

### 3. 准备文件

脚本会自动创建目录，但你需要**手动放置应用文件**：

#### 后端应用

将 Spring Boot 打包好的 `jar` 文件上传并命名为 `backend.jar`：

```bash
mv /path/to/your-app.jar /opt/app/backend.jar
```

#### 前端项目（可选）

如有前端页面，请将 HTML/CSS/JS 文件上传到：

```bash
/usr/share/nginx/html
```

> 如果不上传，脚本默认部署一个简单的占位页。

---

### 4. 执行部署脚本

```bash
chmod +x deploy.sh
sudo ./deploy.sh
```

> 建议使用 `root` 用户或加 `sudo` 执行，以确保所有安装与服务注册顺利完成。

---

## 部署验证

部署完成后，脚本会输出各项服务状态。

你也可以手动检查服务运行情况：

```bash
systemctl status nginx
systemctl status backend
systemctl status mysqld
systemctl status redis
systemctl status minio
```

---

## 访问地址

以下为默认访问入口：

- **前端页面**：`http://<你的服务器IP>`
- **后端 API**：`http://<你的服务器IP>/api`
- **MinIO 控制台**：`http://<你的服务器IP>:9000`

> 登录 MinIO 控制台时，使用你在脚本中配置的 Access Key 和 Secret Key。

---

## 日志管理

脚本会将关键日志统一至 `/var/log/app-logs/` 目录下：

后端日志：

  ```bash
  tail -f /var/log/app-logs/backend.log
  ```

Nginx 前端访问日志：

  ```bash
  tail -f /var/log/app-logs/frontend-access.log
  ```

---

## 注意事项

- 本脚本适用于 **CentOS 7与Rocky 9**，在其他系统版本未测试
- **强烈建议**在生产环境中配置更复杂的密码，并禁止 root 运行后端服务
- 为增强安全性的建议：
  
  - 创建专用服务用户运行后端服务
  - 配置防火墙限制访问范围
  - 配置 HTTPS 和域名等额外安全措施

---
