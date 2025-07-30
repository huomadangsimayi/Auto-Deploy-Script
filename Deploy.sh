#!/bin/bash

#配置参数
BACKEND_PORT=8080
NGINX_PORT=80
DB_PASSWORD="huomadangsimayi"
MINIO_ACCESS_KEY="huomadangsimayi"
MINIO_SECRET_KEY="huomadangsimayi"

#检查root权限
if [ "$(id -u)" != "0" ];then
    echo "请使用root权限！？" >&2
    exit 1
fi

#安装基础工具
echo "> 安装开发环境与工具..."
yum update -y
yum install -y wget nano unzip unrar tmux

#安装JDK
echo "> 安装JDK 17..."
yum install -y java-17-openjdk-devel
java -version

if ! command -v java &> /dev/null; then
    echo "JDK 安装失败"
    exit 1
fi

#安装数据库
echo "> 安装MySQL..."
wget https://dev.mysql.com/get/mysql80-community-release-el7-6.noarch.rpm
rpm -Uvh mysql80-community-release-el7-6.noarch.rpm
yum install -y mysql-server
systemctl start mysqld
systemctl enable mysqld

#设置MySQL密码
temp_pass=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
mysql --connect-expired-password -u root -p"$temp_pass" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
FLUSH PRIVILEGES;
EOF

#安装Redis
echo "> 安装Redis..."
yum install -y redis
systemctl start redis
systemctl enable redis

#安装MinIO
echo "> 安装MinIO..."
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
mv minio /usr/local/bin/

useradd -s /sbin/nologin minio-user
mkdir /opt/minio /opt/minio/data
chown -R minio-user:minio-user /opt/minio

#基础MinIO配置
cat > /etc/systemd/system/minio.service <<EOF
[Unit]
Description=MinIO
After=network.target

[Service]
User=minio-user
Group=minio-user
ExecStart=/usr/local/bin/minio server /opt/minio/data
Environment="MINIO_ROOT_USER=$MINIO_ACCESS_KEY"
Environment="MINIO_ROOT_PASSWORD=$MINIO_SECRET_KEY"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start minio
systemctl enable minio

#安装配置Nginx
echo "> 安装配置Nginx..."
yum install -y epel-release
yum install -y nginx

#基础Nginx配置
cat > /etc/nginx/conf.d/app.conf <<EOF
server {
    listen $NGINX_PORT;
    server_name _;

    # 前端配置
    location / {
        root /usr/share/nginx/html;
	try_files \$uri /index.html;
    }

    #后端API代理
    location /api {
	proxy_pass http://127.0.0.1:$BACKEND_PORT;
	proxy_set_header Host \$host;
	proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

#创建后端服务
echo "> 配置后端服务..."

mkdir -p /opt/app

cat > /etc/systemd/system/backend.service <<EOF
[Unit]
Description=Backend Service
After=network.target

[Service]
BACKEND_JAR_PATH="/opt/app/backend.jar"
ExecStart=/usr/bin/java -jar $BACKEND_JAR_PATH
User=root
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start backend
systemctl enable backend

#前端项目
mkdir -p /usr/share/nginx/html

echo "<html><body><h1>前端应用已部署!</h1></body></html>" > /usr/share/nginx/html/index.html

systemctl start nginx
systemctl enable nginx

#防火墙配置
echo "> 防火墙配置..."
firewall-cmd --permanent --add-port=$NGINX_PORT/tcp
firewall-cmd --permanent --add-port=$BACKEND_PORT/tcp
firewall-cmd --reload

#日志管理配置
echo "> 日志管理配置"
mkdir /var/log/app-logs
ln -s /var/log/nginx/access.log /var/log/app-logs/frontend-access.log
nohup journalctl -u backend.service -f > /var/log/app-logs/backend.log 2>&1 &

#验证部署
echo "终于部署完了，验证一下吧..."
echo "- Nginx状态：$(systemctl is-active nginx)"
echo "- 后端服务：$(systemctl is-active backend)"
echo "- MySQL状态：$(systemctl is-active mysqld)"
echo "- Redis状态：$(systemctl is-active redis)"
echo "- MinIO状态：$(systemctl is-active minio)"

IP_ADDR=$(hostname -I | awk '{print $1}')
echo "请访问:http://$IP_ADDR:$NGINX_PORT"
echo "后端API:http://$IP_ADDR:$NGINX_PORT/api"
echo "MinIO控制台:http://$IP_ADDR:9000"

#查看日志提示
echo "查看日志提示:"
echo "tail -f /var/log/app-logs/backend.log"
echo "tail -f /var/log/app-logs/frontend-access.log"
