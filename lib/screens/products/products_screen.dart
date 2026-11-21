import 'package:flutter/material.dart';
import 'package:stock_app/core/theme/app_colors.dart';
import 'package:stock_app/controllers/product_controller.dart';
import 'package:stock_app/models/product.dart';
import 'package:stock_app/repositories/product_repository.dart';
import 'package:stock_app/screens/products/widgets/product_card.dart';
import 'package:stock_app/screens/products/widgets/product_list_empty.dart';
import 'package:stock_app/screens/products/widgets/product_search_bar.dart';
import 'package:stock_app/screens/products/widgets/product_tabs.dart';
import 'package:stock_app/screens/products/add_product_screen.dart';
import 'package:stock_app/screens/products/product_form_screen.dart';
import 'package:stock_app/widgets/app_bottom_nav_bar.dart';
import 'package:stock_app/widgets/button_add_product.dart';

class ProductsScreen extends StatefulWidget {
  final ProductRepository? productRepository;
  final ValueChanged<int>? onNavigateTab;
  final bool showBottomBar;

  const ProductsScreen({
    super.key,
    this.productRepository,
    this.onNavigateTab,
    this.showBottomBar = true,
  });

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
  final ProductController _fallbackController = ProductController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadProducts();
      }
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
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
      List<Product> products;
      if (widget.productRepository != null) {
        products = await widget.productRepository!.getProducts();
      } else {
        await _fallbackController.fetchProducts();
        products = _fallbackController.allProducts;
      }

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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
            // 1. Encabezado superior (Título y botón + Agregar)
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
                  if (widget.productRepository != null)
                    ButtonAddProduct(
                      productRepository: widget.productRepository!,
                      products: _allproducts,
                      onProductCreated: _loadProducts,
                    )
                  else
                    _buildFallbackAddButton(),
                ],
              ),
            ),

            // 2. Barra de Búsqueda
            ProductSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onFilterPressed: () {},
            ),

            const SizedBox(height: 8),

            // 3. Pestañas de estado (Todos, Bajo stock, Sin stock)
            ProductTabs(
              products: _allproducts,
              selectedTabIndex: _selectedTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),

            const SizedBox(height: 10),

            // 4. Lista de Productos o Estados
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _errorMessage != null
                      ? _buildErrorState()
                      : products.isEmpty
                          ? const ProductListEmpty()
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 4, bottom: 16),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return ProductCard(
                                  product: product,
                                  productRepository: widget.productRepository,
                                  onTap: () {},
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomBar
          ? AppBottomNavBar(
              currentIndex: 1,
              onTap: (index) {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(index);
                } else if (index == 2) {
                  if (widget.productRepository != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductFormScreen(
                          productRepository: widget.productRepository!,
                          existingBarcodes: _allproducts
                              .map((p) => p.barcode ?? '')
                              .toList(),
                        ),
                      ),
                    ).then((created) {
                      if (created != null) _loadProducts();
                    });
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddProductScreen(),
                      ),
                    );
                  }
                }
              },
            )
          : null,
    );
  }

  Widget _buildFallbackAddButton() {
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
            final res = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            );
            if (res == true) {
              _loadProducts();
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

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '¡Ups! Algo salió mal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Error desconocido',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
