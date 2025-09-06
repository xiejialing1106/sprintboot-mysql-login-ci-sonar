# Spring Boot + MySQL + Login API + Unit Test

這是一個完整的 Spring Boot 專案，實現了用戶註冊和登入功能，包含 MySQL 資料庫整合和完整的單元測試。

## 功能特色

- ✅ 用戶註冊 API (Signup)
- ✅ 用戶登入 API (Login)
- ✅ MySQL 資料庫整合
- ✅ Spring Security 安全配置
- ✅ 密碼加密 (BCrypt)
- ✅ 完整的單元測試覆蓋
- ✅ API 驗證和錯誤處理
- ✅ RESTful API 設計

## 技術棧

- **Java 17**
- **Spring Boot 3.2.5**
- **Spring Security**
- **Spring Data JPA**
- **MySQL 8.0**
- **Maven**
- **JUnit 5**
- **Mockito**
- **H2 Database (測試用)**

## 專案結構

```
src/
├── main/
│   ├── java/com/example/springboot_mysql_login_ci_sonar/
│   │   ├── config/
│   │   │   └── SecurityConfig.java          # Spring Security 配置
│   │   ├── controller/
│   │   │   └── AuthController.java          # 認證 API Controller
│   │   ├── dto/
│   │   │   ├── ApiResponse.java             # API 回應格式
│   │   │   ├── LoginRequest.java            # 登入請求 DTO
│   │   │   ├── SignupRequest.java           # 註冊請求 DTO
│   │   │   └── UserResponse.java            # 用戶回應 DTO
│   │   ├── entity/
│   │   │   └── User.java                    # 用戶實體類別
│   │   ├── repository/
│   │   │   └── UserRepository.java          # 用戶資料存取層
│   │   ├── service/
│   │   │   └── UserService.java             # 用戶業務邏輯層
│   │   └── SpringbootMysqlLoginCiSonarApplication.java
│   └── resources/
│       └── application.properties           # 應用程式配置
└── test/
    ├── java/com/example/springboot_mysql_login_ci_sonar/
    │   ├── controller/
    │   │   └── AuthControllerTest.java      # Controller 單元測試
    │   ├── repository/
    │   │   └── UserRepositoryTest.java      # Repository 整合測試
    │   └── service/
    │       └── UserServiceTest.java         # Service 單元測試
    └── resources/
        └── application-test.properties      # 測試配置
```

## 快速開始

### 方式一：Docker 部署（推薦）

#### 1. 環境需求

- Docker 20.0+
- Docker Compose 2.0+

#### 2. 快速部署

```bash
# 1. 複製環境變數文件
cp env.example .env

# 2. 編輯環境變數（可選）
nano .env

# 3. 執行部署腳本
chmod +x deploy.sh
./deploy.sh
```

#### 3. 使用簡化版本（不包含 Nginx）

```bash
# 使用簡化的 docker-compose 配置
docker-compose -f docker-compose.simple.yml up --build -d
```

### 方式二：本地開發

#### 1. 環境需求

- Java 17+
- Maven 3.6+
- MySQL 8.0+

#### 2. 資料庫設定

建立 MySQL 資料庫：

```sql
CREATE DATABASE user_login_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 3. 配置資料庫連接

修改 `src/main/resources/application.properties`：

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/user_login_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=your_username
spring.datasource.password=your_password
```

#### 4. 執行專案

```bash
# 編譯專案
mvn clean compile

# 執行測試
mvn test

# 啟動應用程式
mvn spring-boot:run
```

應用程式將在 `http://localhost:8080` 啟動。

## API 文檔

### 1. 用戶註冊

**POST** `/api/auth/signup`

請求體：
```json
{
  "username": "張三",
  "loginId": "zhangsan",
  "password": "password123"
}
```

回應：
```json
{
  "success": true,
  "message": "註冊成功",
  "data": {
    "id": 1,
    "username": "張三",
    "loginId": "zhangsan",
    "createdAt": "2024-01-01T10:00:00",
    "updatedAt": "2024-01-01T10:00:00",
    "enabled": true
  },
  "timestamp": 1704067200000
}
```

### 2. 用戶登入

**POST** `/api/auth/login`

請求體：
```json
{
  "loginId": "zhangsan",
  "password": "password123"
}
```

回應：
```json
{
  "success": true,
  "message": "登入成功",
  "data": {
    "id": 1,
    "username": "張三",
    "loginId": "zhangsan",
    "createdAt": "2024-01-01T10:00:00",
    "updatedAt": "2024-01-01T10:00:00",
    "enabled": true
  },
  "timestamp": 1704067200000
}
```

### 3. 健康檢查

**GET** `/api/auth/health`

