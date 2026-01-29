class InboxMessage {
  final int nid;
  final String accountId;
  final String? fcmToken;
  final String category;
  final String title;
  final String body;
  final int? targetId;
  bool isRead;
  final DateTime createdAt;

  InboxMessage({
    required this.nid,
    required this.accountId,
    this.fcmToken,
    required this.category,
    required this.title,
    required this.body,
    this.targetId,
    required this.isRead,
    required this.createdAt,
  });

  factory InboxMessage.fromJson(Map<String, dynamic> json) {
    return InboxMessage(
      nid: json['nid'],
      accountId: json['accountId'],
      fcmToken: json['fcmToken'],
      category: json['category'],
      title: json['title'],
      body: json['body'],
      targetId: json['targetId'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nid': nid,
      'accountId': accountId,
      'fcmToken': fcmToken,
      'category': category,
      'title': title,
      'body': body,
      'targetId': targetId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
