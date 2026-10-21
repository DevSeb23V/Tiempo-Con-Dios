import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/devocional_repository.dart';
import '../../../core/utils/date_utils.dart';
import 'month_detail_page.dart';
import 'widgets/devocional_calendar.dart';
import 'widgets/evolution_chart.dart';
import 'widgets/manual_entry_sheet.dart';
import 'widgets/metric_pill_card.dart';

/// Pantalla 2: Mi Progreso
/// Muestra las métricas de días acumulados y minutos del mes,
/// el calendario mensual interactivo con píldoras azul acero y la gráfica de evolución.
class ProgressPage extends ConsumerStatefulWidget {
  const ProgressPage({super.key});

  @override
  ConsumerState<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends ConsumerState<ProgressPage> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final diasAcumuladosAsync = ref.watch(diasAcumuladosStreamProvider);
    final mesArg = (anio: _focusedDay.year, mes: _focusedDay.month);
    final minutosMesAsync = ref.watch(minutosMesStreamProvider(mesArg));
    final sesionesMesAsync = ref.watch(sesionesMesStreamProvider(mesArg));

    final diasAcumulados = diasAcumuladosAsync.valueOrNull ?? 0;
    final minutosMes = minutosMesAsync.valueOrNull ?? 0;
    final sesionesMes = sesionesMesAsync.valueOrNull ?? <SesionDevocionalData>[];

    // Mapa de sesiones para buscar rápidamente al tocar un día
    final Map<String, SesionDevocionalData> mapaSesiones = {
      for (final s in sesionesMes) s.fecha: s,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi Progreso',
                style: AppTypography.titleLarge(),
              ),
              const SizedBox(height: 4),
              Text(
                'Pequeños pasos, un hábito que crece.',
                style: AppTypography.subtitle(),
              ),
              const SizedBox(height: 20),

              // Fila de 2 métricas principales
              Row(
                children: [
                  Expanded(
                    child: MetricPillCard(
                      value: '$diasAcumulados',
                      label: 'días de tiempo con Dios',
                      icon: Icons.local_fire_department_rounded,
                      iconColor: AppColors.orangePrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MetricPillCard(
                      value: '$minutosMes',
                      label: 'minutos del mes',
                      icon: Icons.access_time_rounded,
                      iconColor: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Calendario devocional interactivo
              DevocionalCalendar(
                focusedDay: _focusedDay,
                sesionesMes: sesionesMes,
                onMonthChanged: (newMonth) {
                  setState(() => _focusedDay = newMonth);
                },
                onDaySelected: (day) {
                  final ymd = AppDateUtils.toYmd(day);
                  ManualEntrySheet.show(
                    context,
                    date: day,
                    existingSession: mapaSesiones[ymd],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Tarjeta Tu evolución con fl_chart
              EvolutionChart(
                sesionesMes: sesionesMes,
                anio: _focusedDay.year,
                mes: _focusedDay.month,
              ),
              const SizedBox(height: 20),

              // Sección Registro de sesiones con botón claro y nota
              Text(
                'Registro de sesiones',
                style: AppTypography.bodyMediumBold(),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  final hoyYmd = AppDateUtils.toYmd(DateTime.now());
                  final sesionHoy = mapaSesiones[hoyYmd];
                  ManualEntrySheet.show(
                    context,
                    date: DateTime.now(),
                    existingSession: sesionHoy,
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.steelBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.steelBlue.withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.edit_calendar_rounded,
                        color: AppColors.steelBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Actualizar tiempo',
                        style: AppTypography.buttonText(color: AppColors.steelBlue).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "En caso de no haber presionado 'Hecho', puedes actualizar tu tiempo aquí.",
                  style: AppTypography.caption(
                    color: AppColors.textSecondary,
                  ).copyWith(fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Botón "Ver detalle del mes →"
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MonthDetailPage(
                          anio: _focusedDay.year,
                          mes: _focusedDay.month,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.steelBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ver detalle del mes',
                        style: AppTypography.buttonText(),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
