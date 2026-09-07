import 'package:flutter/material.dart';
import 'package:stock_app/core/theme/app_colors.dart';
import 'package:stock_app/models/product.dart';
import 'package:stock_app/screens/products/widgets/product_card.dart';
import 'package:stock_app/widgets/app_bottom_nav_bar.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // Pestaña seleccionada: 0 = Todos, 1 = Bajo stock, 2 = Sin stock
  int _selectedTabIndex = 0;
  
  // Controlador para el campo de búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Array quemado de productos simulando datos iniciales (idéntico al mockup)
  final List<Product> _mockProducts = [
    Product(
      id: '1',
      name: 'Coca Cola 350ml',
      barcode: '7501234567890',
      category: 'Bebidas',
      unitPrice: 3500.0,
      stock: 27,
      minimumStock: 10,
      imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=150&auto=format&fit=crop&q=80',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '2',
      name: 'Agua Mineral 500ml',
      barcode: '7501234567891',
      category: 'Bebidas',
      unitPrice: 2000.0,
      stock: 13,
      minimumStock: 10,
      imageUrl: 'https://images.unsplash.com/photo-1548839140-29a749e1bc4e?w=150&auto=format&fit=crop&q=80',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '3',
      name: 'Papas Lays 160g',
      barcode: '7501234567892',
      category: 'Snacks',
      unitPrice: 4500.0,
      stock: 5, // Bajo stock
      minimumStock: 10,
      imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=150&auto=format&fit=crop&q=80',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '4',
      name: 'Teclado HP K120',
      barcode: '7501234567893',
      category: 'Electrónica',
      unitPrice: 45000.0,
      stock: 22,
      minimumStock: 5,
      imageUrl: 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=150&auto=format&fit=crop&q=80',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '5',
      name: 'Mouse Logitech M185',
      barcode: '7501234567894',
      category: 'Electrónica',
      unitPrice: 38000.0,
      stock: 3, // Bajo stock
      minimumStock: 5,
      imageUrl: 'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=150&auto=format&fit=crop&q=80',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '6',
      name: 'Monitor Samsung 24"',
      barcode: '7501234567895',
      category: 'Electrónica',
      unitPrice: 520000.0,
      stock: 7,
      minimumStock: 3,
      imageUrl: 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=150&auto=format&fit=crop&q=80',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtrado reactivo en memoria para búsqueda y pestañas
  List<Product> get _filteredProducts {
    return _mockProducts.where((product) {
      // Filtro por pestaña
      if (_selectedTabIndex == 1 && product.stock > product.minimumStock) {
        return false;
      }
      if (_selectedTabIndex == 2 && product.stock > 0) {
        return false;
      }

      // Filtro por búsqueda de texto
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = product.name.toLowerCase().contains(query);
        final matchBarcode = (product.barcode ?? '').toLowerCase().contains(query);
        final matchCategory = (product.category ?? '').toLowerCase().contains(query);
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
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
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
                  _buildAddButton(),
                ],
              ),
            ),

            // 2. Barra de Búsqueda y Botón Filtro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Buscar productos, código o categoría...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13.5,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Botón de filtros avanzados
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        // Modal visual futuro de filtros
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 3. Pestañas de estado (Todos, Bajo stock, Sin stock)
            _buildTabsRow(),

            const SizedBox(height: 10),

            // 4. Lista de Productos o Estado Vacío
            Expanded(
              child: products.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            // Navegación futura al detalle (T18)
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // 5. Barra de navegación inferior estandarizada
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1, // 'Productos' activo
        onTap: (index) {
          // Navegación global futura (T20)
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            // Acción de crear producto (T10)
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

  Widget _buildTabsRow() {
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
          _buildTabItem(title: 'Todos (152)', index: 0),
          const SizedBox(width: 24),
          _buildTabItem(title: 'Bajo stock (8)', index: 1),
          const SizedBox(width: 24),
          _buildTabItem(title: 'Sin stock (3)', index: 2),
        ],
      ),
    );
  }

  Widget _buildTabItem({required String title, required int index}) {
    final bool isSelected = _selectedTabIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
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

  Widget _buildEmptyState() {
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
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No se encontraron productos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Prueba ajustando el término de búsqueda o cambiando el filtro seleccionado.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
