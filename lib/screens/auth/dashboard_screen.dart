import 'package:flutter/material.dart';

import 'package:stock_app/screens/products/products_screen.dart';
import 'package:stock_app/services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  final AuthService authService;

  const DashboardScreen({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user?.email ?? 'Usuario',
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: const ProductsScreen(),
    );
  }
}