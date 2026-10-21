import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiempo_con_dios/core/database/app_database.dart';
import 'package:tiempo_con_dios/core/database/devocional_repository.dart';
import 'package:tiempo_con_dios/core/utils/date_utils.dart';

void main() {
  late AppDatabase db;
  late DevocionalRepository repository;

  setUp(() {
    // Base de datos SQLite pura en memoria para pruebas aisladas
    db = AppDatabase(NativeDatabase.memory());
    repository = DevocionalRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Pruebas de Repositorio Devocional - Base de Datos Drift', () {
    test('Configuración por defecto (Singleton) se inicializa correctamente', () async {
      final config = await repository.obtenerConfiguracion();

      expect(config.nombreUsuario, 'Sebastian');
      expect(config.diasSemana, [1, 2, 3, 4, 5, 6, 7]);
      expect(config.horaDevocional, '07:00');
      expect(config.avisoPrevioActivo, false);
      expect(config.sesionActivaInicio, isNull);
    });

    test('Semilla inicial de actividades devocionales (Orar, Leer la Biblia, Escribir)', () async {
      final actividades = await repository.obtenerActividades();

      expect(actividades.length, 3);
      expect(actividades[0].titulo, 'Orar');
      expect(actividades[0].orden, 1);
      expect(actividades[1].titulo, 'Leer la Biblia');
      expect(actividades[1].orden, 2);
      expect(actividades[2].titulo, 'Escribir lo que me llamó la atención');
      expect(actividades[2].orden, 3);
    });

    test('Cronómetro por timestamp: guardarInicioSesion() y finalizarSesion() con cálculo de minutos', () async {
      final inicio = DateTime(2026, 10, 17, 7, 0);
      final fin = DateTime(2026, 10, 17, 7, 28); // 28 minutos

      // 1. Iniciar sesión
      await repository.guardarInicioSesion(inicio);
      var config = await repository.obtenerConfiguracion();
      expect(config.sesionActivaInicio, inicio);

      // 2. Finalizar sesión
      final minutos = await repository.finalizarSesion(fin);
      expect(minutos, 28);

      // 3. Verificar que sesionActivaInicio quedó en null
      config = await repository.obtenerConfiguracion();
      expect(config.sesionActivaInicio, isNull);

      // 4. Verificar que se guardó en SesionDevocional
      final historial = await repository.obtenerHistorialMes(2026, 10);
      expect(historial.length, 1);
      expect(historial.first.fecha, AppDateUtils.toYmd(fin));
      expect(historial.first.duracionMinutos, 28);
      expect(historial.first.registroManual, false);
      expect(historial.first.completado, true);
    });

    test('Múltiples sesiones en el mismo día acumulan los minutos devocionales', () async {
      // Sesión 1: 15 minutos en la mañana
      await repository.guardarInicioSesion(DateTime(2026, 10, 17, 7, 0));
      await repository.finalizarSesion(DateTime(2026, 10, 17, 7, 15));

      // Sesión 2: 20 minutos en la noche
      await repository.guardarInicioSesion(DateTime(2026, 10, 17, 21, 0));
      await repository.finalizarSesion(DateTime(2026, 10, 17, 21, 20));

      final historial = await repository.obtenerHistorialMes(2026, 10);
      expect(historial.length, 1); // Un solo registro para la fecha
      expect(historial.first.duracionMinutos, 35); // 15 + 20 minutos
    });

    test('cancelarSesion() apaga sesionActivaInicio sin registrar sesión', () async {
      await repository.guardarInicioSesion(DateTime(2026, 10, 17, 7, 0));
      await repository.cancelarSesion();

      final config = await repository.obtenerConfiguracion();
      expect(config.sesionActivaInicio, isNull);

      final historial = await repository.obtenerHistorialMes(2026, 10);
      expect(historial, isEmpty);
    });

    test('registrarDiaManual() y eliminarRegistroDia() operan retroactivamente', () async {
      final fechaPasada = DateTime(2026, 10, 5);

      // Registro manual de 25 minutos
      await repository.registrarDiaManual(fechaPasada, duracionMinutos: 25);
      var historial = await repository.obtenerHistorialMes(2026, 10);
      expect(historial.length, 1);
      expect(historial.first.registroManual, true);
      expect(historial.first.duracionMinutos, 25);

      // Eliminar el registro
      await repository.eliminarRegistroDia(fechaPasada);
      historial = await repository.obtenerHistorialMes(2026, 10);
      expect(historial, isEmpty);
    });

    test('calcularMinutosMes() y calcularDiasAcumulados()', () async {
      // Registramos 3 días en octubre 2026
      await repository.registrarDiaManual(DateTime(2026, 10, 1), duracionMinutos: 20);
      await repository.registrarDiaManual(DateTime(2026, 10, 2), duracionMinutos: 30);
      await repository.registrarDiaManual(DateTime(2026, 10, 3), duracionMinutos: 15);

      // Registramos 1 día en noviembre 2026
      await repository.registrarDiaManual(DateTime(2026, 11, 1), duracionMinutos: 40);

      final minutosOctubre = await repository.calcularMinutosMes(2026, 10);
      expect(minutosOctubre, 65); // 20 + 30 + 15

      final minutosNoviembre = await repository.calcularMinutosMes(2026, 11);
      expect(minutosNoviembre, 40);

      final totalDias = await repository.calcularDiasAcumulados();
      expect(totalDias, 4);
    });

    test('Reordenamiento de actividades: guardarOrdenActividades()', () async {
      final actividades = await repository.obtenerActividades();
      // Invertimos el orden: [Escribir, Leer, Orar]
      final reordenadas = [actividades[2], actividades[1], actividades[0]];
      await repository.guardarOrdenActividades(reordenadas);

      final actividadesActualizadas = await repository.obtenerActividades();
      expect(actividadesActualizadas[0].titulo, 'Escribir lo que me llamó la atención');
      expect(actividadesActualizadas[0].orden, 1);
      expect(actividadesActualizadas[1].titulo, 'Leer la Biblia');
      expect(actividadesActualizadas[1].orden, 2);
      expect(actividadesActualizadas[2].titulo, 'Orar');
      expect(actividadesActualizadas[2].orden, 3);
    });

    test('agregarActividad() y eliminarActividad()', () async {
      await repository.agregarActividad('Meditar en un salmo');
      var actividades = await repository.obtenerActividades();
      expect(actividades.length, 4);
      expect(actividades.last.titulo, 'Meditar en un salmo');
      expect(actividades.last.orden, 4);

      await repository.eliminarActividad(actividades.last.id);
      actividades = await repository.obtenerActividades();
      expect(actividades.length, 3);
    });
  });
}
