// ignore_for_file: non_constant_identifier_names

class Banners {
  final int id;
  final String title;
  final String description;
  final String? url;
  final String image;
  final String imageUrl;
  final String createdAtText;
  int? is_disabled;

  Banners(
      {required this.id,
      required this.title,
      this.url,
      required this.description,
      required this.image,
      required this.imageUrl,
      required this.createdAtText,
      this.is_disabled});

  factory Banners.fromJson(Map<String, dynamic> json) {
    return Banners(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      description: json['description'],
      image: json['image'],
      imageUrl: json['image_url'],
      createdAtText: json['created_at_text'],
      is_disabled: json['is_disabled'],
    );
  }
}
