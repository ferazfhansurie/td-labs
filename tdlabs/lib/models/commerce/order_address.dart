class OrderAddress {
  int? id;
  int? orderId;
  String? name;
  String? phoneNo;
  String? email;
  String? address_1;
  String? address_2;
  String? postcode;
  String? city;
  String? stateCode;
  String? remark;

  OrderAddress({
    this.id,
    this.orderId,
    this.phoneNo,
    this.email,
    this.address_1,
    this.address_2,
    this.postcode,
    this.city,
    this.stateCode,
    this.remark,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      id: json['id'],
      orderId: json['order_id'],
      phoneNo: json['phone_no'],
      email: json['email'],
      address_1: json['address_1'],
      address_2: json['address_2'],
      postcode: json['postcode'],
      city: json['city'],
      stateCode: json['state_code'],
      remark: json['remark'],
    );
  }
}
