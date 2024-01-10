// ignore_for_file: non_constant_identifier_names

class PocDirectory {
  final String name;
  final String? registration_no;
  final String phone_no;
  final String? email;
  final String? unit_no;
  final String street_1;
  final String? street_2;
  final String city;
  final String? address;
  final String state_code;
  final String postcode;
  final String latitude;
  final String longitude;
  final String? description;
  final String? image_url;
  final String? expertise;
  final String? other_phone_no;
  int? poc_id;
  List? packages;
  List? images;
  PocDirectory(
      {required this.name,
      this.registration_no,
      required this.phone_no,
      this.unit_no,
      required this.email,
      required this.street_1,
      this.street_2,
      required this.city,
      this.address,
      required this.state_code,
      required this.postcode,
      required this.latitude,
      required this.longitude,
      this.description,
      this.image_url,
      this.expertise,
      this.other_phone_no,
      this.packages,
      this.images,
      this.poc_id});

  factory PocDirectory.fromJson(Map<String, dynamic> json) {
    return PocDirectory(
      name: json['name'],
      registration_no: json['registration_no'],
      phone_no: json['phone_no'],
      email: json['email'],
      unit_no: json['unit_no'],
      street_1: json['street_1'],
      street_2: json['street_2'],
      city: json['city'],
      state_code: json['state_code'],
      address: json['address'],
      description: json['description'],
      postcode: json['postcode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      image_url: json['image_url'],
      expertise: json['expertise'],
      other_phone_no: json['other_phone_no'],
      packages: json['packages'],
      poc_id: json['poc_id'],
      images: json['images'],
    );
  }
}
