import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

class ProductRepository {
  final SupabaseClient _supabase;

  ProductRepository(this._supabase);

  Future<Product> createProduct(Product product) async {
    final response = await _supabase
        .from('products')
        .insert(product.toInsertMap())
        .select()
        .single();

    return Product.fromMap(response);
  }

  Future<List<Product>> getProducts() async {
    final response = await _supabase.from('products').select();

    return response.map<Product>((item) => Product.fromMap(item)).toList();
  }
}
