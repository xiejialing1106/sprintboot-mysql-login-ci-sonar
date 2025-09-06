#!/bin/bash

# Maven 啟動腳本

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Spring Boot Maven 啟動腳本${NC}"
echo "=================================="

# 檢查 Java 是否安裝
if ! command -v java &> /dev/null; then
    echo -e "${RED}❌ Java 未安裝，請先安裝 Java 17+${NC}"
    exit 1
fi

# 檢查 Maven 是否安裝
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}❌ Maven 未安裝，請先安裝 Maven${NC}"
    exit 1
fi

# 顯示 Java 和 Maven 版本
echo -e "${GREEN}📋 環境資訊:${NC}"
echo "Java 版本: $(java -version 2>&1 | head -n 1)"
echo "Maven 版本: $(mvn -version | head -n 1)"
echo ""

# 函數：清理並編譯
clean_compile() {
    echo -e "${YELLOW}🧹 清理並編譯專案...${NC}"
    mvn clean compile
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 編譯成功${NC}"
    else
        echo -e "${RED}❌ 編譯失敗${NC}"
        return 1
    fi
}

# 函數：執行測試
run_tests() {
    echo -e "${YELLOW}🧪 執行測試...${NC}"
    mvn test
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 測試通過${NC}"
    else
        echo -e "${RED}❌ 測試失敗${NC}"
        return 1
    fi
}

# 函數：啟動應用程式（測試模式）
start_test() {
    echo -e "${YELLOW}🚀 啟動應用程式（測試模式 - H2 資料庫）...${NC}"
    echo -e "${BLUE}📝 使用 H2 記憶體資料庫，無需外部資料庫${NC}"
    mvn spring-boot:run -Dspring-boot.run.profiles=test
}

# 函數：啟動應用程式（Docker 模式）
start_docker() {
    echo -e "${YELLOW}🚀 啟動應用程式（Docker 模式 - MySQL）...${NC}"
    echo -e "${BLUE}📝 需要 MySQL 資料庫運行在 localhost:3306${NC}"
    mvn spring-boot:run -Dspring-boot.run.profiles=docker
}

# 函數：啟動應用程式（預設模式）
start_default() {
    echo -e "${YELLOW}🚀 啟動應用程式（預設模式）...${NC}"
    mvn spring-boot:run
}

# 函數：生成測試報告
generate_report() {
    echo -e "${YELLOW}📊 生成測試報告...${NC}"
    mvn test jacoco:report
    echo -e "${GREEN}📈 測試報告已生成在 target/site/jacoco/index.html${NC}"
}

# 函數：清理專案
clean_project() {
    echo -e "${YELLOW}🧹 清理專案...${NC}"
    mvn clean
    echo -e "${GREEN}✅ 清理完成${NC}"
}

# 主選單
show_menu() {
    echo -e "${BLUE}請選擇要執行的操作:${NC}"
    echo "1) 清理並編譯"
    echo "2) 執行測試"
    echo "3) 啟動應用程式（測試模式 - H2）"
    echo "4) 啟動應用程式（Docker 模式 - MySQL）"
    echo "5) 啟動應用程式（預設模式）"
    echo "6) 生成測試報告"
    echo "7) 清理專案"
    echo "8) 退出"
    echo ""
    read -p "請輸入選項 (1-8): " choice
}

# 主程式
main() {
    while true; do
        show_menu
        
        case $choice in
            1)
                clean_compile
                ;;
            2)
                run_tests
                ;;
            3)
                start_test
                ;;
            4)
                start_docker
                ;;
            5)
                start_default
                ;;
            6)
                generate_report
                ;;
            7)
                clean_project
                ;;
            8)
                echo -e "${GREEN}👋 再見！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ 無效選項，請重新選擇${NC}"
                ;;
        esac
        
        echo ""
        read -p "按 Enter 鍵繼續..."
        echo ""
    done
}

# 如果提供了參數，直接執行對應功能
case "${1:-}" in
    "compile")
        clean_compile
        ;;
    "test")
        run_tests
        ;;
    "start-test")
        start_test
        ;;
    "start-docker")
        start_docker
        ;;
    "start")
        start_default
        ;;
    "report")
        generate_report
        ;;
    "clean")
        clean_project
        ;;
    *)
        main
        ;;
esac


