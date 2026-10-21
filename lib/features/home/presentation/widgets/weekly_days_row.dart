import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/devocional_repository.dart';
import '../../../../core/utils/date_utils.dart';

/// Fila semanal reactiva (Lunes a Domingo) que muestra el progreso de la semana en curso.
class WeeklyDaysRow extends ConsumerWidget {
  const WeeklyDaysRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    // Calculamos el lunes de la semana actual (1 = Lunes en Dart)
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    // Observamos las sesiones del mes actual
    final sesionesAsync = ref.watch(
      sesionesMesStreamProvider((anio: now.year, mes: now.month)),
    );

    final completedDates = sesionesAsync.when(
      data: (sesiones) => sesiones.map((s) => s.fecha).toSet(),
      loading: () => <String>{},
      error: (_, __) => <String>{},
    );

    const dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = weekDays[index];
        final dateYmd = AppDateUtils.toYmd(date);
        final isCompleted = completedDates.contains(dateYmd);
        final isToday = AppDateUtils.isToday(date);

        return _WeeklyDayCircle(
          dayLetter: dayLabels[index],
          dayNumber: date.day.toString(),
          isCompleted: isCompleted,
          isToday: isToday,
        );
      }),
    );
  }
}

class _WeeklyDayCircle extends StatelessWidget {
  final String dayLetter;
  final String dayNumber;
  final bool isCompleted;
  final bool isToday;

  const _WeeklyDayCircle({
    required this.dayLetter,
    required this.dayNumber,
    required this.isCompleted,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          dayLetter,
          style: AppTypography.caption(
            color: isToday ? AppColors.textPrimary : AppColors.textSecondary,
          ).copyWith(
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.orangePrimary
                : (isToday ? Colors.white : AppColors.cardWhite),
            border: Border.all(
              color: isToday
                  ? AppColors.gold
                  : (isCompleted
                      ? AppColors.orangePrimary
                      : AppColors.textMuted.withValues(alpha: 0.3)),
              width: isToday ? 2.5 : 1,
            ),
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : Text(
                    dayNumber,
                    style: AppTypography.caption(
                      color: isToday ? AppColors.textPrimary : AppColors.textSecondary,
                    ).copyWith(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
