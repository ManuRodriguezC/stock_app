import 'package:flutter/material.dart';
import 'package:stock_app/core/theme/app_colors.dart';
import 'package:stock_app/models/product.dart';
import 'package:stock_app/repositories/product_repository.dart';
import 'package:stock_app/screens/products/product_form_screen.dart';

class ButtonAddProduct extends StatelessWidget {
  final ProductRepository productRepository;
  final List<Product> products;
  final Future<void> Function() onProductCreated;

  const ButtonAddProduct({super.key, required this.productRepository, required this.products, required this.onProductCreated});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            final productoCreado = await Navigator.push<Product>(
              context,
              MaterialPageRoute(
                builder: (_) => ProductFormScreen(
                  existingBarcodes: products
                      .map((product) => product.barcode ?? '')
                      .toList(),
                  productRepository: productRepository,
                ),
              ),
            );

            if (productoCreado != null) {
              await onProductCreated();
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  'Agregar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
