import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

/// Base de datos SQLite local-first tipada de "Tiempo con Dios" usando Drift.
@DriftDatabase(tables: [
  ConfiguracionUsuarioTable,
  SesionDevocionalTable,
  ActividadGuiaTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();

          // Semilla inicial: Configuración de usuario por defecto (Singleton)
          await into(configuracionUsuarioTable).insert(
            ConfiguracionUsuarioTableCompanion.insert(
              nombreUsuario: const Value('Sebastian'),
              diasSemana: const Value([1, 2, 3, 4, 5, 6, 7]),
              horaDevocional: const Value('07:00'),
              avisoPrevioActivo: const Value(false),
              onboardingCompletado: const Value(true),
            ),
          );

          // Semilla inicial: 3 actividades devocionales por defecto
          await batch((b) {
            b.insertAll(actividadGuiaTable, [
              ActividadGuiaTableCompanion.insert(
                titulo: 'Orar',
                orden: 1,
              ),
              ActividadGuiaTableCompanion.insert(
                titulo: 'Leer la Biblia',
                orden: 2,
              ),
              ActividadGuiaTableCompanion.insert(
                titulo: 'Escribir lo que me llamó la atención',
                orden: 3,
              ),
            ]);
          });
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(configuracionUsuarioTable, configuracionUsuarioTable.onboardingCompletado);
          }
        },
      );
}

/// Crea la conexión nativa a la base de datos SQLite en el almacenamiento seguro de la app.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tiempo_con_dios.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
