import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:stock_app/core/theme/app_theme.dart';
import 'package:stock_app/services/auth_service.dart';
import 'package:stock_app/screens/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final rawUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final rawKey = dotenv.env['SUPABASE_KEY'] ?? '';

  // Si .env contiene los asteriscos del template o una URL inválida, usamos un fallback para pruebas locales
  final supabaseUrl = rawUrl.startsWith('http') ? rawUrl : 'https://mock.supabase.co';
  final supabaseKey = (rawKey != '*******' && rawKey.isNotEmpty) ? rawKey : 'mock-anon-key';

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseKey,
  );

  final supabase = Supabase.instance.client;
  final authService = AuthService(supabase);

  runApp(
    MainApp(
      authService: authService,
    ),
  );
}

class MainApp extends StatelessWidget {
  final AuthService authService;

  const MainApp({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AuthGate(
        authService: authService,
      ),
    );
  }
}
