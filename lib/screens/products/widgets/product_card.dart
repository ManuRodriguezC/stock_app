import 'package:flutter/material.dart';
import 'package:stock_app/core/theme/app_colors.dart';
import 'package:stock_app/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  Color _getCategoryColor(String? category) {
    if (category == null) return AppColors.categoryGeneral;
    switch (category.toLowerCase().trim()) {
      case 'bebidas':
        return AppColors.categoryBebidas;
      case 'snacks':
        return AppColors.categorySnacks;
      case 'electrónica':
      case 'electronica':
        return AppColors.categoryElectronica;
      default:
        return AppColors.categoryGeneral;
    }
  }

  Widget _buildThumbnail() {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          product.imageUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            );
          },
        ),
      );
    }
    return _buildFallbackThumbnail();
  }

  Widget _buildFallbackThumbnail() {
    // Iconos de apoyo según la categoría o nombre para lucir idéntico al mockup
    IconData iconData = Icons.inventory_2_outlined;
    Color iconColor = AppColors.textSecondary;

    final lowerName = product.name.toLowerCase();
    if (lowerName.contains('coca') || lowerName.contains('soda')) {
      iconData = Icons.local_drink_rounded;
      iconColor = AppColors.categoryBebidas;
    } else if (lowerName.contains('agua')) {
      iconData = Icons.water_drop_rounded;
      iconColor = const Color(0xFF0284C7);
    } else if (lowerName.contains('papas') || lowerName.contains('snack')) {
      iconData = Icons.fastfood_rounded;
      iconColor = AppColors.categorySnacks;
    } else if (lowerName.contains('teclado')) {
      iconData = Icons.keyboard_rounded;
      iconColor = AppColors.textPrimary;
    } else if (lowerName.contains('mouse')) {
      iconData = Icons.mouse_rounded;
      iconColor = AppColors.textPrimary;
    } else if (lowerName.contains('monitor')) {
      iconData = Icons.desktop_windows_rounded;
      iconColor = AppColors.categoryElectronica;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Alerta de bajo stock: rojo si stock <= stock mínimo configurado
    final bool isLowStock = product.stock <= product.minimumStock;
    final categoryColor = _getCategoryColor(product.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // 1. Imagen / Miniatura
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildThumbnail(),
                ),

                const SizedBox(width: 14),

                // 2. Información del Producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nombre
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Código de barras
                      Text(
                        product.barcode ?? 'Sin código',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Categoría con punto de color
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: categoryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            product.category ?? 'General',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Stock y Chevron
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Stock',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${product.stock}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isLowStock ? AppColors.stockLow : AppColors.stockNormal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
