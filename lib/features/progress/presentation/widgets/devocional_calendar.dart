import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_utils.dart';

/// Calendario devocional interactivo con table_calendar.
/// Días completados con píldoras azul acero (#5B7F9E), día de hoy con borde dorado (#E8B93C)
/// y leyenda explicativa inferior.
class DevocionalCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final List<SesionDevocionalData> sesionesMes;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  const DevocionalCalendar({
    super.key,
    required this.focusedDay,
    required this.sesionesMes,
    required this.onMonthChanged,
    required this.onDaySelected,
  });

  String _formatMonthYear(DateTime date) {
    try {
      final formatter = DateFormat('MMMM yyyy', 'es');
      final formatted = formatter.format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (_) {
      return '${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mapa rápido de sesiones por 'YYYY-MM-DD'
    final Map<String, SesionDevocionalData> mapaSesiones = {
      for (final s in sesionesMes) s.fecha: s,
    };

    final hoyYmd = AppDateUtils.toYmd(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabecera: Mes Año y flechas < >
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatMonthYear(focusedDay),
                  style: AppTypography.titleSmall(),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 22),
                      color: AppColors.textPrimary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Mes anterior',
                      onPressed: () {
                        final previousMonth = DateTime(
                          focusedDay.year,
                          focusedDay.month - 1,
                          1,
                        );
                        onMonthChanged(previousMonth);
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 22),
                      color: AppColors.textPrimary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Mes siguiente',
                      onPressed: () {
                        final nextMonth = DateTime(
                          focusedDay.year,
                          focusedDay.month + 1,
                          1,
                        );
                        onMonthChanged(nextMonth);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Calendario mensual
          TableCalendar(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2035, 12, 31),
            focusedDay: focusedDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: CalendarFormat.month,
            headerVisible: false,
            daysOfWeekHeight: 28,
            rowHeight: 44,
            onPageChanged: onMonthChanged,
            onDaySelected: (selectedDay, _) {
              onDaySelected(selectedDay);
            },
            daysOfWeekStyle: const DaysOfWeekStyle(
              dowTextFormatter: _customDowTextFormatter,
              weekdayStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
              weekendStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) => _buildDayCell(day, hoyYmd, mapaSesiones),
              todayBuilder: (context, day, _) => _buildDayCell(day, hoyYmd, mapaSesiones),
              outsideBuilder: (context, day, _) => _buildOutsideDayCell(day),
            ),
          ),
          const SizedBox(height: 16),

          // Leyenda visual inferior
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.steelBlue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('Tiempo completado', style: AppTypography.caption()),
              const SizedBox(width: 20),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
              ),
              const SizedBox(width: 6),
              Text('Hoy', style: AppTypography.caption()),
            ],
          ),
        ],
      ),
    );
  }

  static String _customDowTextFormatter(DateTime date, dynamic locale) {
    // Retorna L, M, M, J, V, S, D
    const dias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return dias[date.weekday - 1];
  }

  Widget _buildDayCell(
    DateTime day,
    String hoyYmd,
    Map<String, SesionDevocionalData> mapaSesiones,
  ) {
    final dayYmd = AppDateUtils.toYmd(day);
    final isCompleted = mapaSesiones.containsKey(dayYmd);
    final isToday = dayYmd == hoyYmd;

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.steelBlue : Colors.transparent,
          shape: BoxShape.circle,
          border: isToday
              ? Border.all(color: AppColors.gold, width: 2)
              : null,
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: AppColors.steelBlue.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: isCompleted || isToday ? FontWeight.w700 : FontWeight.w500,
              color: isCompleted ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutsideDayCell(DateTime day) {
    return Center(
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}
