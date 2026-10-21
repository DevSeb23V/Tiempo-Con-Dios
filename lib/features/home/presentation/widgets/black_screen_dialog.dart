import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

/// Pantalla 100% negra (#000000) AMOLED que se muestra durante 3 segundos al iniciar el devocional.
/// Respeta la imposibilidad del SO de apagar la pantalla por código y guía al usuario con calma.
class BlackScreenDialog extends StatefulWidget {
  const BlackScreenDialog({super.key});

  /// Método estático conveniente para desplegar la pantalla en reposo.
  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.oledBlack,
      barrierLabel: 'Cerrar pantalla de reposo',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) => const BlackScreenDialog(),
    );
  }

  @override
  State<BlackScreenDialog> createState() => _BlackScreenDialogState();
}

class _BlackScreenDialogState extends State<BlackScreenDialog> with SingleTickerProviderStateMixin {
  Timer? _dismissTimer;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Cierra automáticamente el diálogo tras exactamente 3 segundos
    _dismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: GestureDetector(
        onTap: () {
          // Permite cerrar si el usuario toca la pantalla antes de los 3s
          Navigator.of(context, rootNavigator: true).pop();
        },
        child: Scaffold(
          backgroundColor: AppColors.oledBlack,
          body: Center(
            child: FadeTransition(
              opacity: _fadeController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Tiempo iniciado.\nBloquea tu celular o colócalo boca abajo.\nNos vemos al terminar.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium(
                    color: AppColors.oledText,
                  ).copyWith(
                    fontSize: 16,
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
