class Product {
  final String id;
  final String? barcode;
  final String name;
  final String? description;
  final String? category;
  final double unitPrice;
  final int stock;
  final int minimumStock;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    this.barcode,
    required this.name,
    this.description,
    this.category,
    required this.unitPrice,
    required this.stock,
    required this.minimumStock,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      barcode: map['barcode'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      unitPrice: (map['unit_price'] as num).toDouble(),
      stock: map['stock'] as int,
      minimumStock: map['minimum_stock'] as int,
      imageUrl: map['image_url'],
      isActive: map['is_active'] as bool,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'description': description,
      'category': category,
      'unit_price': unitPrice,
      'stock': stock,
      'minimum_stock': minimumStock,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'barcode': barcode,
      'name': name,
      'description': description,
      'category': category,
      'unit_price': unitPrice,
      'stock': stock,
      'minimum_stock': minimumStock,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }
}
