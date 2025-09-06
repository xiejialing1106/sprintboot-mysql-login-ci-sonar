#!/bin/bash

# Spring Boot + MySQL Docker 部署腳本
# 適用於 GCP Compute Engine

set -e

echo "🚀 開始部署 Spring Boot + MySQL 應用程式..."

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 檢查 Docker 是否安裝
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker 未安裝，請先安裝 Docker${NC}"
    exit 1
fi

# 檢查 Docker Compose 是否安裝
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose 未安裝，請先安裝 Docker Compose${NC}"
    exit 1
fi

# 檢查環境變數文件
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env 文件不存在，從 env.example 複製...${NC}"
    cp env.example .env
    echo -e "${YELLOW}請編輯 .env 文件設定您的環境變數${NC}"
fi

# 停止現有容器
echo -e "${YELLOW}🛑 停止現有容器...${NC}"
docker-compose down

# 清理舊的映像
echo -e "${YELLOW}🧹 清理舊的 Docker 映像...${NC}"
docker system prune -f

# 構建並啟動服務
echo -e "${YELLOW}🔨 構建並啟動服務...${NC}"
docker-compose up --build -d

# 等待服務啟動
echo -e "${YELLOW}⏳ 等待服務啟動...${NC}"
sleep 30

# 檢查服務狀態
echo -e "${YELLOW}🔍 檢查服務狀態...${NC}"
docker-compose ps

# 健康檢查
echo -e "${YELLOW}🏥 執行健康檢查...${NC}"
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -f http://localhost:8080/api/auth/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ API 服務健康檢查通過${NC}"
        break
    else
        echo -e "${YELLOW}⏳ 等待 API 服務啟動... (嘗試 $attempt/$max_attempts)${NC}"
        sleep 10
        ((attempt++))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo -e "${RED}❌ API 服務健康檢查失敗${NC}"
    echo -e "${YELLOW}查看日誌: docker-compose logs api${NC}"
    exit 1
fi

# 顯示部署資訊
echo -e "${GREEN}🎉 部署完成！${NC}"
echo -e "${GREEN}📋 服務資訊:${NC}"
echo -e "  • API 服務: http://localhost:8080"
echo -e "  • 健康檢查: http://localhost:8080/api/auth/health"
echo -e "  • MySQL 資料庫: localhost:3306"
echo -e "  • Nginx 代理: http://localhost:80"

echo -e "${GREEN}📝 常用命令:${NC}"
echo -e "  • 查看日誌: docker-compose logs -f"
echo -e "  • 停止服務: docker-compose down"
echo -e "  • 重啟服務: docker-compose restart"
echo -e "  • 查看狀態: docker-compose ps"

echo -e "${GREEN}🔧 測試 API:${NC}"
echo -e "  • 註冊用戶: curl -X POST http://localhost:8080/api/auth/signup \\"
echo -e "    -H 'Content-Type: application/json' \\"
echo -e "    -d '{\"username\":\"測試用戶\",\"loginId\":\"testuser\",\"password\":\"password123\"}'"
echo -e "  • 登入: curl -X POST http://localhost:8080/api/auth/login \\"
echo -e "    -H 'Content-Type: application/json' \\"
echo -e "    -d '{\"loginId\":\"testuser\",\"password\":\"password123\"}'"


