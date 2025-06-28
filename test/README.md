# 测试指南

## 测试类型

本项目包含两种类型的测试：

### 1. 单元测试 (`flutter_xboard_sdk_test.dart`)

测试SDK的基本功能和数据模型，不需要网络连接。

**运行命令：**
```bash
flutter test test/flutter_xboard_sdk_test.dart
```

### 2. 集成测试 (`integration_test.dart`)

测试与真实XBoard API的交互，需要网络连接和有效的测试账号。

## 集成测试配置

### 环境变量设置

在运行集成测试前，需要设置以下环境变量：

**必需的环境变量：**
```bash
export XBOARD_BASE_URL="https://your-xboard-domain.com"
export XBOARD_TEST_EMAIL="test@example.com"
export XBOARD_TEST_PASSWORD="your_password"
```

**可选的环境变量：**
```bash
export XBOARD_TEST_INVITE_CODE="your_invite_code"
```

### macOS/Linux 设置示例

```bash
# 在终端中设置环境变量
export XBOARD_BASE_URL="https://demo.xboard.com"
export XBOARD_TEST_EMAIL="test@example.com"
export XBOARD_TEST_PASSWORD="test123456"
export XBOARD_TEST_INVITE_CODE="ABC123"

# 运行集成测试
flutter test test/integration_test.dart
```

### Windows 设置示例

```cmd
# 在命令提示符中设置环境变量
set XBOARD_BASE_URL=https://demo.xboard.com
set XBOARD_TEST_EMAIL=test@example.com
set XBOARD_TEST_PASSWORD=test123456
set XBOARD_TEST_INVITE_CODE=ABC123

# 运行集成测试
flutter test test/integration_test.dart
```

### VSCode 配置

创建 `.vscode/launch.json` 文件：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter Integration Test",
            "type": "dart",
            "request": "launch",
            "program": "test/integration_test.dart",
            "env": {
                "XBOARD_BASE_URL": "https://your-xboard-domain.com",
                "XBOARD_TEST_EMAIL": "test@example.com",
                "XBOARD_TEST_PASSWORD": "your_password",
                "XBOARD_TEST_INVITE_CODE": "your_invite_code"
            }
        }
    ]
}
```

## 测试内容

### 单元测试覆盖

- ✅ SDK单例模式
- ✅ 配置验证
- ✅ Token管理
- ✅ 数据模型序列化/反序列化
- ✅ 异常处理

### 集成测试覆盖

- ✅ SDK初始化
- ✅ 用户登录（真实API）
- ✅ 发送邮箱验证码
- ✅ Token刷新
- ✅ 用户退出登录
- ✅ API错误处理
- ✅ 性能测试

## 运行所有测试

```bash
# 运行单元测试
flutter test test/flutter_xboard_sdk_test.dart

# 运行集成测试（需要环境变量）
flutter test test/integration_test.dart

# 运行所有测试
flutter test
```

## 注意事项

### 安全性
- 🚨 **不要**在代码中硬编码真实的账号密码
- 🔐 使用环境变量来配置测试凭据
- 🧪 建议使用专门的测试账号，而不是生产环境账号

### 频率限制
- ⏱️ 某些API可能有频率限制
- 🚀 集成测试包含延迟来避免触发限制
- 🔄 如果测试失败，可能需要等待一段时间后重试

### 网络依赖
- 🌐 集成测试需要稳定的网络连接
- ⚡ 网络延迟可能影响测试结果
- 🛡️ 测试会捕获网络异常并进行适当处理

## 故障排除

### 常见问题

1. **环境变量未设置**
   ```
   需要设置环境变量才能运行集成测试
   ```
   解决：按照上述步骤设置所需的环境变量

2. **登录失败**
   ```
   ❌ 登录失败: Invalid credentials
   ```
   解决：检查测试邮箱和密码是否正确

3. **网络连接错误**
   ```
   🚨 登录测试出错: Network error
   ```
   解决：检查网络连接和XBoard服务器状态

4. **API频率限制**
   ```
   Too many requests
   ```
   解决：等待一段时间后重试，或减少测试频率

### 调试技巧

1. **查看详细日志**：集成测试会打印详细的请求和响应信息
2. **单独运行测试**：可以运行特定的测试用例进行调试
3. **检查API响应**：测试会显示完整的API响应内容

## 贡献测试

如果你发现bug或想要添加新的测试用例：

1. 🧪 为新功能添加单元测试
2. 🔌 为API交互添加集成测试
3. 📝 更新此文档
4. 🚀 确保所有测试都能通过 