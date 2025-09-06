#!/bin/bash

# Docker 環境測試執行腳本

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Docker 環境測試執行腳本${NC}"
echo "=================================="

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

# 建立測試結果目錄
mkdir -p test-results

# 函數：執行單元測試
run_unit_tests() {
    echo -e "${YELLOW}🔬 執行單元測試...${NC}"
    
    # 停止現有容器
    docker-compose -f docker-compose.test.yml down
    
    # 啟動測試環境
    docker-compose -f docker-compose.test.yml up --build test-runner
    
    # 檢查測試結果
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 單元測試通過${NC}"
    else
        echo -e "${RED}❌ 單元測試失敗${NC}"
        return 1
    fi
}

# 函數：執行整合測試
run_integration_tests() {
    echo -e "${YELLOW}🔗 執行整合測試...${NC}"
    
    # 停止現有容器
    docker-compose -f docker-compose.test.yml down
    
    # 啟動整合測試環境
    docker-compose -f docker-compose.test.yml up --build integration-test
    
    # 檢查測試結果
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 整合測試通過${NC}"
    else
        echo -e "${RED}❌ 整合測試失敗${NC}"
        return 1
    fi
}

# 函數：執行所有測試
run_all_tests() {
    echo -e "${YELLOW}🚀 執行所有測試...${NC}"
    
    # 停止現有容器
    docker-compose -f docker-compose.test.yml down
    
    # 啟動所有測試服務
    docker-compose -f docker-compose.test.yml up --build
    
    # 檢查測試結果
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 所有測試通過${NC}"
    else
        echo -e "${RED}❌ 部分測試失敗${NC}"
        return 1
    fi
}

# 函數：查看測試日誌
view_test_logs() {
    echo -e "${YELLOW}📋 查看測試日誌...${NC}"
    docker-compose -f docker-compose.test.yml logs
}

# 函數：清理測試環境
cleanup() {
    echo -e "${YELLOW}🧹 清理測試環境...${NC}"
    docker-compose -f docker-compose.test.yml down -v
    docker system prune -f
    echo -e "${GREEN}✅ 清理完成${NC}"
}

# 函數：生成測試報告
generate_report() {
    echo -e "${YELLOW}📊 生成測試報告...${NC}"
    
    # 檢查是否有測試結果
    if [ -d "target/surefire-reports" ]; then
        echo -e "${GREEN}📈 測試報告已生成在 target/surefire-reports/ 目錄${NC}"
        
        # 顯示測試摘要
        if [ -f "target/surefire-reports/TEST-*.xml" ]; then
            echo -e "${BLUE}測試摘要:${NC}"
            find target/surefire-reports -name "TEST-*.xml" -exec grep -H "tests\|failures\|errors" {} \;
        fi
    else
        echo -e "${YELLOW}⚠️  未找到測試報告${NC}"
    fi
}

# 主選單
show_menu() {
    echo -e "${BLUE}請選擇要執行的操作:${NC}"
    echo "1) 執行單元測試"
    echo "2) 執行整合測試"
    echo "3) 執行所有測試"
    echo "4) 查看測試日誌"
    echo "5) 生成測試報告"
    echo "6) 清理測試環境"
    echo "7) 退出"
    echo ""
    read -p "請輸入選項 (1-7): " choice
}

# 主程式
main() {
    while true; do
        show_menu
        
        case $choice in
            1)
                run_unit_tests
                ;;
            2)
                run_integration_tests
                ;;
            3)
                run_all_tests
                ;;
            4)
                view_test_logs
                ;;
            5)
                generate_report
                ;;
            6)
                cleanup
                ;;
            7)
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
    "unit")
        run_unit_tests
        ;;
    "integration")
        run_integration_tests
        ;;
    "all")
        run_all_tests
        ;;
    "logs")
        view_test_logs
        ;;
    "report")
        generate_report
        ;;
    "cleanup")
        cleanup
        ;;
    *)
        main
        ;;
esac


