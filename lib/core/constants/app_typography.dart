import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tipografía oficial del proyecto "Tiempo con Dios".
/// Títulos en Serif (Lora) y cuerpo de texto en Sans-serif (Inter).
class AppTypography {
  AppTypography._();

  /// Título grande serif para cabeceras y tarjetas principales (ej: "Tiempo con Dios de hoy")
  static TextStyle titleLarge({
    Color color = AppColors.textPrimary,
    double fontSize = 26,
    FontWeight fontWeight = FontWeight.w600,
    double height = 1.25,
    double letterSpacing = -0.3,
  }) {
    return GoogleFonts.lora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Título mediano serif para nombres de secciones (ej: "Mi Progreso", "Guía de hoy")
  static TextStyle titleMedium({
    Color color = AppColors.textPrimary,
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w600,
    double height = 1.3,
  }) {
    return GoogleFonts.lora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Título pequeño para encabezados de tarjetas
  static TextStyle titleSmall({
    Color color = AppColors.textPrimary,
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.lora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Subtítulos y lemas poéticos/reflexivos (ej: "Pequeños pasos, un hábito que crece.")
  static TextStyle subtitle({
    Color color = AppColors.textSecondary,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.4,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Texto de cuerpo normal sans-serif
  static TextStyle body({
    Color color = AppColors.textPrimary,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.5,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Texto de cuerpo normal sans-serif
  static TextStyle bodyMedium({
    Color color = AppColors.textPrimary,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.5,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Texto de cuerpo destacado sans-serif
  static TextStyle bodyMediumBold({
    Color color = AppColors.textPrimary,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Texto pequeño para leyendas, días de la semana y contadores
  static TextStyle caption({
    Color color = AppColors.textSecondary,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Texto para números grandes de métricas (ej: [X], [180])
  static TextStyle metricNumber({
    Color color = AppColors.textPrimary,
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return GoogleFonts.lora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Texto en botones de acción principales
  static TextStyle buttonText({
    Color color = Colors.white,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 0.2,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
