import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_utils.dart';

/// Gráfica de evolución mensual con fl_chart.
/// Representa la curva de minutos acumulados a lo largo de los días del mes.
class EvolutionChart extends StatelessWidget {
  final List<SesionDevocionalData> sesionesMes;
  final int anio;
  final int mes;

  const EvolutionChart({
    super.key,
    required this.sesionesMes,
    required this.anio,
    required this.mes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tu evolución', style: AppTypography.titleSmall()),
              Text('Minutos acumulados', style: AppTypography.caption()),
            ],
          ),
          const SizedBox(height: 18),

          if (sesionesMes.isEmpty)
            _buildEmptyState()
          else
            _buildChart(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.trending_up_rounded,
              color: AppColors.textMuted,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no hay sesiones este mes.\nEmpieza hoy para ver tu constancia crecer.',
              textAlign: TextAlign.center,
              style: AppTypography.caption(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    // Ordenamos las sesiones por fecha ascendente
    final sesionesOrdenadas = List<SesionDevocionalData>.from(sesionesMes)
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    // Calculamos los minutos acumulados progresivos para cada día
    final List<FlSpot> spots = [];
    int minutosAcumulados = 0;

    // Punto inicial: día 1 con 0 minutos si la primera sesión es posterior al día 1
    final primerDia = AppDateUtils.fromYmd(sesionesOrdenadas.first.fecha).day;
    if (primerDia > 1) {
      spots.add(const FlSpot(1, 0));
    }

    final Set<int> diasConSesion = {};

    for (final s in sesionesOrdenadas) {
      final dia = AppDateUtils.fromYmd(s.fecha).day;
      minutosAcumulados += s.duracionMinutos;
      spots.add(FlSpot(dia.toDouble(), minutosAcumulados.toDouble()));
      diasConSesion.add(dia);
    }

    final maxY = (minutosAcumulados <= 0 ? 30 : ((minutosAcumulados / 30).ceil() * 30)).toDouble();
    final diasEnMes = DateUtils.getDaysInMonth(anio, mes);

    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? (maxY / 2) : 15,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.1),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: maxY > 0 ? (maxY / 2) : 15,
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return Text('0', style: AppTypography.caption(color: AppColors.textMuted));
                  }
                  if (value.toInt() == maxY.toInt()) {
                    return Text('${value.toInt()}', style: AppTypography.caption(color: AppColors.textMuted));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final dia = value.toInt();
                  if (diasConSesion.contains(dia)) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$dia',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.steelBlue,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 1,
          maxX: diasEnMes.toDouble(),
          minY: 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    'Día ${spot.x.toInt()}: ${spot.y.toInt()} min',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.steelBlue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3.5,
                    color: AppColors.steelBlue,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.steelBlue.withValues(alpha: 0.25),
                    AppColors.steelBlue.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
