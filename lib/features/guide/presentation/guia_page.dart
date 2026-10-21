import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/devocional_repository.dart';
import 'widgets/add_activity_dialog.dart';
import 'widgets/cloud_step_card.dart';

/// Pantalla 3: Guía de hoy
/// Permite al creyente ordenar sus pasos devocionales (Orar, Leer la Biblia, Escribir, etc.)
/// con tarjetas en forma de nube suave celeste (#E3EAF4) y reordenables mediante drag & drop.
class GuiaPage extends ConsumerStatefulWidget {
  const GuiaPage({super.key});

  @override
  ConsumerState<GuiaPage> createState() => _GuiaPageState();
}

class _GuiaPageState extends ConsumerState<GuiaPage> {
  List<ActividadGuiaData>? _orderedActivities;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final actividadesAsync = ref.watch(actividadesStreamProvider);

    // Sincronizamos con la base de datos si no hay cambios pendientes sin guardar
    if (!_hasUnsavedChanges && actividadesAsync.hasValue) {
      _orderedActivities = List.from(actividadesAsync.value!);
    }

    final items = _orderedActivities ?? actividadesAsync.valueOrNull ?? <ActividadGuiaData>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guía de hoy',
                style: AppTypography.titleLarge(),
              ),
              const SizedBox(height: 4),
              Text(
                'Ordena tus pasos como Dios te guíe',
                style: AppTypography.subtitle(),
              ),
              const SizedBox(height: 28),

              // Lista horizontal reordenable de tarjetas en forma de nube
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (items.isEmpty)
                        Container(
                          height: 180,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(color: AppColors.steelBlue),
                        )
                      else if (items.length <= 3)
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int i = 0; i < items.length; i++)
                                  _buildDraggableCard(items[i], i, items.length),
                              ],
                            ),
                          ),
                        )
                      else
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Primeros 3 elementos organizados horizontalmente
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (int i = 0; i < 3; i++)
                                      _buildDraggableCard(items[i], i, items.length),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // A partir del 4.º elemento en adelante, organizados hacia abajo y centrados verticalmente
                              Wrap(
                                alignment: WrapAlignment.center,
                                runSpacing: 16,
                                children: [
                                  for (int i = 3; i < items.length; i++)
                                    _buildDraggableCard(items[i], i, items.length),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Botón tipo nube "+ Agregar actividad"
                      InkWell(
                        onTap: _abrirDialogoAgregar,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.cloudBlue.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add_rounded,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Agregar actividad',
                                style: AppTypography.bodyMediumBold(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Leyenda con ícono de mano
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.touch_app_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Mantén presionado y desliza para cambiar el orden',
                              textAlign: TextAlign.center,
                              style: AppTypography.caption(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Botón inferior fijo "Guardar orden"
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _guardarOrden,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.steelBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Guardar orden',
                          style: AppTypography.buttonText(),
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableCard(ActividadGuiaData actividad, int index, int totalCount) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) {
        _onReorderItem(details.data, index);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            color: Colors.transparent,
            child: Transform.scale(
              scale: 1.05,
              child: Opacity(
                opacity: 0.9,
                child: CloudStepCard(
                  index: index,
                  actividad: actividad,
                  onDelete: null,
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: CloudStepCard(
              index: index,
              actividad: actividad,
              onDelete: null,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              border: isHovered
                  ? Border.all(color: AppColors.gold, width: 2)
                  : null,
            ),
            child: CloudStepCard(
              index: index,
              actividad: actividad,
              onDelete: totalCount > 1 ? () => _eliminarActividad(actividad) : null,
            ),
          ),
        );
      },
    );
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    setState(() {
      final currentList = _orderedActivities ?? ref.read(actividadesStreamProvider).valueOrNull ?? <ActividadGuiaData>[];
      final items = List<ActividadGuiaData>.from(currentList);
      if (oldIndex < 0 || oldIndex >= items.length || newIndex < 0 || newIndex >= items.length) return;
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      _orderedActivities = items;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _guardarOrden() async {
    if (_orderedActivities == null) return;
    setState(() => _isSaving = true);
    final repo = ref.read(devocionalRepositoryProvider);
    try {
      await repo.guardarOrdenActividades(_orderedActivities!);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasUnsavedChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Orden guardado con paz.',
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
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _abrirDialogoAgregar() async {
    final titulo = await AddActivityDialog.show(context);
    if (titulo != null && titulo.isNotEmpty) {
      final repo = ref.read(devocionalRepositoryProvider);
      await repo.agregarActividad(titulo);
      setState(() {
        _hasUnsavedChanges = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Actividad "$titulo" agregada.',
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
    }
  }

  Future<void> _eliminarActividad(ActividadGuiaData actividad) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('¿Eliminar actividad?', style: AppTypography.titleSmall()),
        content: Text(
          '¿Deseas quitar "${actividad.titulo}" de tu guía devocional?',
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

    if (confirmar == true) {
      final repo = ref.read(devocionalRepositoryProvider);
      await repo.eliminarActividad(actividad.id);
      setState(() {
        _hasUnsavedChanges = false;
      });
    }
  }
}
