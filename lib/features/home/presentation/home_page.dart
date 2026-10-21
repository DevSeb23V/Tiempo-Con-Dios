import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/database/devocional_repository.dart';
import '../../../core/utils/date_utils.dart';
import 'widgets/devocional_action_card.dart';
import 'widgets/growth_flame_painter.dart';
import 'widgets/weekly_days_row.dart';

/// Provider que determina el estado de la Llama (Viva vs Reposo) según la Regla de la Gracia.
final estadoLlamaVivaProvider = FutureProvider<bool>((ref) async {
  // Se invalida cuando cambian los días acumulados
  ref.watch(diasAcumuladosStreamProvider);
  final repo = ref.watch(devocionalRepositoryProvider);
  final ultimoRegistro = await repo.obtenerUltimoRegistro();

  if (ultimoRegistro == null) {
    // Si no tiene registros previos, arranca en reposo acogedor
    return false;
  }

  // Viva si hubo registro en las últimas 36 horas
  return AppDateUtils.isWithinLastHours(ultimoRegistro, 36);
});

/// Pantalla principal: Inicio
/// Conecta la cabecera, la tarjeta de acción devocional reactiva,
/// la fila semanal y la Llama de Crecimiento con la base de datos Drift.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(configuracionStreamProvider);
    final diasAcumuladosAsync = ref.watch(diasAcumuladosStreamProvider);
    final isVivaAsync = ref.watch(estadoLlamaVivaProvider);

    // Redirección guiada a Onboarding si el usuario aún no lo ha completado
    configAsync.whenData((config) {
      if (!config.onboardingCompletado) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/onboarding');
          }
        });
      }
    });

    final nombreUsuario = configAsync.maybeWhen(
      data: (config) => config.nombreUsuario,
      orElse: () => 'Sebastian',
    );

    final diasTotales = diasAcumuladosAsync.maybeWhen(
      data: (dias) => dias,
      orElse: () => 0,
    );

    final isViva = isVivaAsync.maybeWhen(
      data: (viva) => viva,
      orElse: () => true,
    );

    final nivel = GrowthFlameWidget.getLevel(diasTotales);
    String nivelDescripcion;
    switch (nivel) {
      case FlameLevel.nivel1:
        nivelDescripcion = 'Nivel 1 (1–7 días): Brasa sobre plato sencillo';
        break;
      case FlameLevel.nivel2:
        nivelDescripcion = 'Nivel 2 (8–30 días): Fuego sobre base de bronce';
        break;
      case FlameLevel.nivel3:
        nivelDescripcion = 'Nivel 3 (31–90 días): Candelabro de tres llamas';
        break;
      case FlameLevel.nivel4:
        nivelDescripcion = 'Nivel 4 (91+ días): Altar devocional completo';
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabecera con degradado naranja cálido
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 54, left: 24, right: 24, bottom: 20),
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tiempo con Dios',
                            style: AppTypography.caption(
                              color: AppColors.textPrimary.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hola, $nombreUsuario',
                            style: AppTypography.titleLarge(),
                          ),
                        ],
                      ),
                      // Botón circular de Ajustes del Devocional
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.push('/ajustes'),
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tarjeta blanca interactiva con botón de inicio / fin
                  const DevocionalActionCard(),
                ],
              ),
            ),

            // Sección de días de la semana reactiva
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: AppColors.orangePrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Mis días de tiempo con Dios',
                        style: AppTypography.bodyMediumBold(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Fila L M M J V S D conectada a Drift
                  const WeeklyDaysRow(),
                ],
              ),
            ),

            // Llama de crecimiento vectorial animada (CustomPainter)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Etiqueta de estado y nivel con la Regla de la Gracia
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                nivelDescripcion,
                                style: AppTypography.caption(
                                  color: AppColors.textPrimary,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isViva
                                    ? AppColors.orangePrimary.withValues(alpha: 0.15)
                                    : AppColors.textMuted.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isViva ? 'Fuego Vivo' : 'En reposo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isViva ? AppColors.orangeDark : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Pintor de la llama animada
                      GrowthFlameWidget(
                        diasAcumulados: diasTotales,
                        isViva: isViva,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

