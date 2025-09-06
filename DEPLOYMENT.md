# GCP Compute Engine 部署指南

本指南將幫助您在 Google Cloud Platform (GCP) 的 Compute Engine 上部署 Spring Boot + MySQL 應用程式。

## 前置需求

- Google Cloud Platform 帳戶
- 已啟用 Compute Engine API
- 本地安裝 gcloud CLI 工具

## 步驟 1: 建立 GCP 專案和 VM 實例

### 1.1 建立 GCP 專案

```bash
# 建立新專案
gcloud projects create your-project-id --name="Spring Boot MySQL App"

# 設定專案
gcloud config set project your-project-id

# 啟用必要的 API
gcloud services enable compute.googleapis.com
```

### 1.2 建立 VM 實例

```bash
# 建立 VM 實例（Ubuntu 20.04 LTS）
gcloud compute instances create springboot-app \
    --zone=asia-east1-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --boot-disk-type=pd-standard \
    --tags=http-server,https-server \
    --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y docker.io docker-compose git
systemctl start docker
systemctl enable docker
usermod -aG docker $USER'
```

### 1.3 設定防火牆規則

```bash
# 允許 HTTP 流量
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server

# 允許 HTTPS 流量
gcloud compute firewall-rules create allow-https \
    --allow tcp:443 \
    --source-ranges 0.0.0.0/0 \
    --target-tags https-server

# 允許自定義端口（用於 API）
gcloud compute firewall-rules create allow-api \
    --allow tcp:8080 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server
```

## 步驟 2: 連接到 VM 並部署應用程式

### 2.1 連接到 VM

```bash
# 獲取 VM 外部 IP
gcloud compute instances describe springboot-app \
    --zone=asia-east1-a \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

# SSH 連接到 VM
gcloud compute ssh springboot-app --zone=asia-east1-a
```

### 2.2 在 VM 上部署應用程式

```bash
# 在 VM 上執行以下命令

# 1. 克隆專案（或上傳代碼）
git clone https://github.com/your-username/springboot-mysql-login-ci-sonar.git
cd springboot-mysql-login-ci-sonar

# 2. 設定環境變數
cp env.example .env
nano .env  # 編輯環境變數

# 3. 執行部署腳本
chmod +x deploy.sh
./deploy.sh
```

## 步驟 3: 環境變數配置

編輯 `.env` 文件：

```bash
# MySQL 資料庫配置
MYSQL_ROOT_PASSWORD=your_secure_root_password
MYSQL_DATABASE=user_login_db
MYSQL_USER=appuser
MYSQL_PASSWORD=your_secure_app_password

# Spring Boot 配置
SPRING_PROFILES_ACTIVE=docker
SPRING_JPA_HIBERNATE_DDL_AUTO=update
SPRING_JPA_SHOW_SQL=false
SERVER_PORT=8080

# 日誌配置
LOG_LEVEL=INFO
SECURITY_LOG_LEVEL=WARN
```

## 步驟 4: 驗證部署

### 4.1 檢查服務狀態

```bash
# 檢查容器狀態
docker-compose ps

# 查看日誌
docker-compose logs -f
```

### 4.2 測試 API

```bash
# 健康檢查
curl http://localhost:8080/api/auth/health

# 註冊用戶
curl -X POST http://localhost:8080/api/auth/signup \
  -H 'Content-Type: application/json' \
  -d '{
    "username": "測試用戶",
    "loginId": "testuser",
    "password": "password123"
  }'

# 登入
curl -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{
    "loginId": "testuser",
    "password": "password123"
  }'
```

## 步驟 5: 設定域名和 SSL（可選）

### 5.1 設定域名

如果您有自己的域名，可以：

1. 在 GCP 設定 DNS 記錄指向您的 VM 外部 IP
2. 使用 Let's Encrypt 獲取 SSL 證書

```bash
# 安裝 Certbot
sudo apt-get install certbot python3-certbot-nginx

# 獲取 SSL 證書
sudo certbot --nginx -d your-domain.com
```

### 5.2 更新 Nginx 配置

編輯 `docker/nginx/nginx.conf` 以使用您的域名和 SSL 證書。

## 監控和維護

### 查看日誌

```bash
# 查看所有服務日誌
docker-compose logs -f

# 查看特定服務日誌
docker-compose logs -f api
docker-compose logs -f mysql
```

### 備份資料庫

```bash
# 建立備份腳本
cat > backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose exec mysql mysqldump -u root -p$MYSQL_ROOT_PASSWORD user_login_db > backup_$DATE.sql
EOF

chmod +x backup.sh
```

### 更新應用程式

```bash
# 拉取最新代碼
git pull origin main

# 重新部署
./deploy.sh
```

## 故障排除

### 常見問題

1. **容器無法啟動**
   ```bash
   docker-compose logs api
   docker-compose logs mysql
   ```

2. **資料庫連接失敗**
   - 檢查 MySQL 容器是否正常運行
   - 驗證環境變數設定
   - 檢查網路連接

3. **API 無法訪問**
   - 檢查防火牆規則
   - 驗證端口是否正確暴露
   - 檢查 Nginx 配置

### 性能優化

1. **調整 VM 規格**
   ```bash
   # 升級 VM 實例
   gcloud compute instances set-machine-type springboot-app \
       --zone=asia-east1-a \
       --machine-type=e2-standard-2
   ```

2. **優化資料庫**
   - 調整 MySQL 配置
   - 使用 SSD 持久化磁碟
   - 設定適當的連接池大小

## 成本優化

1. **使用預付費實例**
2. **設定自動關機/開機**
3. **監控資源使用情況**
4. **使用較小的機器類型（如果性能足夠）**

## 安全建議

1. **定期更新系統和依賴**
2. **使用強密碼**
3. **限制 SSH 訪問**
4. **啟用防火牆**
5. **定期備份資料**
6. **監控日誌**

## 支援

如果遇到問題，請檢查：

1. GCP 控制台中的 VM 實例狀態
2. Docker 容器日誌
3. 應用程式日誌
4. 網路連接和防火牆設定


