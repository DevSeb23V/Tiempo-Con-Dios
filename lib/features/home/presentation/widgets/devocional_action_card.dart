import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/devocional_repository.dart';
import 'package:go_router/go_router.dart';
import 'black_screen_dialog.dart';

/// Tarjeta blanca central con el botón reactivo de inicio / fin devocional.
class DevocionalActionCard extends ConsumerWidget {
  const DevocionalActionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(configuracionStreamProvider);
    final repo = ref.read(devocionalRepositoryProvider);

    return configAsync.when(
      data: (config) {
        final inicioActivo = config.sesionActivaInicio;
        final haySesionActiva = inicioActivo != null;

        // Subtítulo dinámico
        String subtitulo;
        if (haySesionActiva) {
          final horaStr = DateFormat('HH:mm').format(inicioActivo);
          subtitulo = 'Sesión en curso desde las $horaStr';
        } else {
          subtitulo = 'Próximo horario: ${config.horaDevocional}';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Tiempo con Dios\nde hoy',
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge(),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: haySesionActiva
                    ? Text(
                        subtitulo,
                        key: ValueKey(subtitulo),
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle(
                          color: AppColors.orangeDark,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Row(
                        key: ValueKey(subtitulo),
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              subtitulo,
                              textAlign: TextAlign.center,
                              style: AppTypography.subtitle(
                                color: AppColors.textSecondary,
                              ).copyWith(
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => context.push('/ajustes'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.steelBlue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.steelBlue.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: AppColors.steelBlue,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Programar horario',
                                    style: AppTypography.caption(color: AppColors.steelBlue).copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),

              // Botón de acción reactivo
              InkWell(
                onTap: () async {
                  if (!haySesionActiva) {
                    // 1. Iniciar sesión: guarda timestamp en SQLite
                    await repo.guardarInicioSesion();
                    if (context.mounted) {
                      // 2. Muestra pantalla negra 3s con mensaje tenue
                      await BlackScreenDialog.show(context);
                    }
                  } else {
                    // 3. Finalizar sesión: calcula minutos, registra en SQLite y reaviva llama
                    final minutos = await repo.finalizarSesion();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '¡Tiempo con Dios completado ($minutos min)! Tu constancia crece.',
                            style: AppTypography.bodyMedium(color: Colors.white),
                          ),
                          backgroundColor: AppColors.steelBlue,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(27),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: haySesionActiva
                        ? const LinearGradient(
                            colors: [Color(0xFFE8934A), Color(0xFFD47326)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: [
                      BoxShadow(
                        color: (haySesionActiva ? AppColors.orangeDark : AppColors.orangePrimary)
                            .withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          haySesionActiva
                              ? 'Terminar mi tiempo (Hecho)'
                              : 'Empezar mi tiempo',
                          style: AppTypography.buttonText(),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          haySesionActiva
                              ? Icons.check_circle_outline_rounded
                              : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.orangePrimary),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
