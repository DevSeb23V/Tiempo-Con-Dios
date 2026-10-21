import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiempo_con_dios/core/database/app_database.dart';
import 'package:tiempo_con_dios/core/database/devocional_repository.dart';
import 'package:tiempo_con_dios/features/home/presentation/home_page.dart';
import 'package:tiempo_con_dios/features/home/presentation/widgets/black_screen_dialog.dart';
import 'package:tiempo_con_dios/features/home/presentation/widgets/growth_flame_painter.dart';

void main() {
  const defaultConfig = ConfiguracionUsuarioData(
    id: 1,
    nombreUsuario: 'Sebastian',
    diasSemana: [1, 2, 3, 4, 5, 6, 7],
    horaDevocional: '07:00',
    avisoPrevioActivo: false,
    horaAvisoPrevio: null,
    sesionActivaInicio: null,
    onboardingCompletado: true,
  );

  group('Pruebas de la Pantalla de Inicio (Fase 3)', () {
    test('Cálculo correcto de niveles de la Llama de Crecimiento', () {
      expect(GrowthFlameWidget.getLevel(0), FlameLevel.nivel1);
      expect(GrowthFlameWidget.getLevel(5), FlameLevel.nivel1);
      expect(GrowthFlameWidget.getLevel(7), FlameLevel.nivel1);
      expect(GrowthFlameWidget.getLevel(8), FlameLevel.nivel2);
      expect(GrowthFlameWidget.getLevel(25), FlameLevel.nivel2);
      expect(GrowthFlameWidget.getLevel(30), FlameLevel.nivel2);
      expect(GrowthFlameWidget.getLevel(31), FlameLevel.nivel3);
      expect(GrowthFlameWidget.getLevel(89), FlameLevel.nivel3);
      expect(GrowthFlameWidget.getLevel(90), FlameLevel.nivel3);
      expect(GrowthFlameWidget.getLevel(91), FlameLevel.nivel4);
      expect(GrowthFlameWidget.getLevel(150), FlameLevel.nivel4);
    });

    testWidgets('HomePage se renderiza con saludo, tarjeta y botón inicial', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configuracionStreamProvider.overrideWith((ref) => Stream.value(defaultConfig)),
            diasAcumuladosStreamProvider.overrideWith((ref) => Stream.value(12)),
            sesionesMesStreamProvider.overrideWith((ref, arg) => Stream.value([])),
            estadoLlamaVivaProvider.overrideWith((ref) => Future.value(true)),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Saludo personalizado
      expect(find.text('Hola, Sebastian'), findsOneWidget);
      // Título de la tarjeta
      expect(find.text('Tiempo con Dios\nde hoy'), findsOneWidget);
      // Botón inicial
      expect(find.text('Empezar mi tiempo'), findsOneWidget);
      // Botón programar horario
      expect(find.text('Programar horario'), findsOneWidget);
      // Fila de días
      expect(find.text('Mis días de tiempo con Dios'), findsOneWidget);
      // Llama
      expect(find.byType(GrowthFlameWidget), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Tarjeta muestra "Terminar mi tiempo (Hecho)" cuando hay sesión activa', (WidgetTester tester) async {
      final configConSesion = defaultConfig.copyWith(
        sesionActivaInicio: Value(DateTime(2026, 10, 17, 7, 0)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configuracionStreamProvider.overrideWith((ref) => Stream.value(configConSesion)),
            diasAcumuladosStreamProvider.overrideWith((ref) => Stream.value(12)),
            sesionesMesStreamProvider.overrideWith((ref, arg) => Stream.value([])),
            estadoLlamaVivaProvider.overrideWith((ref) => Future.value(true)),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verifica subtítulo activo y botón reactivo
      expect(find.text('Sesión en curso desde las 07:00'), findsOneWidget);
      expect(find.text('Terminar mi tiempo (Hecho)'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('BlackScreenDialog muestra mensaje tenue y se descarta tras 15 segundos', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BlackScreenDialog(),
          ),
        ),
      );
      await tester.pump();

      // Verificamos el texto exacto requerido
      expect(
        find.text('Tiempo iniciado.\nBloquea tu celular o colócalo boca abajo.\nNos vemos al terminar.'),
        findsOneWidget,
      );

      // Avanzamos 15 segundos
      await tester.pump(const Duration(seconds: 15));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(const SizedBox());
    });
  });
}
