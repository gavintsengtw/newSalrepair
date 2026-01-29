class InboxMessage {
  final int nid;
  final String accountId;
  final String? category;
  final String title;
  final String body;
  final int? targetId;
  bool isRead;
  final DateTime createdAt;

  InboxMessage({
    required this.nid,
    required this.accountId,
    this.category,
    required this.title,
    required this.body,
    this.targetId,
    required this.isRead,
    required this.createdAt,
  });

  factory InboxMessage.fromJson(Map<String, dynamic> json) {
    return InboxMessage(
      nid: json['nid'],
      accountId: json['accountid'],
      category: json['category'],
      title: json['title'],
      body: json['body'],
      targetId: json['target_id'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
