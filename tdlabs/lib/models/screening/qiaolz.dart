// ignore_for_file: non_constant_identifier_names


class Qiaolz {
  int? id;
  String? referenceId;
  int? userId;
  String? qiaolzUserId;
  String? deviceId;
  double? score1;
  double? score2;
  String? url;
  String? dump;
  int? createdAt;

  Qiaolz({
    this.id,
    this.referenceId,
    this.userId,
    this.qiaolzUserId,
    this.deviceId,
    this.score1,
    this.score2,
    this.url,
    this.dump,
    this.createdAt,
  });

  factory Qiaolz.fromJson(Map<String, dynamic> json) {
    return Qiaolz(
      id: json['id'],
      referenceId: json['reference_id'],
      userId: json['user_id'],
      qiaolzUserId: json['qiaolz_user_id'],
      deviceId: json['device_id'],
      score1: double.parse(json['score_1']),
      score2: double.parse(json['score_2']),
      url: json['url'],
      dump: json['dump'],
      createdAt: json['created_at'],
    );
  }

}
