class Notifications {
  final int id;
  final String userId;
  final int screenId;
  final String name;
  final String message;
  final int isRead;
  final int createdAt;
  final String createdAtText;
  String? url ;

  Notifications({
    required this.id,
    required this.userId,
    required this.screenId,
    required this.name,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.createdAtText,
    this.url,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      id: json['id'],
      userId: json['user_id'],
      screenId: json['screen_id'],
      name: json['name'],
      message: json['message'],
      isRead: json['is_read'],
      createdAt: json['created_at'],
      createdAtText: json['created_at_text'],
       url: json['url'],
    );
  }
}
