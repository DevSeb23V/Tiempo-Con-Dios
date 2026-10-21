import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/devocional_repository.dart';
import '../../../core/notifications/notification_service.dart';

/// Pantalla de Ajustes de "Tiempo con Dios".
/// Permite personalizar horarios, días activos, avisos previos, probar las alarmas exactas
/// y consultar las políticas de privacidad y la Regla de la Gracia.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final List<String> _nombresDias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  void _editarNombre(BuildContext context, String nombreActual) {
    final controller = TextEditingController(text: nombreActual);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Modificar nombre', style: AppTypography.titleMedium()),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTypography.body(),
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Tu nombre',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancelar', style: AppTypography.body(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.steelBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              final nuevoNombre = controller.text.trim();
              if (nuevoNombre.isNotEmpty) {
                final repo = ref.read(devocionalRepositoryProvider);
                await repo.actualizarConfiguracion(
                  ConfiguracionUsuarioTableCompanion(
                    nombreUsuario: Value(nuevoNombre),
                  ),
                );
              }
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cambiarHoraDevocional(BuildContext context, String horaActual) async {
    final partes = horaActual.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(partes[0]) ?? 7,
      minute: partes.length > 1 ? (int.tryParse(partes[1]) ?? 0) : 0,
    );

    final seleccion = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.steelBlue,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (seleccion != null) {
      final hour = seleccion.hour.toString().padLeft(2, '0');
      final min = seleccion.minute.toString().padLeft(2, '0');
      final nuevaHora = '$hour:$min';

      final repo = ref.read(devocionalRepositoryProvider);
      await repo.actualizarConfiguracion(
        ConfiguracionUsuarioTableCompanion(
          horaDevocional: Value(nuevaHora),
        ),
      );

      // Sincronizar alarmas del sistema operativo
      final config = await repo.obtenerConfiguracion();
      final notif = ref.read(notificationServiceProvider);
      await notif.programarAlarmaDevocional(
        hora: nuevaHora,
        diasSemana: config.diasSemana,
      );
    }
  }

  Future<void> _cambiarHoraAviso(BuildContext context, String? horaActual) async {
    final partes = (horaActual ?? '06:30').split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(partes[0]) ?? 6,
      minute: partes.length > 1 ? (int.tryParse(partes[1]) ?? 30) : 30,
    );

    final seleccion = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.steelBlue,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (seleccion != null) {
      final hour = seleccion.hour.toString().padLeft(2, '0');
      final min = seleccion.minute.toString().padLeft(2, '0');
      final nuevaHora = '$hour:$min';

      final repo = ref.read(devocionalRepositoryProvider);
      await repo.actualizarConfiguracion(
        ConfiguracionUsuarioTableCompanion(
          horaAvisoPrevio: Value(nuevaHora),
        ),
      );

      final config = await repo.obtenerConfiguracion();
      final notif = ref.read(notificationServiceProvider);
      await notif.programarAvisoPrevio(
        hora: nuevaHora,
        diasSemana: config.diasSemana,
        activo: config.avisoPrevioActivo,
      );
    }
  }

  Future<void> _toggleDia(int diaId, List<int> diasActuales) async {
    final nuevaLista = List<int>.from(diasActuales);
    if (nuevaLista.contains(diaId)) {
      if (nuevaLista.length > 1) {
        nuevaLista.remove(diaId);
      }
    } else {
      nuevaLista.add(diaId);
      nuevaLista.sort();
    }

    final repo = ref.read(devocionalRepositoryProvider);
    await repo.actualizarConfiguracion(
      ConfiguracionUsuarioTableCompanion(
        diasSemana: Value(nuevaLista),
      ),
    );

    final config = await repo.obtenerConfiguracion();
    final notif = ref.read(notificationServiceProvider);
    await notif.programarAlarmaDevocional(
      hora: config.horaDevocional,
      diasSemana: nuevaLista,
    );
  }

  Future<void> _toggleAvisoPrevio(bool activo, String? horaActual, List<int> dias) async {
    final repo = ref.read(devocionalRepositoryProvider);
    await repo.actualizarConfiguracion(
      ConfiguracionUsuarioTableCompanion(
        avisoPrevioActivo: Value(activo),
        horaAvisoPrevio: Value(horaActual ?? '06:30'),
      ),
    );

    final notif = ref.read(notificationServiceProvider);
    await notif.programarAvisoPrevio(
      hora: horaActual ?? '06:30',
      diasSemana: dias,
      activo: activo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(configuracionStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Ajustes', style: AppTypography.titleLarge(fontSize: 22)),
        centerTitle: true,
      ),
      body: configAsync.when(
        data: (config) => _buildContent(context, config),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.steelBlue)),
        error: (err, _) => Center(child: Text('Error al cargar configuración: $err')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ConfiguracionUsuarioData config) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Subtítulo
        Text(
          'Personaliza tu rutina y preferencias',
          style: AppTypography.body(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 20),

        // 1. SECCIÓN: PERFIL
        _buildSectionHeader('Perfil'),
        _buildCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.cloudBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline_rounded, color: AppColors.steelBlue),
            ),
            title: Text('Nombre en el saludo', style: AppTypography.caption()),
            subtitle: Text(config.nombreUsuario, style: AppTypography.titleMedium(fontSize: 18)),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.steelBlue, size: 20),
              onPressed: () => _editarNombre(context, config.nombreUsuario),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 2. SECCIÓN: HORARIOS Y RUTINA
        _buildSectionHeader('Horario del Devocional'),
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hora devocional principal
              GestureDetector(
                onTap: () => _cambiarHoraDevocional(context, config.horaDevocional),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.alarm_rounded, color: AppColors.goldDark, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cita diaria con Dios', style: AppTypography.caption()),
                            const SizedBox(height: 2),
                            Text(config.horaDevocional, style: AppTypography.titleLarge(fontSize: 22)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cloudBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Cambiar',
                        style: AppTypography.caption(
                          color: AppColors.steelBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 28),

              // Días activos
              Text('Días activos de devocional', style: AppTypography.caption()),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final diaId = index + 1;
                  final isSelected = config.diasSemana.contains(diaId);

                  return GestureDetector(
                    onTap: () => _toggleDia(diaId, config.diasSemana),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.steelBlue : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.steelBlue : Colors.black12,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _nombresDias[index],
                          style: AppTypography.body(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const Divider(height: 28),

              // Aviso previo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.cloudBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none_rounded, color: AppColors.steelBlue, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Aviso previo ("Prepara tu espacio")', style: AppTypography.titleMedium(fontSize: 14)),
                        Text(
                          config.avisoPrevioActivo
                              ? 'Sonar a las ${config.horaAvisoPrevio ?? "06:30"}'
                              : 'Desactivado',
                          style: AppTypography.caption(),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: config.avisoPrevioActivo,
                    activeTrackColor: AppColors.steelBlue,
                    onChanged: (val) => _toggleAvisoPrevio(val, config.horaAvisoPrevio, config.diasSemana),
                  ),
                ],
              ),

              if (config.avisoPrevioActivo) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.schedule, size: 16, color: AppColors.steelBlue),
                    label: Text(
                      'Cambiar hora del aviso (${config.horaAvisoPrevio ?? "06:30"})',
                      style: AppTypography.caption(color: AppColors.steelBlue, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _cambiarHoraAviso(context, config.horaAvisoPrevio),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 3. SECCIÓN: PRUEBAS DE ALARMA EXACTA
        _buildSectionHeader('Verificación de Alarmas'),
        _buildCard(
          child: Column(
            children: [
              // Probar en 10 segundos
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.timer_outlined, color: AppColors.goldDark),
                ),
                title: Text('Probar alarma en 10 segundos', style: AppTypography.titleMedium(fontSize: 15)),
                subtitle: Text('Programa una alarma de prueba para verificar el sonido.', style: AppTypography.caption()),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                onTap: () async {
                  final notif = ref.read(notificationServiceProvider);
                  await notif.probarAlarmaEn10Segundos();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.steelBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        content: const Text(
                          '🔔 Alarma programada en 10 segundos. Puedes bloquear tu pantalla para probar.',
                        ),
                      ),
                    );
                  }
                },
              ),

              const Divider(height: 16),

              // Ver alerta pantalla completa
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.cloudBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fullscreen_rounded, color: AppColors.steelBlue),
                ),
                title: Text('Ver Alerta a Pantalla Completa', style: AppTypography.titleMedium(fontSize: 15)),
                subtitle: Text('Vista previa del despertador de intimidad devocional.', style: AppTypography.caption()),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                onTap: () => context.push('/alerta'),
              ),

              const Divider(height: 16),

              // Notificación instantánea de campana
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.cloudBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active_outlined, color: AppColors.steelBlue),
                ),
                title: Text('Sonar campana calmada ahora', style: AppTypography.titleMedium(fontSize: 15)),
                subtitle: Text('Prueba el tono armónico de 432 Hz de inmediato.', style: AppTypography.caption()),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                onTap: () async {
                  final notif = ref.read(notificationServiceProvider);
                  await notif.dispararAlertaInmediataParaPruebas();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 4. SECCIÓN: FILOSOFÍA Y REGLA DE LA GRACIA
        _buildSectionHeader('Filosofía de Gracia y Paz'),
        _buildCard(
          color: AppColors.cloudBlue.withValues(alpha: 0.35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department_outlined, color: AppColors.flameOrange, size: 24),
                  const SizedBox(width: 10),
                  Text('La Regla de la Gracia', style: AppTypography.titleMedium(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'En Tiempo con Dios, tu constancia nunca se destruye a cero. Si faltas unos días, tu llama entra en reposo protegiendo el nivel alcanzado.\n\nCreemos firmemente en buscar a Dios por amor y gratitud, no por la culpa de una racha rota.',
                style: AppTypography.body(fontSize: 13, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildCard(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.security_outlined, color: AppColors.steelBlue, size: 22),
                  const SizedBox(width: 10),
                  Text('100% Local-First & Privado', style: AppTypography.titleMedium(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Tus tiempos, oraciones y notas reposan exclusivamente en la memoria local de tu dispositivo. Sin cuentas obligatorias, sin nube, sin publicidad y sin analítica de seguimiento.',
                style: AppTypography.body(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 5. SECCIÓN: INFORMACIÓN
        _buildSectionHeader('Acerca de'),
        _buildCard(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.cloudBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: AppColors.steelBlue),
                ),
                title: Text('Repetir Bienvenida (Onboarding)', style: AppTypography.titleMedium(fontSize: 15)),
                subtitle: Text('Volver a explorar la introducción inicial.', style: AppTypography.caption()),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                onTap: () => context.push('/onboarding'),
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Versión', style: AppTypography.body(color: AppColors.textSecondary)),
                  Text('1.0.0 (Release Candidate)', style: AppTypography.caption(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.caption(
          color: AppColors.steelBlue,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, Color color = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: child,
        ),
      ),
    );
  }
}
