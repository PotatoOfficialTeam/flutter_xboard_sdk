#!/bin/bash

# XBoard SDK 集成测试运行脚本
# 用法: ./scripts/run_integration_test.sh

echo "🚀 XBoard SDK 集成测试"
echo "======================"

# 检查环境变量是否设置
if [ -z "$XBOARD_BASE_URL" ]; then
    echo "❌ 错误: 未设置环境变量 XBOARD_BASE_URL"
    echo ""
    echo "请先设置必要的环境变量："
    echo "export XBOARD_BASE_URL=\"https://your-xboard-domain.com\""
    echo "export XBOARD_TEST_EMAIL=\"test@example.com\""
    echo "export XBOARD_TEST_PASSWORD=\"your_password\""
    echo "export XBOARD_TEST_INVITE_CODE=\"your_invite_code\"  # 可选"
    echo ""
    exit 1
fi

if [ -z "$XBOARD_TEST_EMAIL" ]; then
    echo "❌ 错误: 未设置环境变量 XBOARD_TEST_EMAIL"
    exit 1
fi

if [ -z "$XBOARD_TEST_PASSWORD" ]; then
    echo "❌ 错误: 未设置环境变量 XBOARD_TEST_PASSWORD"
    exit 1
fi

echo "✅ 环境变量检查通过"
echo "📍 Base URL: $XBOARD_BASE_URL"
echo "📧 Test Email: $XBOARD_TEST_EMAIL"
echo "🔑 Password: $(echo $XBOARD_TEST_PASSWORD | sed 's/./*/g')"
if [ -n "$XBOARD_TEST_INVITE_CODE" ]; then
    echo "🎫 Invite Code: $XBOARD_TEST_INVITE_CODE"
else
    echo "🎫 Invite Code: 未设置"
fi
echo ""

echo "🧪 开始运行集成测试..."
echo ""

# 运行集成测试
flutter test test/integration_test.dart -r expanded

# 检查测试结果
if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 集成测试完成！"
else
    echo ""
    echo "💥 集成测试失败！"
    echo ""
    echo "故障排除建议："
    echo "1. 检查网络连接是否正常"
    echo "2. 确认XBoard服务器地址是否正确"
    echo "3. 验证测试账号和密码是否有效"
    echo "4. 查看上面的错误日志获取详细信息"
    exit 1
fi 