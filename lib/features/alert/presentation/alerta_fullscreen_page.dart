import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/database/devocional_repository.dart';
import '../../../core/notifications/notification_service.dart';
import '../../home/presentation/widgets/black_screen_dialog.dart';

/// Pantalla Alerta a Pantalla Completa (Full Screen Intent).
/// Se levanta sobre la pantalla de bloqueo en el horario pactado para el devocional.
/// Diseño limpio, sereno y sin alarmas estridentes.
class AlertaFullScreenPage extends ConsumerWidget {
  const AlertaFullScreenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    final dateStr = DateFormat("EEEE, d 'de' MMMM", 'es').format(now);
    final capitalizedDate = dateStr[0].toUpperCase() + dateStr.substring(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Hora en gran tamaño con tipografía Lora
              Text(
                timeStr,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 64,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                capitalizedDate,
                style: AppTypography.caption(color: AppColors.steelBlue).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 36),

              // Ícono ilustrativo en círculo dorado suave
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.gold,
                  size: 44,
                ),
              ),
              const SizedBox(height: 36),

              // Título y Mensaje de intimidad
              Text(
                'Es momento de tu\ntiempo con Dios',
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge().copyWith(
                  height: 1.25,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Deja a un lado las prisas del mundo.\nTu Padre te espera en lo secreto.',
                textAlign: TextAlign.center,
                style: AppTypography.subtitle().copyWith(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 3),

              // Botón 1: "Empezaré mi tiempo" (Acción principal)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    // 1. Guardar timestamp en Drift
                    final repo = ref.read(devocionalRepositoryProvider);
                    await repo.guardarInicioSesion();

                    // 2. Cancelar posposición si existía
                    final notif = ref.read(notificationServiceProvider);
                    await notif.cancelarPosposicion();

                    if (context.mounted) {
                      // 3. Mostrar pantalla negra OLED de 3 segundos
                      await BlackScreenDialog.show(context);

                      if (context.mounted) {
                        // 4. Volver a la pantalla principal
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          context.go('/');
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.steelBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Empezaré mi tiempo',
                    style: AppTypography.buttonText(),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Botón 2: "Posponer 10 min" (Acción secundaria)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () async {
                    final notif = ref.read(notificationServiceProvider);
                    await notif.posponerDevocional10Min();

                    if (context.mounted) {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.go('/');
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Alarma pospuesta por 10 minutos.',
                            style: AppTypography.bodyMedium(color: Colors.white),
                          ),
                          backgroundColor: AppColors.steelBlue,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.textPrimary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Posponer 10 min',
                    style: AppTypography.bodyMediumBold(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
