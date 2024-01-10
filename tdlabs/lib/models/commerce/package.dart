class Package {
  final int id;
  final String? name;
  final String? description;
  final String? imageUrl;

  Package({
    required this.id,
    this.name,
    this.description,
    this.imageUrl,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }
}
