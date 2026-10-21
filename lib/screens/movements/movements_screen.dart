import 'package:flutter/material.dart';
import 'package:stock_app/core/theme/app_colors.dart';

class MovementsScreen extends StatelessWidget {
  const MovementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movements = [
      {
        'product': 'Coca Cola 350ml',
        'type': 'Entrada',
        'qty': '+15 uds',
        'isEntry': true,
        'date': 'Hoy, 10:30 AM',
        'notes': 'Recepción proveedor central',
      },
      {
        'product': 'Mouse Logitech M185',
        'type': 'Salida',
        'qty': '-2 uds',
        'isEntry': false,
        'date': 'Hoy, 09:15 AM',
        'notes': 'Venta mostrador #0412',
      },
      {
        'product': 'Papas Lays 160g',
        'type': 'Salida',
        'qty': '-5 uds',
        'isEntry': false,
        'date': 'Ayer, 04:45 PM',
        'notes': 'Venta mostrador #0398',
      },
      {
        'product': 'Cable HDMI 2m',
        'type': 'Salida',
        'qty': '-1 ud',
        'isEntry': false,
        'date': 'Ayer, 02:10 PM',
        'notes': 'Agotamiento de stock',
      },
      {
        'product': 'Teclado HP K120',
        'type': 'Entrada',
        'qty': '+10 uds',
        'isEntry': true,
        'date': '18 Oct, 11:00 AM',
        'notes': 'Compra mayorista lote #88',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
              child: Text(
                'Movimientos',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Registro de entradas y salidas de inventario',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: movements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final m = movements[index];
                  final isEntry = m['isEntry'] as bool;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isEntry
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isEntry
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            color: isEntry ? AppColors.success : AppColors.error,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['product'] as String,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${m['notes']} • ${m['date']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          m['qty'] as String,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isEntry ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
