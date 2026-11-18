import 'package:flutter/material.dart';
import 'package:stock_app/core/theme/app_colors.dart';
import 'package:stock_app/models/product.dart';
import 'package:stock_app/repositories/product_repository.dart';
import 'package:stock_app/screens/products/widgets/product_card.dart';
import 'package:stock_app/screens/products/widgets/product_list_empty.dart';
import 'package:stock_app/screens/products/widgets/product_search_bar.dart';
import 'package:stock_app/screens/products/widgets/product_tabs.dart';
import 'package:stock_app/widgets/app_bottom_nav_bar.dart';
import 'package:stock_app/widgets/button_add_product.dart';

class ProductsScreen extends StatefulWidget {
  final ProductRepository productRepository;

  const ProductsScreen({super.key, required this.productRepository});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _selectedTabIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Product> _products = [];
  List<Product> _allproducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await widget.productRepository.getProducts();

      if (!mounted) return;
      setState(() {
        _products = products;
        _allproducts = products;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'No fue posible cargar los productos.';
      });

      debugPrint('Error cargando productos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Product> get _filteredProducts {
    return _products.where((product) {
      if (_selectedTabIndex == 1 &&
          !(product.stock > 0 && product.stock <= product.minimumStock)) {
        return false;
      }
      if (_selectedTabIndex == 2 && product.stock != 0) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = product.name.toLowerCase().contains(query);
        final matchBarcode =
            (product.barcode ?? '').toLowerCase().contains(query);
        final matchCategory =
            (product.category ?? '').toLowerCase().contains(query);
        return matchName || matchBarcode || matchCategory;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 16, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Productos',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  ButtonAddProduct(
                      productRepository: widget.productRepository,
                      products: _allproducts,
                      onProductCreated: _loadProducts),
                ],
              ),
            ),

            ProductSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onFilterPressed: () {
              },
            ),

            const SizedBox(height: 8),

            ProductTabs(
                products: _allproducts,
                selectedTabIndex: _selectedTabIndex,
                onTabChanged: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                }),

            const SizedBox(height: 10),

            Expanded(
              child: products.isEmpty
                  ? ProductListEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          productRepository: widget.productRepository,
                          onTap: () {
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1, 
        onTap: (index) {
        },
      ),
    );
  }
}
