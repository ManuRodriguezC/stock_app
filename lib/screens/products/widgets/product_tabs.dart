import 'package:flutter/material.dart';
import 'package:stock_app/core/theme/app_colors.dart';
import 'package:stock_app/models/product.dart';

class ProductTabs extends StatelessWidget {
  final List<Product> products;
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;

  const ProductTabs({
    super.key,
    required this.products,
    required this.selectedTabIndex,
    required this.onTabChanged,
  });

  int get _totalProducts {
    return products.length;
  }

  int get _lowStockProducts {
    return products
        .where(
          (product) =>
              product.stock > 0 && product.stock <= product.minimumStock,
        )
        .length;
  }

  int get _outOfStockProducts {
    return products.where((product) => product.stock == 0).length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTabItem(title: 'Todos ($_totalProducts)', index: 0),
          const SizedBox(width: 24),
          _buildTabItem(title: 'Bajo stock ($_lowStockProducts)', index: 1),
          const SizedBox(width: 24),
          _buildTabItem(title: 'Sin stock ($_outOfStockProducts)', index: 2),
        ],
      ),
    );
  }

  Widget _buildTabItem({required String title, required int index}) {
    final bool isSelected = selectedTabIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTabChanged(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
          // Barra indicadora activa inferior
          Container(
            height: 2.5,
            width: isSelected ? 80 : 0,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
