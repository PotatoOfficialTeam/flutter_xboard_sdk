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
