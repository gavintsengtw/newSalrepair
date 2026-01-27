import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider with ChangeNotifier {
  // 模擬登入帳號 (格式: 案場別@戶別)
  // 實際應用中，這裡的值應該在登入成功後透過 login() 方法設定
  String _account = "";
  String _pjno = "";
  String _unit = "";
  DateTime? _expiryDate;
  Timer? _logoutTimer;

  // 建立 Secure Storage 實體
  final _storage = const FlutterSecureStorage();

  String get account => _account;
  String get pjno => _pjno;
  String get unit => _unit;
  bool get isLoggedIn => _account.isNotEmpty;

  UserProvider() {
    _parseAccount();
  }

  // 設定使用者帳號 (登入時呼叫)
  Future<void> login(String account) async {
    _account = account;
    _parseAccount();

    // 設定 Token 過期時間 (例如: 24 小時後)
    // 若後端有回傳過期時間，應使用後端回傳的值
    _expiryDate = DateTime.now().add(const Duration(hours: 24));
    _startAutoLogoutTimer();

    notifyListeners();

    await _storage.write(key: 'user_account', value: account);
    await _storage.write(
        key: 'token_expiry', value: _expiryDate!.toIso8601String());
  }

  // 清除使用者資訊 (登出時呼叫)
  Future<void> logout() async {
    _logoutTimer?.cancel();
    _expiryDate = null;
    _account = "";
    _pjno = "";
    _unit = "";
    notifyListeners();

    await _storage.delete(key: 'user_account');
    await _storage.delete(key: 'token_expiry');
  }

  // 檢查登入狀態 (App 啟動時呼叫)
  Future<bool> checkLoginStatus() async {
    final String? savedAccount = await _storage.read(key: 'user_account');
    final String? expiryStr = await _storage.read(key: 'token_expiry');

    if (savedAccount != null && savedAccount.isNotEmpty && expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);

      if (expiry.isBefore(DateTime.now())) {
        // Token 已過期，執行登出
        await logout();
        return false;
      }

      // Token 有效，恢復狀態
      _account = savedAccount;
      _expiryDate = expiry;
      _parseAccount();
      _startAutoLogoutTimer();
      notifyListeners();
      return true;
    }
    return false;
  }

  // 啟動自動登出計時器
  void _startAutoLogoutTimer() {
    _logoutTimer?.cancel();
    if (_expiryDate != null) {
      final timeToExpiry = _expiryDate!.difference(DateTime.now());
      if (timeToExpiry.isNegative) {
        logout();
      } else {
        _logoutTimer = Timer(timeToExpiry, () {
          logout();
        });
      }
    }
  }

  void _parseAccount() {
    if (_account.contains('@')) {
      final parts = _account.split('@');
      _pjno = parts[0]; // S_PJNO
      _unit = parts.length > 1 ? parts[1] : ''; // 戶別
    } else {
      _pjno = "";
      _unit = "";
    }
  }
}
