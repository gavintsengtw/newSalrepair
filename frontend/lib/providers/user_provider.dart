import 'dart:async';
import 'dart:convert';
import '../services/api_service.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config.dart';

class UserProvider with ChangeNotifier {
  // 模擬登入帳號 (格式: 案場別@戶別)
  // 實際應用中，這裡的值應該在登入成功後透過 login() 方法設定
  String _account = "";
  String _pjno = "";
  String _unit = "";
  String _roles = ""; // New
  List<dynamic> _projects = []; // List of SalrepairStore objects (maps)
  String? _currentSid; // Selected project unique ID
  String _currentPjno = "";
  String _currentUnit = "";
  bool _isDefaultPassword = false; // New
  String _token = "";
  DateTime? _expiryDate;
  Timer? _logoutTimer;
  List<dynamic>? _paymentHistoryCache; // 新增繳款紀錄快取
  List<dynamic> _menus = []; // Store dynamic menus

  // 建立 Secure Storage 實體
  final _storage = const FlutterSecureStorage();

  String get account => _account;
  String get pjno => _pjno;

  String get unit =>
      _currentUnit.isNotEmpty ? _currentUnit : _unit; // Prefer selected unit
  String get roles => _roles; // New
  List<dynamic> get menus => _menus;
  List<dynamic> get projects => _projects;
  String? get currentSid => _currentSid;
  String get currentPjno => _currentPjno.isNotEmpty ? _currentPjno : _pjno;
  String get currentUnit => _currentUnit.isNotEmpty ? _currentUnit : _unit;
  bool get isDefaultPassword => _isDefaultPassword; // New
  String get token => _token;
  bool get isLoggedIn => _account.isNotEmpty;

  UserProvider() {
    _parseAccount();
  }

  // 根據平台取得 Base URL
  String get baseUrl {
    return AppConfig.apiUrl;
  }

  // 取得帶有 Authorization 的 Header (方便 API 呼叫使用)
  Map<String, String> get authHeaders => {'Authorization': 'Bearer $_token'};

  // 設定使用者帳號 (登入時呼叫)
  Future<void> login(String account, String token, String pjnoid, String roles,
      bool isDefaultPassword) async {
    _account = account;
    _token = token;
    _pjno = pjnoid;
    _roles = roles;
    _isDefaultPassword = isDefaultPassword;
    _paymentHistoryCache = null; // 登入時重置快取
    _parseAccount(); // 解析 Unit (如果有)

    // Update ApiService token
    ApiService().setToken(token);

    // 設定 Token 過期時間 (例如: 24 小時後)
    _expiryDate = DateTime.now().add(const Duration(hours: 24));
    _startTokenRefreshTimer();

    // await _storage.write(
    //     key: 'token_expiry', value: _expiryDate!.toIso8601String());

    // Fetch projects after login
    await fetchUserProjects();
    await fetchUserMenus();

    // Disable persistence for "Login on App Restart" requirement
    // await _storage.write(key: 'user_account', value: account);
    // await _storage.write(key: 'auth_token', value: token);
    // await _storage.write(key: 'user_pjnoid', value: pjnoid);
    // await _storage.write(key: 'user_roles', value: roles);
    // await _storage.write(
    //     key: 'user_is_default_pwd', value: isDefaultPassword.toString());
  }

  // 清除使用者資訊 (登出時呼叫)
  Future<void> logout() async {
    debugPrint("🔄 UserProvider: Logging out...");
    _logoutTimer?.cancel();
    _expiryDate = null;
    _account = "";
    _token = "";
    _pjno = "";
    _unit = "";
    _roles = "";
    _isDefaultPassword = false;
    _projects = [];
    _currentSid = null;
    _currentPjno = "";
    _currentUnit = "";
    _paymentHistoryCache = null; // 登出時清除快取

    // Clear ApiService token
    ApiService().setToken(null);

    try {
      await _storage.delete(key: 'user_account');
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_pjnoid');
      await _storage.delete(key: 'user_roles');
      await _storage.delete(key: 'user_is_default_pwd');
      await _storage.delete(key: 'token_expiry');
      await _storage.delete(key: 'current_sid');
      debugPrint("✅ UserProvider: Storage cleared.");
    } catch (e) {
      debugPrint("⚠️ UserProvider: Error clearing storage: $e");
    }

    notifyListeners();
    debugPrint("📢 UserProvider: logout notifyListeners() called.");
  }