回應：
```json
{
  "success": true,
  "message": "認證服務正常運行",
  "data": null,
  "timestamp": 1704067200000
}
```

## 測試

### 方式一：Docker 環境測試（推薦）

#### 快速執行測試

```bash
# 執行單元測試
docker-compose -f docker-compose.test-simple.yml up --build

# 使用互動式測試腳本
./test.sh
```

#### 測試選項

```bash
# 執行單元測試
./test.sh unit

# 執行整合測試
./test.sh integration

# 執行所有測試
./test.sh all

# 查看測試日誌
./test.sh logs

# 生成測試報告
./test.sh report
```

### 方式二：本地測試

#### 執行所有測試

```bash
mvn test
```

#### 執行特定測試類別

```bash
# Controller 測試
mvn test -Dtest=AuthControllerTest

# Service 測試
mvn test -Dtest=UserServiceTest

# Repository 測試
mvn test -Dtest=UserRepositoryTest
```

#### 測試覆蓋率報告

```bash
mvn clean test jacoco:report
```

報告將生成在 `target/site/jacoco/index.html`

### 測試配置

- **單元測試**: 使用 H2 記憶體資料庫，快速執行
- **整合測試**: 使用 MySQL 資料庫，真實環境測試
- **測試報告**: 自動生成 Surefire 和 Jacoco 報告

詳細測試說明請參考 [TESTING.md](TESTING.md)

## 資料庫表結構

### users 表

| 欄位名 | 類型 | 約束 | 說明 |
|--------|------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 用戶 ID |
| username | VARCHAR(50) | NOT NULL | 用戶名稱 |
| login_id | VARCHAR(30) | NOT NULL, UNIQUE | 登入 ID |
| password | VARCHAR(255) | NOT NULL | 加密密碼 |
| created_at | DATETIME | NOT NULL | 建立時間 |
| updated_at | DATETIME | | 更新時間 |
| enabled | BOOLEAN | NOT NULL, DEFAULT TRUE | 是否啟用 |

## 安全特性

- 密碼使用 BCrypt 加密
- Spring Security 整合
- 輸入驗證和錯誤處理
- SQL 注入防護
- CORS 支援

## 開發工具

- **Lombok**: 減少樣板代碼
- **Spring Boot DevTools**: 熱重載
- **H2 Database**: 測試用記憶體資料庫
- **Jacoco**: 測試覆蓋率分析

## 常見問題

### Q: 如何修改資料庫連接設定？

A: 修改 `src/main/resources/application.properties` 中的資料庫相關配置。

### Q: 如何添加新的 API 端點？

A: 在 `AuthController` 中添加新的方法，並使用 `@PostMapping` 或 `@GetMapping` 註解。

### Q: 如何執行 SonarQube 掃描？

A: 執行 `mvn sonar:sonar` 命令（需要先設定 SonarQube 伺服器）。

## Docker 部署

### 本地 Docker 部署

```bash
# 1. 複製環境變數文件
cp env.example .env

# 2. 啟動所有服務
docker-compose up --build -d

# 3. 查看服務狀態
docker-compose ps

# 4. 查看日誌
docker-compose logs -f
```

### GCP Compute Engine 部署

詳細的 GCP 部署指南請參考 [DEPLOYMENT.md](DEPLOYMENT.md)

#### 快速 GCP 部署步驟：

1. **建立 GCP VM 實例**
```bash
gcloud compute instances create springboot-app \
    --zone=asia-east1-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --tags=http-server,https-server
```

2. **設定防火牆規則**
```bash
gcloud compute firewall-rules create allow-http \
    --allow tcp:80,tcp:8080 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server
```

3. **部署應用程式**
```bash
# SSH 連接到 VM
gcloud compute ssh springboot-app --zone=asia-east1-a

# 在 VM 上執行
git clone <your-repo-url>
cd springboot-mysql-login-ci-sonar
./deploy.sh
```

### Docker 服務說明

| 服務 | 端口 | 說明 |
|------|------|------|
| api | 8080 | Spring Boot API 服務 |
| mysql | 3306 | MySQL 資料庫 |
| nginx | 80, 443 | 反向代理（可選） |

### 環境變數

| 變數名 | 預設值 | 說明 |
|--------|--------|------|
| MYSQL_ROOT_PASSWORD | rootpassword | MySQL root 密碼 |
| MYSQL_DATABASE | user_login_db | 資料庫名稱 |
| MYSQL_USER | appuser | 應用程式資料庫用戶 |
| MYSQL_PASSWORD | apppassword | 應用程式資料庫密碼 |
| SPRING_PROFILES_ACTIVE | docker | Spring 配置檔案 |
| SERVER_PORT | 8080 | API 服務端口 |

## 授權

MIT License
