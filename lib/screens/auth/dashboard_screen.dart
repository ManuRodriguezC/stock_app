import 'package:flutter/material.dart';
import 'package:stock_app/repositories/product_repository.dart';
import 'package:stock_app/screens/main_shell_screen.dart';
import 'package:stock_app/services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  final AuthService authService;
  final ProductRepository productRepository;

  const DashboardScreen({
    super.key,
    required this.authService,
    required this.productRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MainShellScreen(
      authService: authService,
      productRepository: productRepository,
    );
  }
}
