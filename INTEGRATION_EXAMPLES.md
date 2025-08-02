# XBoard SDK 集成示例

## 📱 完整页面示例

### 1. 登录页面

```dart
// lib/pages/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('XBoard 登录'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 邮箱输入框
              TextFormField(
                key: Key('email_field'),
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '邮箱',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入邮箱';
                  }
                  if (!value.contains('@')) {
                    return '请输入有效的邮箱地址';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              
              // 密码输入框
              TextFormField(
                key: Key('password_field'),
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  if (value.length < 6) {
                    return '密码至少6位';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 24),
              
              // 错误信息显示
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (_errorMessage != null) SizedBox(height: 16),
              
              // 登录按钮
              ElevatedButton(
                key: Key('login_button'),
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('登录中...'),
                        ],
                      )
                    : Text('登录'),
              ),
              
              SizedBox(height: 16),
              
              // 其他操作链接
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('注册新账号'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/reset-password');
                    },
                    child: Text('忘记密码？'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await XBoardSDK.instance.loginWithCredentials(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        // 登录成功，跳转到主页面
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() {
          _errorMessage = '登录失败，请检查邮箱和密码';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = '认证失败: ${e.message}';
      });
    } on NetworkException catch (e) {
      setState(() {
        _errorMessage = '网络连接失败，请检查网络设置';
      });
    } catch (e) {
      setState(() {
        _errorMessage = '登录失败: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

### 2. 用户信息页面

```dart
// lib/pages/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserInfo? _userInfo;
  SubscriptionInfo? _subscriptionInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人中心'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUserData,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'logout', child: Text('退出登录')),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载中...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: Text('重试'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildUserInfoCard(),
          SizedBox(height: 16),
          _buildSubscriptionCard(),
          SizedBox(height: 16),
          _buildActionsCard(),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    if (_userInfo == null) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: _userInfo!.avatarUrl.isNotEmpty
                      ? NetworkImage(_userInfo!.avatarUrl)
                      : null,
                  child: _userInfo!.avatarUrl.isEmpty
                      ? Icon(Icons.person)
                      : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userInfo!.email,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_userInfo!.telegramId != null)
                        Text('Telegram: ${_userInfo!.telegramId}'),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            _buildInfoRow('用户ID', _userInfo!.uuid),
            _buildInfoRow('注册时间', _formatTimestamp(_userInfo!.createdAt)),
            if (_userInfo!.lastLoginAt != null)
              _buildInfoRow('最后登录', _formatTimestamp(_userInfo!.lastLoginAt!)),
            _buildInfoRow('账户状态', _userInfo!.banned ? '已封禁' : '正常'),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '订阅信息',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            if (_subscriptionInfo != null) ...[
              _buildInfoRow('已用流量', _formatBytes(_subscriptionInfo!.usedTraffic)),
              _buildInfoRow('总流量', _formatBytes(_subscriptionInfo!.totalTraffic)),
              _buildInfoRow('剩余流量', 
                _formatBytes(_subscriptionInfo!.totalTraffic - _subscriptionInfo!.usedTraffic)),
              if (_userInfo?.expiredAt != null)
                _buildInfoRow('到期时间', _formatTimestamp(_userInfo!.expiredAt!)),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _copySubscriptionUrl,
                      icon: Icon(Icons.copy),
                      label: Text('复制订阅链接'),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _resetSubscription,
                    icon: Icon(Icons.refresh),
                    label: Text('重置'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text('无订阅信息'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    if (_userInfo == null) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '余额信息',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            _buildInfoRow('可用余额', '¥${(_userInfo!.balance / 100).toStringAsFixed(2)}'),
            _buildInfoRow('佣金余额', '¥${(_userInfo!.commissionBalance / 100).toStringAsFixed(2)}'),
            if (_userInfo!.commissionBalance > 0) ...[
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _transferCommission,
                icon: Icon(Icons.transform),
                label: Text('转移佣金到余额'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 并行获取用户信息和订阅信息
      final results = await Future.wait([
        XBoardSDK.instance.userInfo.getUserInfo(),
        XBoardSDK.instance.subscription.getSubscriptionInfo(),
      ]);

      final userResponse = results[0] as ApiResponse<UserInfo>;
      final subscriptionResponse = results[1] as ApiResponse<SubscriptionInfo>;

      setState(() {
        if (userResponse.success) {
          _userInfo = userResponse.data;
        }
        if (subscriptionResponse.success) {
          _subscriptionInfo = subscriptionResponse.data;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载失败: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _copySubscriptionUrl() async {
    if (_subscriptionInfo?.subscribeUrl != null) {
      await Clipboard.setData(ClipboardData(text: _subscriptionInfo!.subscribeUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('订阅链接已复制到剪贴板')),
      );
    }
  }

  Future<void> _resetSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认重置'),
        content: Text('重置订阅链接后，原链接将失效。确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await XBoardSDK.instance.subscription.resetSubscription();
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('订阅链接已重置')),
          );
          _loadUserData(); // 重新加载数据
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('重置失败: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _transferCommission() async {
    if (_userInfo?.commissionBalance == null || _userInfo!.commissionBalance <= 0) {
      return;
    }

    try {
      final response = await XBoardSDK.instance.balanceApi.transferCommission(
        _userInfo!.commissionBalance.toInt(),
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('佣金转移成功')),
        );
        _loadUserData(); // 重新加载数据
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('转移失败: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'logout':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('确认退出'),
            content: Text('确定要退出登录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('退出'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await XBoardSDK.instance.clearTokens();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
        break;
    }
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
```

### 3. 路由守卫示例

```dart
// lib/utils/auth_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  
  const AuthGuard({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: XBoardSDK.instance.authStateStream,
      initialData: XBoardSDK.instance.authState,
      builder: (context, snapshot) {
        final authState = snapshot.data ?? AuthState.unauthenticated;
        
        switch (authState) {
          case AuthState.authenticated:
            return child;
          case AuthState.refreshing:
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在验证登录状态...'),
                  ],
                ),
              ),
            );
          default:
            return fallback ?? LoginPage();
        }
      },
    );
  }
}

// 使用示例
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => AuthGuard(
            child: DashboardPage(),
            fallback: LoginPage(),
          ),
        );
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case '/profile':
        return MaterialPageRoute(
          builder: (_) => AuthGuard(child: ProfilePage()),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('页面未找到')),
          ),
        );
    }
  }
}
```

### 4. 全局错误处理器

```dart
// lib/utils/global_error_handler.dart
import 'package:flutter/material.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