  // 檢查登入狀態 (App 啟動時呼叫)
  Future<bool> checkLoginStatus() async {
    // Disable auto-login: Always return false to require login on restart
    return false;
    /*
    try {
      final String? savedAccount = await _storage.read(key: 'user_account');
      final String? savedToken = await _storage.read(key: 'auth_token');
      final String? savedPjnoid = await _storage.read(key: 'user_pjnoid');
      final String? savedRoles = await _storage.read(key: 'user_roles');
      final String? savedIsDefaultPwd =
          await _storage.read(key: 'user_is_default_pwd');
      final String? expiryStr = await _storage.read(key: 'token_expiry');
      final String? savedSid =
          await _storage.read(key: 'current_sid'); // Restore selected project

      if (savedAccount != null &&
          savedAccount.isNotEmpty &&
          savedToken != null &&
          savedToken.isNotEmpty &&
          expiryStr != null) {
        final expiry = DateTime.parse(expiryStr);

        if (expiry.isBefore(DateTime.now())) {
          // Token 已過期，執行登出
          await logout();
          return false;
        }

        // Token 有效，恢復狀態
        _account = savedAccount;
        _token = savedToken;
        _pjno = savedPjnoid ?? "";
        _roles = savedRoles ?? "";
        _isDefaultPassword = savedIsDefaultPwd == 'true';
        _expiryDate = expiry;
        _currentSid = savedSid; // Restore selection
        _parseAccount();
        _startTokenRefreshTimer();

        // Fetch projects to validate selection or get fresh data
        fetchUserProjects();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Error checking login status: $e");
      return false;
    }
    */
  }

  // 啟動 Token 自動換發/登出計時器
  void _startTokenRefreshTimer() {
    _logoutTimer?.cancel();
    if (_expiryDate != null) {
      final now = DateTime.now();
      final timeToExpiry = _expiryDate!.difference(now);

      // 設定在過期前 5 分鐘進行換發
      const refreshBuffer = Duration(minutes: 5);

      if (timeToExpiry.isNegative) {
        logout();
      } else if (timeToExpiry < refreshBuffer) {
        // 即將過期，立即嘗試換發
        _refreshToken();
      } else {
        // 設定計時器在過期前 5 分鐘觸發
        _logoutTimer = Timer(timeToExpiry - refreshBuffer, () {
          _refreshToken();
        });
      }
    }
  }

