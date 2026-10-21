import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiempo_con_dios/core/database/app_database.dart';
import 'package:tiempo_con_dios/core/database/devocional_repository.dart';
import 'package:tiempo_con_dios/features/settings/presentation/settings_page.dart';

void main() {
  testWidgets('SettingsPage renderiza secciones de perfil, horario, alarmas, gracia y privacidad', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    const config = ConfiguracionUsuarioData(
      id: 1,
      nombreUsuario: 'Sebastian',
      diasSemana: [1, 2, 3, 4, 5, 6, 7],
      horaDevocional: '07:00',
      avisoPrevioActivo: false,
      horaAvisoPrevio: null,
      sesionActivaInicio: null,
      onboardingCompletado: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configuracionStreamProvider.overrideWith((ref) => Stream.value(config)),
        ],
        child: const MaterialApp(
          home: SettingsPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Personaliza tu rutina y preferencias'), findsOneWidget);
    expect(find.text('Nombre en el saludo'), findsOneWidget);
    expect(find.text('Sebastian'), findsOneWidget);
    expect(find.text('Cita diaria con Dios'), findsOneWidget);
    expect(find.text('07:00'), findsOneWidget);
    expect(find.text('Probar alarma en 10 segundos'), findsOneWidget);
    expect(find.text('Ver Alerta a Pantalla Completa'), findsOneWidget);
    expect(find.text('La Regla de la Gracia'), findsOneWidget);
    expect(find.text('100% Local-First & Privado'), findsOneWidget);
    expect(find.text('Repetir Bienvenida (Onboarding)'), findsOneWidget);
  });
}
