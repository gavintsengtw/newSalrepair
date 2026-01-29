import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/inbox_message.dart';
import 'user_provider.dart';

class InboxProvider with ChangeNotifier {
  final UserProvider? _userProvider;
  List<InboxMessage> _messages = [];
  bool _isLoading = false;

  // 透過建構子接收 UserProvider 以取得 API URL 和 token
  InboxProvider(this._userProvider);

  List<InboxMessage> get messages => [..._messages];
  bool get isLoading => _isLoading;
  int get unreadCount => _messages.where((msg) => !msg.isRead).length;

  Future<void> fetchMessages() async {
    if (_userProvider == null || !_userProvider!.isLoggedIn) return;

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse('${_userProvider!.baseUrl}/api/inbox');
      final response = await http.get(uri, headers: _userProvider!.authHeaders);

      if (response.statusCode == 200) {
        // 使用 utf8.decode 處理中文字元
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _messages = data.map((json) => InboxMessage.fromJson(json)).toList();
      } else {
        debugPrint('Failed to load messages: ${response.statusCode}');
        _messages = [];
      }
    } catch (e) {
      debugPrint('Failed to fetch inbox messages: $e');
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int nid) async {
    final messageIndex = _messages.indexWhere((msg) => msg.nid == nid);
    if (messageIndex == -1 || _messages[messageIndex].isRead) {
      return; // 找不到訊息或訊息已讀
    }

    // 先更新 UI，提供更好的使用者體驗
    _messages[messageIndex].isRead = true;
    notifyListeners();

    try {
      final uri = Uri.parse('${_userProvider!.baseUrl}/api/inbox/$nid/read');
      final response = await http.put(uri, headers: _userProvider!.authHeaders);

      if (response.statusCode != 200) {
        // 若 API 呼叫失敗，則還原 UI 狀態
        _messages[messageIndex].isRead = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to mark message as read: $e');
      _messages[messageIndex].isRead = false;
      notifyListeners();
    }
  }
}
