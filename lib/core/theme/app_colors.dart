import 'package:flutter/material.dart';

/// Paleta de colores estandarizada para toda la aplicación.
/// Mantiene la coherencia visual entre los módulos del equipo de desarrollo.
class AppColors {
  AppColors._();

  // Fondos y superficies
  static const Color background = Color(0xFFF8FAFC); // Fondo general suave
  static const Color surface = Color(0xFFFFFFFF); // Blanco tarjetas
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Gris para fondos de imágenes
  
  // Primario y Acentos
  static const Color primaryNavy = Color(0xFF1E3A8A); // Azul marino oscuro para botones principales (+ Agregar)
  static const Color primary = Color(0xFF2563EB); // Azul brillante para tabs activas y barra de navegación
  static const Color primaryLight = Color(0xFFEFF6FF); // Azul claro para selecciones o badges

  // Textos
  static const Color textPrimary = Color(0xFF0F172A); // Texto oscuro principal
  static const Color textSecondary = Color(0xFF64748B); // Texto secundario / gris medio
  static const Color textMuted = Color(0xFF94A3B8); // Texto tenue / placeholders

  // Bordes y separadores
  static const Color border = Color(0xFFE2E8F0); // Bordes de inputs y cards
  static const Color divider = Color(0xFFEEF2F6); // Divisores sutiles

  // Categorías de productos
  static const Color categoryBebidas = Color(0xFFEF4444); // Rojo
  static const Color categorySnacks = Color(0xFFF59E0B); // Ámbar / Amarillo
  static const Color categoryElectronica = Color(0xFF3B82F6); // Azul
  static const Color categoryGeneral = Color(0xFF10B981); // Verde

  // Estados de inventario y alertas
  static const Color stockNormal = Color(0xFF0F172A); // Stock normal (oscuro)
  static const Color stockLow = Color(0xFFDC2626); // Bajo stock (rojo de alerta)
  static const Color success = Color(0xFF16A34A); // Éxito
  static const Color warning = Color(0xFFD97706); // Advertencia
}
