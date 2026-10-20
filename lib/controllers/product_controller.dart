import 'package:flutter/material.dart';
import 'package:stock_app/models/product.dart';

class ProductController extends ChangeNotifier {
  // --- Estado ---
  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _products = [];

  // --- Filtros ---
  String _searchQuery = '';
  int _selectedTabIndex = 0; // 0 = Todos, 1 = Bajo stock, 2 = Sin stock

  // --- Getters ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get selectedTabIndex => _selectedTabIndex;

  // Getter para productos ya filtrados
  List<Product> get filteredProducts {
    return _products.where((product) {
      // 1. Filtro por pestaña
      if (_selectedTabIndex == 1 && product.stock > product.minimumStock) {
        return false;
      }
      if (_selectedTabIndex == 2 && product.stock > 0) {
        return false;
      }

      // 2. Filtro por búsqueda de texto
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

  // Contadores para las pestañas
  int get totalProductsCount => _products.length;
  int get lowStockCount =>
      _products.where((p) => p.stock > 0 && p.stock <= p.minimumStock).length;
  int get outOfStockCount => _products.where((p) => p.stock == 0).length;

  // --- Métodos públicos ---

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Reemplazar con llamada real al ProductService / ProductRepository cuando T08 esté lista.
      // await Future.delayed(const Duration(seconds: 2)); // Simular retraso de red

      // Simulando una posible falla (puedes descomentar para probar)
      // if (DateTime.now().second % 2 == 0) {
      //   throw Exception('Error simulado al cargar los productos');
      // }

      // Cargando datos falsos temporalmente
      await Future.delayed(const Duration(milliseconds: 1500));
      _products = _getMockProducts();
    } catch (e) {
      _errorMessage =
          'Ocurrió un error al cargar los productos. Por favor, intenta de nuevo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void setSelectedTab(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  // Datos de prueba estáticos movidos desde la vista
  List<Product> _getMockProducts() {
    return [
      Product(
        id: '1',
        name: 'Coca Cola 350ml',
        barcode: '7501234567890',
        category: 'Bebidas',
        unitPrice: 3500.0,
        stock: 27,
        minimumStock: 10,
        imageUrl:
            'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=150&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1548839140-29a749e1bc4e?w=150&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=150&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=150&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=150&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=150&auto=format&fit=crop&q=80',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '7',
        name: 'Cable HDMI 2m',
        barcode: '7501234567896',
        category: 'Accesorios',
        unitPrice: 15000.0,
        stock: 0, // Sin stock
        minimumStock: 10,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
