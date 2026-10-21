import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';

/// Tarjeta devocional en forma de nube suave celeste (#E3EAF4).
/// Muestra el identificador numérico (01, 02...), el título del paso devocional
/// y la manija de arrastre (drag handle) dorada (:::).
class CloudStepCard extends StatelessWidget {
  final int index;
  final ActividadGuiaData actividad;
  final VoidCallback? onDelete;

  const CloudStepCard({
    super.key,
    required this.index,
    required this.actividad,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final stepNumber = (index + 1).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Número de paso (01, 02, 03...)
          Text(
            stepNumber,
            style: AppTypography.caption(color: AppColors.textMuted).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),

          // Tarjeta con forma de nube estilizada
          Container(
            width: 110,
            height: 165,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cloudBlue,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (onDelete != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                      tooltip: 'Eliminar actividad',
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          actividad.titulo,
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMediumBold().copyWith(
                            fontSize: 12.5,
                            height: 1.25,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Manija de agarre / Drag handle en dorado suave
                    const Icon(
                      Icons.drag_indicator_rounded,
                      color: AppColors.gold,
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
