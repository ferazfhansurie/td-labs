// ignore_for_file: non_constant_identifier_names

class Catalog {
  final int? id;
  final String? name;
  final String? description;
  final String? image_url;
  final String? price;
  final String? price_2;
  final String? shortDescription;
  String? overlay_name;
  List? images;
  bool? isDescHide;
  int? is_vm_stock;
  int? in_stock;
  int? type;
  int? stock_quantity;
  Catalog(
      {this.id,
      this.name,
      this.description,
      this.shortDescription,
      this.overlay_name,
      this.image_url,
      this.price,
      this.price_2,
      this.isDescHide = true,
      this.images,
      this.is_vm_stock,
      this.in_stock,
      this.type,
      this.stock_quantity});

  factory Catalog.fromJson(Map<String, dynamic> json) {
    return Catalog(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      shortDescription: json['short_description'],
      overlay_name: json['overlay_name'],
      image_url: (json['image_url'] != null) ? json['image_url'] : null,
      price: json['price'],
      price_2: json['price_2'],
      images: json['images'],
      is_vm_stock: json['is_vm_stock'],
      in_stock: json['in_stock'],
      type: json['type'],
      stock_quantity: json['stock_quantity'],
    );
  }
}