class GlobalErrorHandler {
  static GlobalKey<ScaffoldMessengerState>? _scaffoldMessengerKey;
  
  static void initialize(GlobalKey<ScaffoldMessengerState> key) {
    _scaffoldMessengerKey = key;
  }
  
  static void handleError(dynamic error, {VoidCallback? onRetry}) {
    String message;
    Color backgroundColor = Colors.red;
    IconData icon = Icons.error;
    bool showRetry = false;
    
    if (error is AuthException) {
      message = '登录已过期，请重新登录';
      icon = Icons.lock;
      // 自动跳转到登录页面
      _navigateToLogin();
    } else if (error is NetworkException) {
      message = '网络连接失败';
      backgroundColor = Colors.orange;
      icon = Icons.wifi_off;
      showRetry = true;
    } else if (error is ApiException) {
      message = error.message;
      if (error.code == 429) {
        message = '请求过于频繁，请稍后再试';
        backgroundColor = Colors.amber;
        icon = Icons.schedule;
      }
    } else {
      message = '操作失败，请重试';
      showRetry = true;
    }
    
    _showSnackBar(
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      showRetry: showRetry,
      onRetry: onRetry,
    );
  }
  
  static void _showSnackBar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    bool showRetry = false,
    VoidCallback? onRetry,
  }) {
    _scaffoldMessengerKey?.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        action: showRetry && onRetry != null
            ? SnackBarAction(
                label: '重试',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: Duration(seconds: showRetry ? 10 : 4),
      ),
    );
  }
  
  static void _navigateToLogin() {
    // 获取当前导航器并跳转到登录页面
    final navigator = _scaffoldMessengerKey?.currentState?.context;
    if (navigator != null) {
      Navigator.pushNamedAndRemoveUntil(
        navigator,
        '/login',
        (route) => false,
      );
    }
  }
}

