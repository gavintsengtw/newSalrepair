import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // 用於日期格式化

import '../providers/inbox_provider.dart';
import '../models/inbox_message.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  static const routeName = '/inbox';

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  void initState() {
    super.initState();
    // 畫面初始化時，立即獲取訊息
    Future.microtask(() {
      if (mounted) {
        Provider.of<InboxProvider>(context, listen: false).fetchMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('訊息中心'),
      ),
      body: Consumer<InboxProvider>(
        builder: (ctx, inboxProvider, child) {
          if (inboxProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (inboxProvider.messages.isEmpty) {
            return const Center(
              child: Text('沒有任何訊息。'),
            );
          }

          // 使用 RefreshIndicator 實現下拉刷新
          return RefreshIndicator(
            onRefresh: () => inboxProvider.fetchMessages(),
            child: ListView.builder(
              itemCount: inboxProvider.messages.length,
              itemBuilder: (ctx, i) =>
                  _buildMessageTile(context, inboxProvider.messages[i]),
            ),
          );
        },
      ),
    );
  }

  // 建立單一訊息的列表項
  Widget _buildMessageTile(BuildContext context, InboxMessage message) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: message.isRead
            ? Colors.grey.shade400
            : Theme.of(context).primaryColor,
        child: Icon(_getCategoryIcon(message.category), color: Colors.white),
      ),
      title: Text(
        message.title,
        style: TextStyle(
          fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(
        message.body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        DateFormat('MM/dd').format(message.createdAt),
        style: TextStyle(color: Colors.grey.shade600),
      ),
      onTap: () {
        // 點擊後標記為已讀，並彈出對話框顯示完整內容
        Provider.of<InboxProvider>(context, listen: false)
            .markAsRead(message.nid);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(message.title),
            content: SingleChildScrollView(child: Text(message.body)),
            actions: [
              TextButton(
                child: const Text('關閉'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  // 根據分類回傳對應的圖示
  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'REPAIR':
        return Icons.build;
      case 'PAYMENT':
        return Icons.payment;
      case 'NEWS':
        return Icons.campaign;
      default:
        return Icons.message;
    }
  }
}
