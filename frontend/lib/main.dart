import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/member_page.dart';
import 'pages/project_selector_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

// 1. 定義全域導航 Key，用於在任何地方控制導航
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      String envFile = ".env.mac";
      if (kIsWeb) {
        envFile = ".env"; // Web fallback or default
      } else if (Platform.isAndroid) {
        envFile = ".env.android";
      } else if (Platform.isWindows) {
        envFile = ".env.windows";
      } else if (Platform.isIOS) {
        envFile = ".env.ios";
      }
      await dotenv.load(fileName: envFile);
    } catch (e) {
      debugPrint("❌ Error loading .env file: $e");
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    debugPrint("❌ Unhandled error: $error");
    debugPrint("Stack trace: $stack");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 2. 綁定 navigatorKey
      title: '豐邑客服系統',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Deep Indigo
          brightness: Brightness.light,
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFF00BFA5), // Teal Accent
          surface: const Color(0xFFF5F5F7),
        ),
        // textTheme: GoogleFonts.interTextTheme(
        //   Theme.of(context).textTheme,
        // ),
        textTheme: Theme.of(context).textTheme,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1A237E),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black.withValues(alpha: 0.1),
        ),
      ),
      // 3. 使用 builder 包裹 AuthListener，監聽登出事件
      builder: (context, child) {
        return AuthListener(child: child!);
      },
      home: const AuthCheckWrapper(),
    );
  }
}

// 4. 新增 AuthListener 元件，負責監聽 UserProvider 狀態並處理導航
class AuthListener extends StatefulWidget {
  final Widget child;
  const AuthListener({super.key, required this.child});

  @override
  State<AuthListener> createState() => _AuthListenerState();
}

class _AuthListenerState extends State<AuthListener> {
  @override
  void initState() {
    super.initState();
    context.read<UserProvider>().addListener(_handleAuthChange);
  }

  @override
  void dispose() {
    context.read<UserProvider>().removeListener(_handleAuthChange);
    super.dispose();
  }

  void _handleAuthChange() {
    final userProvider = context.read<UserProvider>();
    if (!userProvider.isLoggedIn) {
      // 當偵測到登出 (包含 Token 過期自動登出) 時，清除所有路由堆疊回到首頁 (LoginPage)
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AuthCheckWrapper extends StatefulWidget {
  const AuthCheckWrapper({super.key});

  @override
  State<AuthCheckWrapper> createState() => _AuthCheckWrapperState();
}

class _AuthCheckWrapperState extends State<AuthCheckWrapper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // 這裡只負責觸發檢查，狀態更新會透過 Provider 通知
    await context.read<UserProvider>().checkLoginStatus();
    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // 使用 context.watch 監聽 UserProvider，當 isLoggedIn 改變時自動切換頁面
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoggedIn) {
      // 如果是預設密碼，強制跳轉到會員中心
      if (userProvider.isDefaultPassword) return const MemberPage();

      // 如果尚未選擇案場，跳轉到案場選擇頁
      if (userProvider.currentSid == null) {
        return const ProjectSelectorPage();
      }

      return const HomePage();
    }
    return const LoginPage();
  }
}
