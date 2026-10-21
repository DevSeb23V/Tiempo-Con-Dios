import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

/// Tarjeta de métrica con número entre corchetes, icono decorativo y etiqueta descriptiva.
/// Ejemplos: "[12] días de tiempo con Dios", "[180] minutos del mes".
class MetricPillCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const MetricPillCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
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
              Text(
                '[$value]',
                style: AppTypography.metricNumber(),
              ),
              Icon(icon, color: iconColor, size: 22),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.caption(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
