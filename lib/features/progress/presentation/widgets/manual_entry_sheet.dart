import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/devocional_repository.dart';

/// Modal inferior para registrar o editar manualmente un día devocional en el calendario.
class ManualEntrySheet extends ConsumerStatefulWidget {
  final DateTime date;
  final SesionDevocionalData? existingSession;

  const ManualEntrySheet({
    super.key,
    required this.date,
    this.existingSession,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    SesionDevocionalData? existingSession,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ManualEntrySheet(
        date: date,
        existingSession: existingSession,
      ),
    );
  }

  @override
  ConsumerState<ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends ConsumerState<ManualEntrySheet> {
  late int _selectedMinutes;
  bool _isLoading = false;

  final List<int> _quickPresets = [10, 15, 20, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.existingSession?.duracionMinutos ?? 15;
  }

  String _formatDateTitle(DateTime date) {
    try {
      final formatter = DateFormat("EEEE, d 'de' MMMM", 'es');
      final formatted = formatter.format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (_) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _guardar() async {
    setState(() => _isLoading = true);
    final repo = ref.read(devocionalRepositoryProvider);
    try {
      await repo.registrarDiaManual(
        widget.date,
        duracionMinutos: _selectedMinutes,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tiempo con Dios guardado con paz.',
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
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('¿Eliminar registro?', style: AppTypography.titleSmall()),
        content: Text(
          'Se borrará el tiempo registrado de este día. Recuerda que no perderás tu nivel en Tiempo con Dios.',
          style: AppTypography.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar', style: AppTypography.bodyMedium()),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);
    final repo = ref.read(devocionalRepositoryProvider);
    try {
      await repo.eliminarRegistroDia(widget.date);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registro eliminado.',
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
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSession != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de agarre superior
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Tiempo registrado' : 'Registrar día devocional',
                      style: AppTypography.titleSmall(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTitle(widget.date),
                      style: AppTypography.caption(color: AppColors.steelBlue),
                    ),
                  ],
                ),
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  tooltip: 'Eliminar registro',
                  onPressed: _isLoading ? null : _eliminar,
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Selector de duración
          Text(
            'Duración del tiempo con Dios',
            style: AppTypography.bodyMediumBold(),
          ),
          const SizedBox(height: 12),

          // Chips rápidos de minutos
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickPresets.map((mins) {
              final isSelected = _selectedMinutes == mins;
              return ChoiceChip(
                label: Text(
                  '$mins min',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.steelBlue,
                backgroundColor: AppColors.background,
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected ? AppColors.steelBlue : Colors.transparent,
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedMinutes = mins);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Slider para ajuste fino
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 20, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(
                '$_selectedMinutes minutos',
                style: AppTypography.metricNumber().copyWith(fontSize: 18),
              ),
              Expanded(
                child: Slider(
                  value: _selectedMinutes.toDouble().clamp(1.0, 180.0),
                  min: 5,
                  max: 120,
                  divisions: 23,
                  activeColor: AppColors.steelBlue,
                  inactiveColor: AppColors.cloudBlue,
                  onChanged: (val) {
                    setState(() => _selectedMinutes = val.round());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Botón de acción principal
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.steelBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isEditing ? 'Actualizar registro' : 'Guardar tiempo con Dios',
                      style: AppTypography.buttonText(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
