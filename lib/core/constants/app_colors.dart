import 'package:flutter/material.dart';

/// Paleta de colores oficial de la app "Tiempo con Dios".
/// Basada estrictamente en el diseño minimalista y cálido.
class AppColors {
  AppColors._();

  /// Fondo crema general de la aplicación (#F7F3EA)
  static const Color background = Color(0xFFF7F3EA);

  /// Blanco puro para tarjetas redondeadas
  static const Color cardWhite = Color(0xFFFFFFFF);

  /// Azul acero para métricas de progreso, píldoras del calendario y botones secundarios (#5B7F9E)
  static const Color steelBlue = Color(0xFF5B7F9E);

  /// Azul acero oscuro para efectos hover o bordes activos
  static const Color steelBlueDark = Color(0xFF4A6B88);

  /// Dorado para destacar "Hoy", bordes activos y detalles sutiles (#E8B93C)
  static const Color gold = Color(0xFFE8B93C);

  /// Dorado oscuro para contrastes en iconos
  static const Color goldDark = Color(0xFFC79A2B);

  /// Naranja de llama viva
  static const Color flameOrange = Color(0xFFE9915A);

  /// Color de fondo para las tarjetas de actividad en forma de nube (#E3EAF4)
  static const Color cloudBlue = Color(0xFFE3EAF4);

  /// Naranja cálido primario para la cabecera y la llama (#E9915A)
  static const Color orangePrimary = Color(0xFFE9915A);

  /// Naranja suave para el fin del degradado (#F4B77A)
  static const Color orangeLight = Color(0xFFF4B77A);

  /// Naranja oscuro para sombras suaves de fuego
  static const Color orangeDark = Color(0xFFD67338);

  /// Texto principal oscuro cálido (serif y sans)
  static const Color textPrimary = Color(0xFF2C241D);

  /// Texto secundario tenue para subtítulos y ayudas
  static const Color textSecondary = Color(0xFF7A7067);

  /// Texto atenuado para leyendas o notas
  static const Color textMuted = Color(0xFFA59D94);

  /// Negro absoluto para la pantalla OLED de reposo (3 segundos)
  static const Color oledBlack = Color(0xFF000000);

  /// Texto tenue para la pantalla OLED
  static const Color oledText = Color(0xFF9E9E9E);

  /// Degradado de la cabecera de la pantalla de Inicio
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE9915A),
      Color(0xFFF4B77A),
      Color(0xFFF7F3EA),
    ],
    stops: [0.0, 0.65, 1.0],
  );

  /// Degradado para el botón principal de acción devocional
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFE9915A),
      Color(0xFFF0A36B),
    ],
  );
}
