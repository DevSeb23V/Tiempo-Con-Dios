import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/devocional_repository.dart';
import '../../../core/utils/date_utils.dart';
import 'widgets/manual_entry_sheet.dart';

/// Pantalla con el desglose detallado de sesiones devocionales del mes seleccionado.
class MonthDetailPage extends ConsumerWidget {
  final int anio;
  final int mes;

  const MonthDetailPage({
    super.key,
    required this.anio,
    required this.mes,
  });

  String _formatMonthYear(int anio, int mes) {
    try {
      final date = DateTime(anio, mes, 1);
      final formatter = DateFormat('MMMM yyyy', 'es');
      final formatted = formatter.format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (_) {
      return '$mes/$anio';
    }
  }

  String _formatDate(String ymd) {
    try {
      final date = AppDateUtils.fromYmd(ymd);
      final formatter = DateFormat("EEEE, d 'de' MMMM", 'es');
      final formatted = formatter.format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (_) {
      return ymd;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesionesAsync = ref.watch(sesionesMesStreamProvider((anio: anio, mes: mes)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detalle del mes',
          style: AppTypography.titleSmall(),
        ),
      ),
      body: SafeArea(
        child: sesionesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.steelBlue),
          ),
          error: (err, _) => Center(
            child: Text('Error al cargar historial: $err'),
          ),
          data: (sesiones) {
            final totalMinutos = sesiones.fold<int>(0, (sum, s) => sum + s.duracionMinutos);
            final promedio = sesiones.isEmpty ? 0 : (totalMinutos / sesiones.length).round();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              children: [
                Text(
                  _formatMonthYear(anio, mes),
                  style: AppTypography.titleLarge(),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cada minuto sembrado en intimidad da fruto.',
                  style: AppTypography.subtitle(),
                ),
                const SizedBox(height: 20),

                // Fila de 3 métricas de resumen
                Row(
                  children: [
                    Expanded(
                      child: _ResumenPill(
                        label: 'Sesiones',
                        value: '${sesiones.length}',
                        icon: Icons.check_circle_outline_rounded,
                        color: AppColors.steelBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResumenPill(
                        label: 'Total min',
                        value: '$totalMinutos',
                        icon: Icons.access_time_rounded,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResumenPill(
                        label: 'Promedio',
                        value: '$promedio m',
                        icon: Icons.speed_rounded,
                        color: AppColors.orangePrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  'Registro de sesiones',
                  style: AppTypography.bodyMediumBold(),
                ),
                const SizedBox(height: 12),

                if (sesiones.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 40, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No hay sesiones registradas en este mes.',
                            textAlign: TextAlign.center,
                            style: AppTypography.caption(),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...sesiones.reversed.map((s) => _SesionItemCard(
                        sesion: s,
                        formattedDate: _formatDate(s.fecha),
                        onTap: () {
                          ManualEntrySheet.show(
                            context,
                            date: AppDateUtils.fromYmd(s.fecha),
                            existingSession: s,
                          );
                        },
                      )),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResumenPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ResumenPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.titleSmall().copyWith(fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption().copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SesionItemCard extends StatelessWidget {
  final SesionDevocionalData sesion;
  final String formattedDate;
  final VoidCallback onTap;

  const _SesionItemCard({
    required this.sesion,
    required this.formattedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.steelBlue.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.steelBlue,
            size: 22,
          ),
        ),
        title: Text(
          formattedDate,
          style: AppTypography.bodyMediumBold(),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                '${sesion.duracionMinutos} min',
                style: AppTypography.caption(color: AppColors.steelBlue).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sesion.registroManual ? 'Manual' : 'Cronómetro',
                  style: AppTypography.caption(color: AppColors.textMuted).copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textMuted,
          size: 20,
        ),
      ),
    ),
  );
}
}
