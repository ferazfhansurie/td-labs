// ignore_for_file: non_constant_identifier_names

class Redeem {
  int? package_id;
  String? package_name;
  int? user_id;
  int? redeem_limit;
  int? redeem_count;
  String? redeem_at;
  int? is_disabled;
  int? created_at;
  int? updated_at;
  String? reward_amount;
  bool? is_valid;
  String? redeemed_at;
  Redeem({
    this.package_id,
    this.package_name,
    this.user_id,
    this.redeem_limit,
    this.redeem_count,
    this.redeem_at,
    this.created_at,
    this.is_disabled,
    this.updated_at,
    this.reward_amount,
    this.is_valid,
    this.redeemed_at,
  });

  factory Redeem.fromJson(Map<String, dynamic> json) {
    return Redeem(
      package_id: json['package_id'],
      package_name: json['package_name'],
      user_id: json['user_id'],
      redeem_limit: json['redeem_limit'],
      redeem_count: json['redeem_count'],
      redeem_at: json['redeem_at'],
      is_disabled: json['is_disabled'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
      reward_amount: json['reward_amount'],
      is_valid: json['is_valid'],
      redeemed_at: json['redeemed_at'],
    );
  }
}
