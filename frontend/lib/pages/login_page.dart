import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountController =
      TextEditingController(text: kDebugMode ? 'admin' : '');
  final _passwordController =
      TextEditingController(text: kDebugMode ? 'admin123' : '');
  bool _isLoading = false;

  // 移除本地 _baseUrl getter，改用 UserProvider

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final baseUrl = context.read<UserProvider>().baseUrl;
        final uri = Uri.parse('$baseUrl/api/users/login');

        // 發送登入請求
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'accountid': _accountController.text,
            'password': _passwordController.text,
          }),
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          // 解析回傳的使用者資料
          final userData = json.decode(response.body);
          // 假設後端回傳的 JSON 包含 accountid 欄位
          final String accountId =
              userData['accountid'] ?? _accountController.text;
          final String token = userData['token'] ?? ''; // 解析 Token
          final String roles = userData['roles'] ?? '';
          final String pjnoid = userData['pjnoid'] ?? '';
          final bool isDefaultPassword = userData['isDefaultPassword'] ?? false;

          // 呼叫 UserProvider 的 login 方法更新狀態
          await context
              .read<UserProvider>()
              .login(accountId, token, pjnoid, roles, isDefaultPassword);

          if (!mounted) return;

          // 顯示成功訊息
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登入成功')),
          );

          // 不需要手動導航，UserProvider 狀態更新後，
          // main.dart 中的 AuthCheckWrapper 會自動切換到 HomePage
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登入失敗：帳號或密碼錯誤')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('連線錯誤: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('豐邑客服系統')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120, // Adjust height as needed
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _accountController,
                    decoration: const InputDecoration(
                      labelText: '帳號',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? '請輸入帳號' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: '密碼',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? '請輸入密碼' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('登入'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/privacy');
                    },
                    child: const Text('隱私權政策'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
