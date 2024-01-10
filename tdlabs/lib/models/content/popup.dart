// ignore_for_file: non_constant_identifier_names

class Popup {
  String? title;
  String? description;
  String? url;
  String? image_url;

  Popup({
    this.title,
    this.description,
    this.url,
    this.image_url,
  });

  factory Popup.fromJson(Map<String, dynamic> json) {
    return Popup(
      title: (json['title'] != null) ? json['title'] : null,
      description: json['description'],
      url: json['url'],
      image_url: json['image_url'],
    );
  }
}