  // 執行 Token 換發
  Future<void> _refreshToken() async {
    try {
      final uri = Uri.parse('$baseUrl/api/users/refresh');
      // 這裡示範傳送帳號，實際應用中應傳送 Refresh Token 或 Session ID
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'accountid': _account}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newToken = data['token'];
        // 更新 Token 與過期時間
        _token = newToken;
        _expiryDate =
            DateTime.now().add(const Duration(hours: 24)); // 或解析 data['expiry']

        // await _storage.write(key: 'auth_token', value: newToken);
        // await _storage.write(
        //     key: 'token_expiry', value: _expiryDate!.toIso8601String());
        _startTokenRefreshTimer(); // 重新啟動計時器
        notifyListeners();
      } else {
        logout(); // 換發失敗則登出
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      logout(); // 網路錯誤或例外時登出
    }
  }

  // Fetch user projects
  Future<void> fetchUserProjects() async {
    try {
      final uri = Uri.parse('$baseUrl/api/users/projects');
      final response = await http.get(
        uri,
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _projects = data;

        if (_currentSid != null) {
          final selected = _projects.firstWhere(
              (p) => p['sid'].toString() == _currentSid,
              orElse: () => null);
          if (selected != null) {
            selectProject(selected);
          } else {
            // Saved selection invalid (e.g. project removed), clear it
            clearProjectSelection();
          }
        }

        // B. Single Unit -> Auto Select (if not already selected)
        if (_currentSid == null && _projects.length == 1) {
          selectProject(_projects[0]);
        }
        // C. Multiple Units -> Do nothing, let UI show selector

        notifyListeners();
      } else {
        debugPrint('Failed to fetch projects: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching projects: $e');
    }
  }

  // Select a project
  void selectProject(Map<String, dynamic> project) async {
    _currentSid = project['sid'].toString();
    _currentPjno = project['pjnoid'];
    _currentUnit = project['unoid'];

    // Update legacy fields for compatibility if needed, but prefer current* fields
    // _pjno = _currentPjno;
    // _unit = _currentUnit;

    notifyListeners();
    // Persist selection - Disabled
    // await _storage.write(key: 'current_sid', value: _currentSid);
  }

  // Clear selection to return to selector
  void clearProjectSelection() async {
    _currentSid = null;
    _currentPjno = "";
    _currentUnit = "";
    notifyListeners();
    await _storage.delete(key: 'current_sid');
  }

  // 更新密碼預設狀態 (當使用者變更密碼後呼叫)
  Future<void> updatePasswordStatus(bool isDefault) async {
    _isDefaultPassword = isDefault;
    notifyListeners();
    // await _storage.write(
    //     key: 'user_is_default_pwd', value: isDefault.toString());
  }

  void _parseAccount() {
    if (_account.contains('@')) {
      final parts = _account.split('@');
      // _pjno = parts[0]; // Modified: pjno is now from pjnoid
      _unit = parts.length > 1 ? parts[1] : ''; // 戶別
    } else {
      // _pjno = "";
      _unit = "";
    }
  }

  // 更新 FCM Token 到後端 (請在登入成功或 App 啟動時呼叫)
  Future<void> updateFcmToken(String fcmToken) async {
    if (!isLoggedIn) return;

    try {
      // 假設後端有一個接收 Token 的 API，請確保後端有對應的 Controller
      final uri = Uri.parse('$baseUrl/api/users/fcm-token');
      await http.post(
        uri,
        headers: authHeaders..addAll({'Content-Type': 'application/json'}),
        body: json.encode({'token': fcmToken}),
      );
      debugPrint('FCM Token updated successfully: $fcmToken');
    } catch (e) {
      debugPrint('Failed to update FCM token: $e');
    }
  }

  // 取得繳款紀錄
  Future<List<dynamic>> fetchPaymentHistory({bool forceRefresh = false}) async {
    if (!isLoggedIn) return [];

    // 若不強制重新整理且快取有資料，直接回傳快取
    if (!forceRefresh && _paymentHistoryCache != null) {
      return _paymentHistoryCache!;
    }

    try {
      final uri = Uri.parse('$baseUrl/api/payment/$_account').replace(
        queryParameters: {
          'pjnoid': currentPjno,
          'unoid': currentUnit,
        },
      );
      debugPrint('Fetching payment history from: $uri');
      final response = await http.get(uri, headers: authHeaders);

      if (response.statusCode == 200) {
        _paymentHistoryCache = json.decode(response.body); // 更新快取
        return _paymentHistoryCache!;
      } else {
        debugPrint('Failed to fetch payment history: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching payment history: $e');
      return [];
    }
  }

  // Fetch user menus
  Future<void> fetchUserMenus() async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/user/menus');
      final response = await http.get(
        uri,
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _menus = data['data']['menus'];
          notifyListeners();
        }
      } else {
        debugPrint('Failed to fetch menus: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching menus: $e');
    }
  }
}
