# Token Management Tests

这个目录包含了XBoard SDK中Token管理系统的完整测试套件。

## 测试结构

### 单元测试

#### `token_manager_test.dart`
测试TokenManager类的核心功能：
- ✅ Token存储和读取
- ✅ Token有效性验证  
- ✅ 自动token刷新机制
- ✅ 认证状态管理
- ✅ 并发刷新控制
- ✅ 错误处理
- ✅ 配置选项

#### `auth_interceptor_test.dart`
测试AuthInterceptor类的HTTP拦截功能：
- ✅ 请求自动添加认证头
- ✅ 公开端点识别
- ✅ 401错误处理和重试
- ✅ Token刷新和重试机制
- ✅ 重试次数限制
- ✅ 公开端点管理

### 集成测试

#### `token_management_integration_test.dart`
端到端测试Token管理系统：
- ✅ SDK初始化和配置
- ✅ 登录流程集成
- ✅ HTTP请求认证集成
- ✅ 不同存储配置测试
- ✅ 认证状态监听
- ✅ 错误处理和降级

## 运行测试

### 运行所有测试
```bash
cd lib/sdk/flutter_xboard_sdk
flutter test
```

### 运行特定测试文件
```bash
# 单元测试
flutter test test/token_manager_test.dart
flutter test test/auth_interceptor_test.dart

# 集成测试
flutter test test/token_management_integration_test.dart
```

### 运行测试套件
```bash
flutter test test/run_tests.dart
```

## 测试覆盖的功能

### 🔐 Token存储
- [x] 安全存储读写
- [x] 内存存储读写
- [x] 存储失败处理
- [x] 缓存机制

### ⏰ Token生命周期
- [x] Token有效性检查
- [x] 过期检测
- [x] 自动刷新触发
- [x] 刷新缓冲时间

### 🔄 自动刷新
- [x] 成功刷新流程
- [x] 刷新失败处理
- [x] 并发刷新控制
- [x] 无刷新回调处理

### 🌐 HTTP集成
- [x] 请求自动认证
- [x] 401错误重试
- [x] 公开端点识别
- [x] 重试次数限制

### 📊 状态管理
- [x] 认证状态变化
- [x] 状态流监听
- [x] 刷新状态显示

### ⚙️ 配置管理
- [x] 默认配置
- [x] 生产环境配置
- [x] 调试配置
- [x] 测试配置
- [x] 自定义配置

### 🛡️ 错误处理
- [x] 存储错误
- [x] 网络错误
- [x] 刷新错误
- [x] 降级处理

## 测试数据和Mock

### Mock HTTP服务器
`MockHttpServer`类提供了完整的HTTP服务器模拟：
- 登录成功/失败响应
- Token刷新成功/失败响应
- 受保护端点响应
- 公开端点响应
- 401错误模拟
- 网络错误模拟

### Mock存储
- `MemoryTokenStorage`: 内存存储实现
- `FailingTokenStorage`: 失败存储实现（用于测试错误处理）

### 测试数据
- 有效Token数据
- 过期Token数据
- 即将过期Token数据
- 无效Token数据

## 测试最佳实践

### 1. 隔离性
每个测试都是独立的，使用setUp/tearDown确保测试间不相互影响。

### 2. 可预测性
使用固定的时间戳和可控的Mock数据，确保测试结果可预测。

### 3. 完整性
覆盖正常流程、边界条件和错误情况。

### 4. 真实性
集成测试尽可能模拟真实的使用场景。

## 故障排除

### 常见问题

1. **测试超时**
   - 检查异步操作是否正确等待
   - 确认Mock服务器正确响应

2. **状态检查失败**
   - 添加适当的延迟等待状态变化
   - 检查状态流监听是否正确设置

3. **存储测试失败**
   - 确认使用的是内存存储而非文件存储
   - 检查测试间是否正确清理

### 调试技巧

```dart
// 启用详细日志
await sdk.initialize(
  'http://test.com',
  tokenConfig: TokenStorageConfig.debug(enableLogging: true),
);

// 监听状态变化
sdk.authStateStream.listen((state) {
  print('Auth state changed to: $state');
});

// 检查存储状态
final storage = tokenManager.storage as MemoryTokenStorage;
print('Storage debug info: ${storage.debugInfo}');
```

## 贡献指南

添加新测试时请遵循以下原则：

1. **命名清晰**: 测试名称应该清楚描述被测试的功能
2. **结构统一**: 使用Arrange-Act-Assert模式
3. **覆盖完整**: 包括正常情况、边界条件和错误情况
4. **文档完善**: 为复杂的测试逻辑添加注释

### 测试模板

```dart
test('应该[预期行为]当[测试条件]', () async {
  // Arrange - 设置测试数据和环境
  
  // Act - 执行被测试的操作
  
  // Assert - 验证结果
  expect(actual, expected);
});
```