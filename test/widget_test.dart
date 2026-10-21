import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiempo_con_dios/core/database/app_database.dart';
import 'package:tiempo_con_dios/core/database/devocional_repository.dart';
import 'package:tiempo_con_dios/features/home/presentation/home_page.dart';
import 'package:tiempo_con_dios/main.dart';

void main() {
  testWidgets('Navegación básica entre las 3 pestañas principales', (WidgetTester tester) async {
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

    // Montamos la aplicación con ProviderScope
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configuracionStreamProvider.overrideWith((ref) => Stream.value(defaultConfig)),
          diasAcumuladosStreamProvider.overrideWith((ref) => Stream.value(12)),
          sesionesMesStreamProvider.overrideWith((ref, arg) => Stream.value([])),
          estadoLlamaVivaProvider.overrideWith((ref) => Future.value(true)),
          actividadesStreamProvider.overrideWith((ref) => Stream.value([
            const ActividadGuiaData(id: 1, titulo: 'Orar', orden: 1, activa: true),
            const ActividadGuiaData(id: 2, titulo: 'Leer la Biblia', orden: 2, activa: true),
            const ActividadGuiaData(id: 3, titulo: 'Escribir lo que me llamó la atención', orden: 3, activa: true),
          ])),
        ],
        child: const TiempoConDiosApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verificamos que arranca en la pestaña Inicio con la tarjeta principal
    expect(find.text('Tiempo con Dios\nde hoy'), findsOneWidget);
    expect(find.text('Empezar mi tiempo'), findsOneWidget);

    // Tocamos la pestaña "Mi Progreso"
    await tester.tap(find.text('Mi Progreso'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verificamos que se muestra el título de Mi Progreso
    expect(find.text('Mi Progreso'), findsOneWidget);
    expect(find.text('Pequeños pasos, un hábito que crece.'), findsOneWidget);

    // Tocamos la pestaña "Guía"
    await tester.tap(find.text('Guía'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verificamos que se muestra el título de Guía de hoy y las actividades
    expect(find.text('Guía de hoy'), findsOneWidget);
    expect(find.text('Orar'), findsOneWidget);
    expect(find.text('Guardar orden'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
