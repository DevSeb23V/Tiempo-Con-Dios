import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/database/devocional_repository.dart';
import '../../../core/notifications/notification_service.dart';

/// Flujo de bienvenida y configuración inicial guiada (Onboarding).
/// Expone con calidez la filosofía "Local-First", "Regla de la Gracia" y solicita
/// permisos pedagógicamente antes de persistir los ajustes en SQLite Drift.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Estados del formulario guiado
  final TextEditingController _nombreController = TextEditingController(text: 'Sebastian');
  final List<int> _diasSeleccionados = [1, 2, 3, 4, 5, 6, 7];
  TimeOfDay _horaDevocional = const TimeOfDay(hour: 7, minute: 0);
  bool _avisoPrevio = false;
  TimeOfDay _horaAvisoPrevio = const TimeOfDay(hour: 6, minute: 30);
  bool _guardando = false;

  final List<String> _nombresDias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  void dispose() {
    _pageController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _seleccionarHoraDevocional() async {
    final seleccion = await showTimePicker(
      context: context,
      initialTime: _horaDevocional,
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
      setState(() {
        _horaDevocional = seleccion;
        final totalMin = (seleccion.hour * 60 + seleccion.minute - 30);
        final adjustedMin = (totalMin + 1440) % 1440;
        _horaAvisoPrevio = TimeOfDay(
          hour: adjustedMin ~/ 60,
          minute: adjustedMin % 60,
        );
      });
    }
  }

  Future<void> _seleccionarHoraAviso() async {
    final seleccion = await showTimePicker(
      context: context,
      initialTime: _horaAvisoPrevio,
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
      setState(() {
        _horaAvisoPrevio = seleccion;
      });
    }
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _completarYGuardar() async {
    setState(() => _guardando = true);

    final notifService = ref.read(notificationServiceProvider);
    final repo = ref.read(devocionalRepositoryProvider);

    // 1. Pedir permisos amablemente al SO
    await notifService.solicitarPermisos();

    // 2. Persistir configuración en SQLite Drift
    final nombre = _nombreController.text.trim().isEmpty ? 'Amigo' : _nombreController.text.trim();
    final horaDevStr = _formatTime(_horaDevocional);
    final horaAvisoStr = _avisoPrevio ? _formatTime(_horaAvisoPrevio) : null;

    await repo.completarOnboarding(
      nombre: nombre,
      dias: _diasSeleccionados.isEmpty ? [1, 2, 3, 4, 5, 6, 7] : _diasSeleccionados,
      horaDevocional: horaDevStr,
      avisoPrevio: _avisoPrevio,
      horaAviso: horaAvisoStr,
    );

    // 3. Programar las alarmas iniciales
    await notifService.programarAlarmaDevocional(
      hora: horaDevStr,
      diasSemana: _diasSeleccionados,
    );

    if (_avisoPrevio) {
      await notifService.programarAvisoPrevio(
        hora: horaAvisoStr,
        diasSemana: _diasSeleccionados,
        activo: true,
      );
    }

    if (mounted) {
      setState(() => _guardando = false);
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior con botón volver e indicador de progreso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      color: AppColors.textPrimary,
                      onPressed: _previousPage,
                    )
                  else
                    const SizedBox(width: 48, height: 48),

                  // Indicador de pasos discretos
                  Row(
                    children: List.generate(5, (index) {
                      final isActive = index == _currentStep;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.steelBlue : AppColors.steelBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Espacio simétrico
                  const SizedBox(width: 48, height: 48),
                ],
              ),
            ),

            // Contenido deslizable por pasos
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (step) => setState(() => _currentStep = step),
                children: [
                  _buildPaso0Bienvenida(),
                  _buildPaso1Nombre(),
                  _buildPaso2Horario(),
                  _buildPaso3AvisoPrevio(),
                  _buildPaso4Permisos(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PASO 0: BIENVENIDA Y FILOSOFÍA
  Widget _buildPaso0Bienvenida() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF9E0AE), Color(0xFFF4B77A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tiempo con Dios',
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge(fontSize: 28),
          ),
          const SizedBox(height: 10),
          Text(
            'Un espacio digital para desconectarte de todo y encontrarte con Dios en lo secreto.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Puntos clave de valor
          _buildPilarCard(
            Icons.auto_stories_outlined,
            'Con tu Biblia y cuaderno físico',
            'Esta app está pensada para ser cerrada. El celular reposa a un lado mientras tu corazón se enfoca en lo importante.',
          ),
          const SizedBox(height: 10),
          _buildPilarCard(
            Icons.favorite_border_rounded,
            'Cero culpa, sin rachas rotas',
            'Tu progreso no se destruye si fallas un día. Dios valora tu constancia, no el perfeccionismo.',
          ),
          const SizedBox(height: 10),
          _buildPilarCard(
            Icons.cloud_sync_outlined,
            'Privacidad y sincronización en la nube',
            'Inicia sesión con tu cuenta para mantener tu progreso a salvo en cualquier dispositivo. Tu intimidad con Dios se guarda con total seguridad.',
          ),

          const SizedBox(height: 32),
          _buildBotonPrincipal(
            texto: 'Comenzar →',
            onTap: _nextPage,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // PASO 1: NOMBRE
  Widget _buildPaso1Nombre() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            '¿Cómo te llamas?',
            style: AppTypography.titleLarge(fontSize: 28),
          ),
          const SizedBox(height: 10),
          Text(
            'Queremos saludarte con calidez cada mañana.',
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 36),

          // Input de nombre estilizado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.steelBlue.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _nombreController,
              style: AppTypography.titleMedium(fontSize: 18),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Tu nombre o apodo',
                hintStyle: AppTypography.body(color: Colors.grey.shade400),
                icon: const Icon(Icons.person_outline_rounded, color: AppColors.steelBlue),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ),

          const SizedBox(height: 80),
          _buildBotonPrincipal(
            texto: 'Continuar →',
            onTap: _nextPage,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // PASO 2: HORARIO Y DÍAS
  Widget _buildPaso2Horario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Tu momento sagrado',
            style: AppTypography.titleLarge(fontSize: 28),
          ),
          const SizedBox(height: 10),
          Text(
            'Elige a qué hora y qué días deseas apartar tu tiempo devocional.',
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 30),

          // Tarjeta de hora devocional
          GestureDetector(
            onTap: _seleccionarHoraDevocional,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.alarm_rounded, color: AppColors.goldDark, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hora devocional', style: AppTypography.caption()),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(_horaDevocional),
                            style: AppTypography.titleLarge(fontSize: 26),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cloudBlue,
                      borderRadius: BorderRadius.circular(16),
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
          ),

          const SizedBox(height: 28),
          Text(
            'Días de la semana',
            style: AppTypography.titleMedium(fontSize: 16),
          ),
          const SizedBox(height: 14),

          // Selector de días
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final diaId = index + 1;
              final isSelected = _diasSeleccionados.contains(diaId);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      if (_diasSeleccionados.length > 1) {
                        _diasSeleccionados.remove(diaId);
                      }
                    } else {
                      _diasSeleccionados.add(diaId);
                      _diasSeleccionados.sort();
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.steelBlue : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.steelBlue : Colors.black12,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.steelBlue.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _nombresDias[index],
                      style: AppTypography.body(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 48),
          _buildBotonPrincipal(
            texto: 'Continuar →',
            onTap: _nextPage,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // PASO 3: AVISO PREVIO (PREPARA TU ESPACIO)
  Widget _buildPaso3AvisoPrevio() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Prepara tu espacio',
            style: AppTypography.titleLarge(fontSize: 28),
          ),
          const SizedBox(height: 10),
          Text(
            '¿Deseas un aviso suave previo para dejar lista tu Biblia física, cuaderno y pluma antes de empezar?',
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          // Tarjeta con Switch
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.cloudBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none_rounded, color: AppColors.steelBlue),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Aviso anticipado', style: AppTypography.titleMedium(fontSize: 16)),
                            Text('Notificación tranquila', style: AppTypography.caption()),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _avisoPrevio,
                      activeTrackColor: AppColors.steelBlue,
                      onChanged: (val) => setState(() => _avisoPrevio = val),
                    ),
                  ],
                ),
                if (_avisoPrevio) ...[
                  const Divider(height: 30),
                  GestureDetector(
                    onTap: _seleccionarHoraAviso,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hora del aviso', style: AppTypography.caption()),
                            const SizedBox(height: 2),
                            Text(_formatTime(_horaAvisoPrevio), style: AppTypography.titleMedium(fontSize: 20)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.cloudBlue,
                            borderRadius: BorderRadius.circular(14),
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
                ],
              ],
            ),
          ),

          const SizedBox(height: 60),
          _buildBotonPrincipal(
            texto: 'Continuar →',
            onTap: _nextPage,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // PASO 4: EXPLICACIÓN PEDAGÓGICA DE PERMISOS
  Widget _buildPaso4Permisos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.steelBlue.withValues(alpha: 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.steelBlue,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Para acompañarte a tiempo',
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge(fontSize: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Para que la campana de intimidad pueda sonar a la hora exacta pactada y levantarse limpiamente sobre tu pantalla de bloqueo, necesitamos activar el permiso de alarmas y notificaciones.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cloudBlue.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.steelBlue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nunca recibirás publicidad, promociones ni avisos invasivos. Solo tu llamado devocional.',
                    style: AppTypography.caption(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildBotonPrincipal(
            texto: _guardando ? 'Preparando todo...' : 'Activar y Comenzar mi camino',
            onTap: _guardando ? () {} : _completarYGuardar,
            isLoading: _guardando,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Tarjeta de beneficio / pilar
  Widget _buildPilarCard(IconData icono, String titulo, String descripcion) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.cloudBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: AppColors.steelBlue, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: AppTypography.titleMedium(fontSize: 14)),
                const SizedBox(height: 2),
                Text(descripcion, style: AppTypography.caption(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Botón principal redondeado
  Widget _buildBotonPrincipal({
    required String texto,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.steelBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                texto,
                style: AppTypography.titleMedium(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
