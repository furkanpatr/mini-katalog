class Product {
  final String name;
  final double price;
  final int? stock;
  final String image;
  final String description;

  const Product({
    required this.name,
    required this.price,
    this.stock,
    required this.image,
    this.description = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int?,
      image: json['image'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'image': image,
      'description': description,
    };
  }
}
