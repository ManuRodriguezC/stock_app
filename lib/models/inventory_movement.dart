import 'package:stock_app/models/movement_type.dart';


class InventoryMovement {
  final String id;
  final String productId;
  final String userId;
  final MovementType type;
  final int quantity;
  final int previousStock;
  final int newStock;
  final String? notes;
  final DateTime createdAt;

  InventoryMovement({
    required this.id,
    required this.productId,
    required this.userId,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.notes,
    required this.createdAt,
  });
}
