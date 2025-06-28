#!/bin/bash

# XBoard 登录凭据测试脚本
# 用法: ./scripts/test_credentials.sh

BASE_URL="https://wujie03.wujie001.art"

echo "🔐 XBoard 登录凭据测试"
echo "====================="
echo "📍 Base URL: $BASE_URL"
echo ""

# 测试函数
test_login() {
    local email="$1"
    local password="$2"
    
    echo "🧪 测试登录: $email"
    echo "🔑 密码: $(echo $password | sed 's/./*/g')"
    
    response=$(curl -s -X POST "$BASE_URL/api/v1/passport/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$email\",\"password\":\"$password\"}")
    
    echo "📄 响应: $response"
    
    # 检查是否成功
    if echo "$response" | grep -q '"status":"success"'; then
        echo "✅ 登录成功！"
        # 提取token
        token=$(echo "$response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('data', {}).get('token', 'N/A'))" 2>/dev/null)
        if [ "$token" != "N/A" ] && [ "$token" != "" ]; then
            echo "🔑 Token: ${token:0:50}..."
        fi
        return 0
    else
        echo "❌ 登录失败"
        return 1
    fi
    echo ""
}

# 测试用户提供的凭据
echo "测试用户提供的凭据:"
test_login "test@gmail.com" "12345678"
echo ""

# 测试其他可能的凭据
echo "测试其他可能的凭据:"
test_login "admin@gmail.com" "12345678"
echo ""

test_login "demo@gmail.com" "12345678"
echo ""

test_login "test@test.com" "12345678"
echo ""

test_login "test@gmail.com" "123456"
echo ""

test_login "test@gmail.com" "password"
echo ""

echo "💡 如果所有测试都失败，请："
echo "1. 确认网站 $BASE_URL 是否可以正常访问"
echo "2. 检查是否需要先注册账号"
echo "3. 确认邮箱和密码是否正确"
echo "4. 检查网站是否有特殊的登录要求" 