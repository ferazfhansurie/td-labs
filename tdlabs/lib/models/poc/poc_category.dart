// ignore_for_file: non_constant_identifier_names

class PocCategory {
  final int id;
  final String name;
  String? image_url;
  PocCategory({
    required this.id,
    required this.name,
    this.image_url,
  });

  factory PocCategory.fromJson(Map<String, dynamic> json) {
    return PocCategory(
      id: json['id'],
      name: json['name'],
      image_url: json['image_url'],
    );
  }
}
