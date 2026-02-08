#!/bin/bash

BASE_URL="https://localhost:8080/api"
USER_ID="user123"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}1. Testing Home API (首頁)...${NC}"
response=$(curl -s "$BASE_URL/home/$USER_ID")
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Success!${NC}"
    echo "$response"
else
    echo -e "${RED}Failed to connect${NC}"
fi

echo -e "\n${CYAN}2. Testing Progress API (工程進度)...${NC}"
response=$(curl -s "$BASE_URL/progress/$USER_ID")
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Success!${NC}"
    echo "$response"
fi

echo -e "\n${CYAN}3. Testing Payment API (繳款查詢)...${NC}"
response=$(curl -s "$BASE_URL/payment/$USER_ID")
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Success!${NC}"
    echo "$response"
fi

echo -e "\n${CYAN}4. Testing Profile API (會員中心)...${NC}"
response=$(curl -s "$BASE_URL/profile/$USER_ID")
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Success!${NC}"
    echo "$response"
fi

echo -e "\n${CYAN}5. Testing Repair API - History (報修紀錄)...${NC}"
response=$(curl -s "$BASE_URL/repair/$USER_ID")
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Success!${NC}"
    echo "$response"
fi

echo -e "\n${CYAN}6. Testing Repair API - Create (新增報修)...${NC}"
response=$(curl -s -X POST "$BASE_URL/repair/$USER_ID" \
    -H "Content-Type: application/json" \
    -d '{"issueDescription": "Test Issue from Bash Script"}')
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Success!${NC}"
    echo "$response"
fi

echo ""
echo -e "${YELLOW}Note: Ensure Spring Boot app is running on port 8080.${NC}"
