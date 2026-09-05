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
}
