import 'package:flutter/material.dart';
import 'package:stock_app/screens/dashboard/dashboard_home_screen.dart';
import 'package:stock_app/screens/products/products_screen.dart';
import 'package:stock_app/screens/products/add_product_screen.dart';
import 'package:stock_app/screens/movements/movements_screen.dart';
import 'package:stock_app/widgets/app_bottom_nav_bar.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
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
        onNavigateTab: (index) => _onTabTapped(index),
      ),
      ProductsScreen(
        showBottomBar: false,
        onNavigateTab: (index) => _onTabTapped(index),
      ),
      const AddProductScreen(),
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
