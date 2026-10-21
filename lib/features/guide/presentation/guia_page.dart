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
                      else
                        SizedBox(
                          height: 215,
                          child: Center(
                            child: ReorderableListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              buildDefaultDragHandles: false,
                              itemCount: items.length,
                              onReorderItem: _onReorderItem,
                              itemBuilder: (context, index) {
                                final actividad = items[index];
                                return ReorderableDragStartListener(
                                  key: ValueKey('activity_${actividad.id}'),
                                  index: index,
                                  child: CloudStepCard(
                                    index: index,
                                    actividad: actividad,
                                    onDelete: items.length > 1
                                        ? () => _eliminarActividad(actividad)
                                        : null,
                                  ),
                                );
                              },
                            ),
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

  void _onReorderItem(int oldIndex, int newIndex) {
    setState(() {
      final items = List<ActividadGuiaData>.from(_orderedActivities!);
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
