import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tiempo_con_dios/core/database/devocional_repository.dart';
import 'package:tiempo_con_dios/core/notifications/notification_service.dart';
import 'package:tiempo_con_dios/features/alert/presentation/alerta_fullscreen_page.dart';

class _FakeDevocionalRepository extends Fake implements DevocionalRepository {
  bool inicioSesionGuardado = false;

  @override
  Future<void> guardarInicioSesion([DateTime? fechaInicio]) async {
    inicioSesionGuardado = true;
  }
}

class _FakeNotificationService extends Fake implements NotificationService {
  bool pospuesto = false;
  bool posposicionCancelada = false;

  @override
  Future<void> posponerDevocional10Min() async {
    pospuesto = true;
  }

  @override
  Future<void> cancelarPosposicion() async {
    posposicionCancelada = true;
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  GoRouter createTestRouter() {
    return GoRouter(
      initialLocation: '/alerta',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/alerta',
          builder: (context, state) => const AlertaFullScreenPage(),
        ),
      ],
    );
  }

  testWidgets('AlertaFullScreenPage muestra hora, título, mensaje y botones', (tester) async {
    final fakeRepo = _FakeDevocionalRepository();
    final fakeNotif = _FakeNotificationService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          devocionalRepositoryProvider.overrideWithValue(fakeRepo),
          notificationServiceProvider.overrideWithValue(fakeNotif),
        ],
        child: MaterialApp.router(
          routerConfig: createTestRouter(),
        ),
      ),
    );
    await tester.pump();

    // Verificamos elementos clave
    expect(find.text('Es momento de tu\ntiempo con Dios'), findsOneWidget);
    expect(find.text('Deja a un lado las prisas del mundo.\nTu Padre te espera en lo secreto.'), findsOneWidget);
    expect(find.text('Empezaré mi tiempo'), findsOneWidget);
    expect(find.text('Posponer 10 min'), findsOneWidget);
  });

  testWidgets('Tocar "Posponer 10 min" programa posposición y navega', (tester) async {
    final fakeRepo = _FakeDevocionalRepository();
    final fakeNotif = _FakeNotificationService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          devocionalRepositoryProvider.overrideWithValue(fakeRepo),
          notificationServiceProvider.overrideWithValue(fakeNotif),
        ],
        child: MaterialApp.router(
          routerConfig: createTestRouter(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Posponer 10 min'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(fakeNotif.pospuesto, isTrue);
    expect(find.text('Home'), findsOneWidget);
  });
}

