import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tiempo_con_dios/core/database/app_database.dart';
import 'package:tiempo_con_dios/core/database/devocional_repository.dart';
import 'package:tiempo_con_dios/features/progress/presentation/progress_page.dart';
import 'package:tiempo_con_dios/features/progress/presentation/widgets/devocional_calendar.dart';
import 'package:tiempo_con_dios/features/progress/presentation/widgets/evolution_chart.dart';
import 'package:tiempo_con_dios/features/progress/presentation/widgets/metric_pill_card.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  testWidgets('ProgressPage muestra métricas, calendario y gráfica con datos reactivos', (tester) async {
    final now = DateTime.now();
    final mesActual = now.month.toString().padLeft(2, '0');
    final anioActual = now.year.toString();

    final testSesiones = [
      SesionDevocionalData(
        id: 1,
        fecha: '$anioActual-$mesActual-01',
        duracionMinutos: 25,
        registroManual: false,
        completado: true,
      ),
      SesionDevocionalData(
        id: 2,
        fecha: '$anioActual-$mesActual-03',
        duracionMinutos: 30,
        registroManual: true,
        completado: true,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          diasAcumuladosStreamProvider.overrideWith((ref) => Stream.value(15)),
          minutosMesStreamProvider.overrideWith((ref, arg) => Stream.value(55)),
          sesionesMesStreamProvider.overrideWith((ref, arg) => Stream.value(testSesiones)),
        ],
        child: const MaterialApp(
          home: ProgressPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verificamos títulos
    expect(find.text('Mi Progreso'), findsOneWidget);
    expect(find.text('Pequeños pasos, un hábito que crece.'), findsOneWidget);

    // Verificamos tarjetas de métricas
    expect(find.byType(MetricPillCard), findsNWidgets(2));
    expect(find.text('[15]'), findsOneWidget);
    expect(find.text('días de tiempo con Dios'), findsOneWidget);
    expect(find.text('[55]'), findsOneWidget);
    expect(find.text('minutos del mes'), findsOneWidget);

    // Verificamos presencia del calendario y la gráfica
    expect(find.byType(DevocionalCalendar), findsOneWidget);
    expect(find.byType(EvolutionChart), findsOneWidget);
    expect(find.text('Tu evolución'), findsOneWidget);

    // Verificamos botón de detalle del mes
    expect(find.text('Ver detalle del mes'), findsOneWidget);
  });

  testWidgets('Tocar un día del calendario abre ManualEntrySheet', (tester) async {
    final now = DateTime.now();
    final mesActual = now.month.toString().padLeft(2, '0');
    final anioActual = now.year.toString();

    final testSesiones = [
      SesionDevocionalData(
        id: 1,
        fecha: '$anioActual-$mesActual-05',
        duracionMinutos: 20,
        registroManual: false,
        completado: true,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          diasAcumuladosStreamProvider.overrideWith((ref) => Stream.value(8)),
          minutosMesStreamProvider.overrideWith((ref, arg) => Stream.value(20)),
          sesionesMesStreamProvider.overrideWith((ref, arg) => Stream.value(testSesiones)),
        ],
        child: const MaterialApp(
          home: ProgressPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Buscamos un día y lo tocamos
    final dayFinder = find.text('5').first;
    await tester.tap(dayFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // El modal de registro manual debe haberse abierto
    expect(find.text('Tiempo registrado'), findsOneWidget);
    expect(find.text('Duración del tiempo con Dios'), findsOneWidget);
    expect(find.text('Actualizar registro'), findsOneWidget);
  });
}
