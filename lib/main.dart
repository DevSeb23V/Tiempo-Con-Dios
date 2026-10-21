import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app_router.dart';
import 'core/database/app_database.dart';
import 'core/database/devocional_repository.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('es', null);
  } catch (e) {
    debugPrint('Error al inicializar formato de fecha: $e');
  }

  final container = ProviderContainer();

  // Iniciar la app de inmediato para que Flutter pinte su primer frame y retire
  // la pantalla nativa de carga ("fuego en medio") en cualquier dispositivo
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TiempoConDiosApp(),
    ),
  );

  // Inicialización desacoplada y segura de notificaciones y alarmas
  _inicializarServiciosEnSegundoPlano(container);
}

/// Inicializa el servicio de alarmas y la sincronización con Drift sin bloquear el arranque de la app
void _inicializarServiciosEnSegundoPlano(ProviderContainer container) async {
  try {
    final notifService = container.read(notificationServiceProvider);

    await notifService.inicializar(
      onSelectNotification: (payload) {
        if (payload == 'alerta_devocional') {
          appRouter.go('/alerta');
        }
      },
    );

    // Sincronización automática de alarmas exactas con la configuración de la BD Drift
    container.listen<AsyncValue<ConfiguracionUsuarioData>>(
      configuracionStreamProvider,
      (previous, next) {
        if (next.hasValue) {
          final config = next.value!;
          notifService.programarAlarmaDevocional(
            hora: config.horaDevocional,
            diasSemana: config.diasSemana,
          );
          notifService.programarAvisoPrevio(
            hora: config.horaAvisoPrevio,
            diasSemana: config.diasSemana,
            activo: config.avisoPrevioActivo,
          );
        }
      },
      fireImmediately: true,
    );
  } catch (e, stack) {
    debugPrint('Error inicializando servicios en segundo plano: $e\n$stack');
  }
}

/// Aplicación raíz de "Tiempo con Dios".
class TiempoConDiosApp extends StatelessWidget {
  const TiempoConDiosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tiempo con Dios',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
