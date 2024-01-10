class TimeSession {
  final int? id;
  final String? name;

  TimeSession({this.id, this.name});

  factory TimeSession.fromJson(Map<String, dynamic> json) {
    return TimeSession(
      id: json['id'],
      name: json['name'],
    );
  }
}
