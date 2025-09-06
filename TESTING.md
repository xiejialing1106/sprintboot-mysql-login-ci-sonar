# Docker 環境測試指南

本指南說明如何在 Docker 環境中執行 Spring Boot 應用程式的單元測試和整合測試。

## 測試環境配置

### 測試架構

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Test Runner   │    │   H2 Database   │    │  MySQL Test DB  │
│   (Maven)       │    │   (Memory)      │    │   (Integration) │
│                 │    │                 │    │                 │
│ • Unit Tests    │    │ • Fast Tests    │    │ • Real DB Tests │
│ • Mock Tests    │    │ • No Persist    │    │ • Integration   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 快速開始

### 1. 執行所有測試

```bash
# 使用互動式腳本
./test.sh

# 或直接執行所有測試
./test.sh all
```

### 2. 執行單元測試

```bash
# 使用簡化配置（推薦）
docker-compose -f docker-compose.test-simple.yml up --build

# 或使用完整配置
./test.sh unit
```

### 3. 執行整合測試

```bash
# 使用完整配置（包含 MySQL）
./test.sh integration
```

## 測試配置說明

### 單元測試配置

- **資料庫**: H2 記憶體資料庫
- **配置檔案**: `application-test.properties`
- **特點**: 快速、隔離、無持久化

### 整合測試配置

- **資料庫**: MySQL 8.0
- **配置檔案**: `application-docker.properties`
- **特點**: 真實環境、持久化、完整功能

## 測試命令

### 基本命令

```bash
# 執行所有測試
docker-compose -f docker-compose.test-simple.yml up --build

# 執行特定測試類別
docker-compose -f docker-compose.test-simple.yml run test-runner mvn test -Dtest=AuthControllerTest

# 執行特定測試方法
docker-compose -f docker-compose.test-simple.yml run test-runner mvn test -Dtest=AuthControllerTest#testSignup_Success

# 生成測試報告
docker-compose -f docker-compose.test-simple.yml run test-runner mvn test jacoco:report
```

### 進階命令

```bash
# 執行測試並生成覆蓋率報告
docker-compose -f docker-compose.test-simple.yml run test-runner mvn clean test jacoco:report

# 執行測試並跳過某些測試
docker-compose -f docker-compose.test-simple.yml run test-runner mvn test -Dtest="!*RepositoryTest"

# 執行測試並顯示詳細輸出
docker-compose -f docker-compose.test-simple.yml run test-runner mvn test -X
```

## 測試腳本使用

### 互動式模式

```bash
./test.sh
```

會顯示選單：
```
🧪 Docker 環境測試執行腳本
==================================
請選擇要執行的操作:
1) 執行單元測試
2) 執行整合測試
3) 執行所有測試
4) 查看測試日誌
5) 生成測試報告
6) 清理測試環境
7) 退出
```

### 直接命令模式

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

# 清理測試環境
./test.sh cleanup
```

## 測試結果

### 測試報告位置

- **Surefire 報告**: `target/surefire-reports/`
- **Jacoco 覆蓋率**: `target/site/jacoco/`
- **測試日誌**: `test-results/`

### 查看測試結果

```bash
# 查看測試摘要
cat target/surefire-reports/TEST-*.xml | grep -E "(tests|failures|errors)"

# 查看覆蓋率報告
open target/site/jacoco/index.html  # macOS
xdg-open target/site/jacoco/index.html  # Linux
```

## 測試環境變數

### 單元測試環境變數

```bash
SPRING_PROFILES_ACTIVE=test
SPRING_DATASOURCE_URL=jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.h2.Driver
SPRING_DATASOURCE_USERNAME=sa
SPRING_DATASOURCE_PASSWORD=
SPRING_JPA_HIBERNATE_DDL_AUTO=create-drop
SPRING_JPA_SHOW_SQL=false
```

### 整合測試環境變數

```bash
SPRING_PROFILES_ACTIVE=docker
SPRING_DATASOURCE_URL=jdbc:mysql://mysql-test:3306/test_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
SPRING_DATASOURCE_USERNAME=testuser
SPRING_DATASOURCE_PASSWORD=testpassword
SPRING_JPA_HIBERNATE_DDL_AUTO=create-drop
SPRING_JPA_SHOW_SQL=true
```

## 故障排除

### 常見問題

1. **測試失敗**
   ```bash
   # 查看詳細日誌
   docker-compose -f docker-compose.test-simple.yml logs test-runner
   ```

2. **資料庫連接問題**
   ```bash
   # 檢查資料庫狀態
   docker-compose -f docker-compose.test.yml ps
   ```

3. **記憶體不足**
   ```bash
   # 增加 Docker 記憶體限制
   docker-compose -f docker-compose.test-simple.yml run --memory=2g test-runner mvn test
   ```

### 清理環境

```bash
# 清理所有測試容器和卷
docker-compose -f docker-compose.test.yml down -v
docker-compose -f docker-compose.test-simple.yml down -v

# 清理 Docker 系統
docker system prune -f
```

## 持續整合

### GitHub Actions 範例

```yaml
name: Docker Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Run Unit Tests
      run: |
        docker-compose -f docker-compose.test-simple.yml up --build --abort-on-container-exit
        docker-compose -f docker-compose.test-simple.yml down
    
    - name: Upload Test Results
      uses: actions/upload-artifact@v2
      if: always()
      with:
        name: test-results
        path: target/surefire-reports/
```

## 最佳實踐

1. **測試隔離**: 每個測試都應該獨立運行
2. **快速反饋**: 單元測試應該快速執行
3. **真實環境**: 整合測試使用真實資料庫
4. **覆蓋率**: 保持高測試覆蓋率
5. **清理**: 測試後清理環境

## 性能優化

1. **並行測試**: 使用 Maven Surefire 並行執行
2. **記憶體優化**: 調整 JVM 參數
3. **資料庫優化**: 使用 H2 進行快速測試
4. **快取依賴**: 利用 Docker 層快取


