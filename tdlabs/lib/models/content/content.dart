class Content {
  final int id;
  final String? title;
  final String? description;
  final String? image;
  final String? imageUrl;
  final String? createdAtText;
  final String? url;

  Content({
    required this.id,
    this.title,
    this.description,
    this.image,
    this.imageUrl,
    this.createdAtText,
    this.url,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      imageUrl: json['image_url'],
      createdAtText: json['created_at_text'],
      url: json['url'],
    );
  }
}
