import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiempo_con_dios/core/database/app_database.dart';
import 'package:tiempo_con_dios/core/database/devocional_repository.dart';
import 'package:tiempo_con_dios/features/onboarding/presentation/onboarding_page.dart';

void main() {
  testWidgets('OnboardingPage renderiza paso 0 de bienvenida y avanza a paso 1 de nombre', (WidgetTester tester) async {
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
      onboardingCompletado: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configuracionStreamProvider.overrideWith((ref) => Stream.value(config)),
        ],
        child: const MaterialApp(
          home: OnboardingPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verificamos elementos clave de bienvenida
    expect(find.text('Tiempo con Dios'), findsOneWidget);
    expect(find.text('Un espacio digital para desconectarte de todo y encontrarte con Dios en lo secreto.'), findsOneWidget);
    expect(find.text('Con tu Biblia y cuaderno físico'), findsOneWidget);
    expect(find.text('Cero culpa, sin rachas rotas'), findsOneWidget);
    expect(find.text('Privacidad y sincronización en la nube'), findsOneWidget);

    // Tocamos "Comenzar →" para avanzar al paso 1
    await tester.tap(find.text('Comenzar →'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verificamos que estamos en el paso 1 de nombre
    expect(find.text('¿Cómo te llamas?'), findsOneWidget);
    expect(find.text('Queremos saludarte con calidez cada mañana.'), findsOneWidget);
  });
}
