# 更新日志

## [0.0.1] - 2024-01-20

### 新增
- ✨ 初始版本发布
- 🔐 实现用户认证系统
  - 用户登录功能
  - 用户注册功能
  - 邮箱验证码发送
  - 密码重置功能
  - Token刷新功能
  - 用户退出登录
- 🏗️ 完整的SDK架构
  - HttpService：处理所有HTTP请求
  - AuthService：认证相关服务
  - XBoardSDK：主要SDK类（单例模式）
- 📦 数据模型
  - LoginRequest/LoginResponse：登录相关模型
  - RegisterRequest：注册请求模型
  - UserInfo：用户信息模型
  - ApiResponse：通用API响应模型
- ⚡ 异常处理系统
  - XBoardException：基础异常类
  - AuthException：认证异常
  - NetworkException：网络异常
  - ConfigException：配置异常
  - ParameterException：参数异常
- 🧪 完整的单元测试覆盖
- 📖 详细的使用文档和示例

### 技术特性
- 🎯 类型安全的API调用
- 🔄 自动Token管理
- 🛡️ 完整的错误处理
- 📱 单例模式设计
- 🚀 支持Flutter 1.17.0+
- 💎 Dart 3.6.0+支持

### API端点支持
- `/api/v1/passport/auth/login` - 用户登录
- `/api/v1/passport/auth/register` - 用户注册
- `/api/v1/passport/auth/logout` - 用户退出
- `/api/v1/passport/auth/token` - Token刷新
- `/api/v1/passport/auth/forget` - 密码重置
- `/api/v1/passport/comm/sendEmailVerify` - 发送邮箱验证码

## [0.3.0] - 2024-12-19

### ✨ 新增功能
- **💰 余额管理服务**: 完整的余额和提现功能
  - 系统配置获取 (`getSystemConfig()`)
  - 用户余额查询 (`getBalanceInfo()`)
  - 佣金转账功能 (`transferCommission()`)
  - 提现申请功能 (`withdrawFunds()`)
  - 提现历史查询 (`getWithdrawHistory()`)
  - 佣金历史查询 (`getCommissionHistory()`)

### 📊 数据模型
- `SystemConfig`: 系统配置模型
- `BalanceInfo`: 余额信息模型
- `TransferResult`: 转账结果模型
- `WithdrawResult`: 提现结果模型

### 🔧 改进
- 更新了SDK主类，集成余额服务
- 完善了API文档和使用示例
- 增强了类型安全和错误处理

### 📖 文档
- 更新README，添加余额功能完整文档
- 添加详细的API参考和使用示例
- 更新了快速开始指南

## [0.2.0] - 2024-12-19

### ✨ 新增功能
- **📱 订阅管理服务**: 完整的订阅管理功能
  - 获取订阅信息 (`getSubscriptionInfo()`)
  - 重置订阅链接 (`resetSubscription()`)
  - 获取订阅统计 (`getSubscriptionStats()`)
  - 订阅信息缓存机制

### 🔧 改进
- 解决了Token传递问题，统一使用全局Token机制
- 优化了HTTP服务的Authorization头处理
- 移除了重复的Token传递逻辑

### 🛠️ 修复
- 修复了订阅服务中的编译错误
- 统一了API响应格式处理
- 改进了错误处理机制

## [0.1.0] - 2024-12-19

### ✨ 初始版本
- **🔐 完整的认证系统**
  - 用户登录 (`login()`)
  - 用户注册 (`register()`)
  - 邮箱验证码 (`sendVerificationCode()`)
  - 密码重置 (`resetPassword()`)

### 🏗️ 核心架构
- **HttpService**: HTTP请求处理服务
- **XBoardSDK**: 主SDK类，单例模式
- **完整的数据模型**: 包含认证相关的所有数据结构
- **异常处理**: 自定义异常系统

### 🧪 测试
- 完整的单元测试覆盖
- 集成测试支持真实API
- 性能基准测试

### 📱 平台支持
- Android ✅
- iOS ✅  
- Web ✅
- Desktop ✅

### 🛡️ 安全特性
- Token自动管理
- HTTPS加密通信
- 输入数据验证
- 完善的错误处理