// 在 main.dart 中初始化
void main() {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  
  GlobalErrorHandler.initialize(scaffoldMessengerKey);
  
  runApp(
    MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      onGenerateRoute: AppRouter.generateRoute,
    ),
  );
}
```

### 5. 使用 Riverpod 的状态管理示例

```dart
// lib/providers/xboard_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

// 认证状态Provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return XBoardSDK.instance.authStateStream;
});

// 用户信息Provider
final userInfoProvider = FutureProvider<UserInfo?>((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  
  if (authState != AuthState.authenticated) {
    return null;
  }
  
  try {
    final response = await XBoardSDK.instance.userInfo.getUserInfo();
    return response.success ? response.data : null;
  } catch (e) {
    // 错误处理
    ref.read(errorProvider.notifier).setError(e);
    return null;
  }
});

// 订阅信息Provider
final subscriptionInfoProvider = FutureProvider<SubscriptionInfo?>((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  
  if (authState != AuthState.authenticated) {
    return null;
  }
  
  try {
    final response = await XBoardSDK.instance.subscription.getSubscriptionInfo();
    return response.success ? response.data : null;
  } catch (e) {
    ref.read(errorProvider.notifier).setError(e);
    return null;
  }
});

// 错误状态Provider
final errorProvider = StateNotifierProvider<ErrorNotifier, String?>((ref) {
  return ErrorNotifier();
});

class ErrorNotifier extends StateNotifier<String?> {
  ErrorNotifier() : super(null);
  
  void setError(dynamic error) {
    if (error is XBoardException) {
      state = error.message;
    } else {
      state = error.toString();
    }
  }
  
  void clearError() {
    state = null;
  }
}

// 认证操作Provider
final authActionsProvider = Provider<AuthActions>((ref) {
  return AuthActions(ref);
});

class AuthActions {
  final Ref ref;
  
  AuthActions(this.ref);
  
  Future<bool> login(String email, String password) async {
    try {
      final success = await XBoardSDK.instance.loginWithCredentials(email, password);
      if (success) {
        // 刷新相关数据
        ref.invalidate(userInfoProvider);
        ref.invalidate(subscriptionInfoProvider);
      }
      return success;
    } catch (e) {
      ref.read(errorProvider.notifier).setError(e);
      return false;
    }
  }
  
  Future<void> logout() async {
    await XBoardSDK.instance.clearTokens();
    // 清除所有缓存的数据
    ref.invalidate(userInfoProvider);
    ref.invalidate(subscriptionInfoProvider);
  }
}

// 页面中使用Provider
class ProfilePageWithProviders extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userInfo = ref.watch(userInfoProvider);
    final subscriptionInfo = ref.watch(subscriptionInfoProvider);
    final error = ref.watch(errorProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('个人中心'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(userInfoProvider);
              ref.invalidate(subscriptionInfoProvider);
            },
          ),
        ],
      ),
      body: authState.when(
        data: (state) {
          if (state != AuthState.authenticated) {
            return Center(child: Text('请先登录'));
          }
          
          return Column(
            children: [
              // 错误提示
              if (error != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  color: Colors.red.shade100,
                  child: Text(error, style: TextStyle(color: Colors.red)),
                ),
              
              // 用户信息
              Expanded(
                child: userInfo.when(
                  data: (user) => user != null 
                      ? _buildUserInfo(user)
                      : Center(child: Text('无用户信息')),
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('加载失败: $error'),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('认证错误: $error')),
      ),
    );
  }
  
  Widget _buildUserInfo(UserInfo user) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: user.avatarUrl.isNotEmpty
                  ? NetworkImage(user.avatarUrl)
                  : null,
              child: user.avatarUrl.isEmpty ? Icon(Icons.person) : null,
            ),
            title: Text(user.email),
            subtitle: Text('余额: ¥${(user.balance / 100).toStringAsFixed(2)}'),
          ),
        ),
        // 更多信息...
      ],
    );
  }
}
```

这些示例展示了如何在实际项目中集成和使用XBoard SDK，包括完整的UI实现、错误处理、状态管理等最佳实践。