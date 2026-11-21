import 'package:flutter/material.dart';
import 'package:stock_app/repositories/product_repository.dart';
import 'package:stock_app/screens/dashboard/dashboard_home_screen.dart';
import 'package:stock_app/screens/products/products_screen.dart';
import 'package:stock_app/screens/products/product_form_screen.dart';
import 'package:stock_app/screens/products/add_product_screen.dart';
import 'package:stock_app/screens/movements/movements_screen.dart';
import 'package:stock_app/services/auth_service.dart';
import 'package:stock_app/widgets/app_bottom_nav_bar.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;
  final AuthService? authService;
  final ProductRepository? productRepository;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
    this.authService,
    this.productRepository,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardHomeScreen(
        authService: widget.authService,
        productRepository: widget.productRepository,
        onNavigateTab: (index) => _onTabTapped(index),
      ),
      ProductsScreen(
        productRepository: widget.productRepository,
        showBottomBar: false,
        onNavigateTab: (index) => _onTabTapped(index),
      ),
      widget.productRepository != null
          ? ProductFormScreen(productRepository: widget.productRepository!)
          : const AddProductScreen(),
      const MovementsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
