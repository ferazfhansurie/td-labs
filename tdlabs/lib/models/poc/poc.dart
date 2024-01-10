// ignore_for_file: non_constant_identifier_names

class Poc {
  int? id;
  String? name;
  String? phoneNo;
  String? email;
  String? address;
  String? price;
  int? reportType;
  String? reportName;
  String? image_url;

  Poc(
      {this.id,
      this.name,
      this.phoneNo,
      this.email,
      this.address,
      this.price,
      this.reportType,
      this.reportName,
      this.image_url});

  factory Poc.fromJson(Map<String, dynamic> json) {
    return Poc(
      id: json['id'],
      name: (json['name'] != null) ? json['name'] : null,
      phoneNo: json['phone_no'],
      email: json['email'],
      address: json['address'],
      price: (json['price'] != null) ? json['price'] : '0',
      reportType: json['report_type'],
      reportName: json['report_name'],
      image_url: json['image_url'],
    );
  }
}
