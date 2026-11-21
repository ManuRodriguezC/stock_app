import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../services/image_storage_service.dart';

class ProductRepository {
  final SupabaseClient _supabase;

  /// Servicio de imágenes. Se crea aquí para no tener que pasarlo por todas
  /// las pantallas: el repositorio ya llega hasta el formulario y la tarjeta.
  final ImageStorageService imageStorage;

  ProductRepository(SupabaseClient supabase)
      : _supabase = supabase,
        imageStorage = ImageStorageService(supabase);

  Future<Product> createProduct(Product product) async {
    final response = await _supabase
        .from('products')
        .insert(product.toInsertMap())
        .select()
        .single();

    return Product.fromMap(response);
  }

  Future<Product> updateProduct(Product product) async {
    final response = await _supabase
        .from('products')
        .update({
          'barcode': product.barcode,
          'name': product.name,
          'description': product.description,
          'category': product.category,
          'unit_price': product.unitPrice,
          'stock': product.stock,
          'minimum_stock': product.minimumStock,
          'image_url': product.imageUrl,
          'is_active': product.isActive,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', product.id)
        .select()
        .single();

    return Product.fromMap(response);
  }

  Future<List<Product>> getProducts() async {
    final response = await _supabase.from('products').select();

    return response.map<Product>((item) => Product.fromMap(item)).toList();
  }

  // ===========================================================================
  // IMÁGENES (bucket privado de Supabase Storage)
  // ===========================================================================

  /// Abre cámara o galería y devuelve la imagen elegida (null si cancela).
  Future<XFile?> pickProductImage(ImageSource source) {
    return imageStorage.pickImage(source);
  }

  /// Sube la foto y devuelve la ruta que se guarda en products.image_url.
  Future<String> uploadProductImage(XFile image, String userId) {
    return imageStorage.uploadProductImage(image, userId: userId);
  }

  String getProductImageUrl(String path) {
    return imageStorage.getPublicUrl(path);
  }

  /// Borra la foto del bucket.
  Future<void> deleteProductImage(String path) {
    return imageStorage.deleteProductImage(path);
  }
}
