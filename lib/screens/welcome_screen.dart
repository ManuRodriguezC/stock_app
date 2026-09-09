import 'package:flutter/material.dart';
import 'package:stock_app/services/auth_service.dart';
import 'login/login_form.dart';

class WelcomePage extends StatelessWidget {
  final AuthService authService;

  const WelcomePage({
    super.key,
    required this.authService
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 234, 248),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: "Stock",
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      TextSpan(
                        text: "Pro",
                        style: TextStyle(
                          color: Color.fromARGB(255, 11, 49, 155),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "controla hoy el inventario de tu negocio",
                  style: TextStyle(
                    fontSize: 25,
                    color: Color.fromARGB(255, 98, 98, 98),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Image.asset('assets/hero.gif'),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(authService: authService),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 11, 49, 155),
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 100,
                    ),
                  ),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 11, 49, 155),
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 100,
                    ),
                  ),
                  child: const Text(
                    'Registrar',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
