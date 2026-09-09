import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stock_app/screens/auth/dashboard_screen.dart';
import 'package:stock_app/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:stock_app/services/auth_service.dart';

class AuthGate extends StatefulWidget {
  final AuthService authService;

  const AuthGate({
    super.key,
    required this.authService,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSubscription;

  Session? _session;

  @override
  void initState() {
    super.initState();

    // Revisamos si ya existe una sesión al abrir la aplicación.
    _session = widget.authService.currentSession;

    // Escuchamos cambios en el estado de autenticación.
    _authSubscription = widget.authService.authStateChanges.listen((data) {
      if (!mounted) return;

      setState(() {
        _session = data.session;
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session != null) {
      return DashboardScreen(authService: widget.authService);
    }
    return WelcomePage(authService: widget.authService);
  }
}
