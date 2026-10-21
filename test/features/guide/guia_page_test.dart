import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiempo_con_dios/core/database/app_database.dart';
import 'package:tiempo_con_dios/core/database/devocional_repository.dart';
import 'package:tiempo_con_dios/features/guide/presentation/guia_page.dart';
import 'package:tiempo_con_dios/features/guide/presentation/widgets/cloud_step_card.dart';

void main() {
  const testActividades = [
    ActividadGuiaData(id: 1, titulo: 'Orar', orden: 1, activa: true),
    ActividadGuiaData(id: 2, titulo: 'Leer la Biblia', orden: 2, activa: true),
    ActividadGuiaData(id: 3, titulo: 'Escribir lo que me llamó la atención', orden: 3, activa: true),
  ];

  testWidgets('GuiaPage renderiza lista de actividades en forma de nube y botón agregar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          actividadesStreamProvider.overrideWith((ref) => Stream.value(testActividades)),
        ],
        child: const MaterialApp(
          home: GuiaPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verificamos títulos
    expect(find.text('Guía de hoy'), findsOneWidget);
    expect(find.text('Ordena tus pasos como Dios te guíe'), findsOneWidget);

    // Verificamos las 3 tarjetas de nube
    expect(find.byType(CloudStepCard), findsNWidgets(3));
    expect(find.text('01'), findsOneWidget);
    expect(find.text('Orar'), findsOneWidget);
    expect(find.text('02'), findsOneWidget);
    expect(find.text('Leer la Biblia'), findsOneWidget);
    expect(find.text('03'), findsOneWidget);
    expect(find.text('Escribir lo que me llamó la atención'), findsOneWidget);

    // Verificamos botón agregar y leyenda
    expect(find.text('Agregar actividad'), findsOneWidget);
    expect(find.text('Mantén presionado y desliza para cambiar el orden'), findsOneWidget);
    expect(find.text('Guardar orden'), findsOneWidget);
  });

  testWidgets('Tocar "+ Agregar actividad" abre el diálogo de creación', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          actividadesStreamProvider.overrideWith((ref) => Stream.value(testActividades)),
        ],
        child: const MaterialApp(
          home: GuiaPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tocamos el botón de agregar
    await tester.tap(find.text('Agregar actividad'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // El diálogo de nueva actividad debe aparecer
    expect(find.text('Nueva actividad'), findsOneWidget);
    expect(find.text('Agrega un paso a tu tiempo devocional:'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Agregar'), findsOneWidget);
  });
}
