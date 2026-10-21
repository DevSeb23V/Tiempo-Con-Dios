import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/date_utils.dart';
import 'app_database.dart';

/// Proveedor global de la base de datos local SQLite.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Proveedor del repositorio devocional.
final devocionalRepositoryProvider = Provider<DevocionalRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DevocionalRepository(db);
});

/// Stream reactivo de la configuración única del usuario.
final configuracionStreamProvider = StreamProvider<ConfiguracionUsuarioData>((ref) {
  final repo = ref.watch(devocionalRepositoryProvider);
  return repo.vigilarConfiguracion();
});

/// Stream reactivo de las actividades de la guía ordenadas.
final actividadesStreamProvider = StreamProvider<List<ActividadGuiaData>>((ref) {
  final repo = ref.watch(devocionalRepositoryProvider);
  return repo.vigilarActividades();
});

/// Stream reactivo de días devocionales acumulados en total.
final diasAcumuladosStreamProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(devocionalRepositoryProvider);
  return repo.vigilarDiasAcumulados();
});

/// Stream reactivo del historial de sesiones de un mes específico.
final sesionesMesStreamProvider = StreamProvider.family<List<SesionDevocionalData>, ({int anio, int mes})>((ref, arg) {
  final repo = ref.watch(devocionalRepositoryProvider);
  return repo.vigilarHistorialMes(arg.anio, arg.mes);
});

/// Stream reactivo de minutos acumulados en el mes.
final minutosMesStreamProvider = StreamProvider.family<int, ({int anio, int mes})>((ref, arg) {
  final repo = ref.watch(devocionalRepositoryProvider);
  return repo.vigilarMinutosMes(arg.anio, arg.mes);
});

/// Repositorio de acceso a datos de "Tiempo con Dios".
/// Encapsula todas las operaciones de Drift de forma desacoplada y robusta.
class DevocionalRepository {
  final AppDatabase _db;

  DevocionalRepository(this._db);

  // ---------------------------------------------------------------------------
  // CONFIGURACIÓN DEL USUARIO (Singleton)
  // ---------------------------------------------------------------------------

  /// Obtiene la configuración del usuario. Si no existe, inicializa una por defecto.
  Future<ConfiguracionUsuarioData> obtenerConfiguracion() async {
    final query = _db.select(_db.configuracionUsuarioTable)..limit(1);
    final config = await query.getSingleOrNull();
    if (config != null) return config;

    // Crea el registro único inicial
    await _db.into(_db.configuracionUsuarioTable).insert(
      ConfiguracionUsuarioTableCompanion.insert(
        nombreUsuario: const Value('Sebastian'),
        diasSemana: const Value([1, 2, 3, 4, 5, 6, 7]),
        horaDevocional: const Value('07:00'),
        avisoPrevioActivo: const Value(false),
        onboardingCompletado: const Value(false),
      ),
    );
    return await (_db.select(_db.configuracionUsuarioTable)..limit(1)).getSingle();
  }

  /// Observa en tiempo real cambios en la configuración.
  Stream<ConfiguracionUsuarioData> vigilarConfiguracion() {
    return (_db.select(_db.configuracionUsuarioTable)..limit(1))
        .watchSingle();
  }

  /// Actualiza los campos de configuración del usuario (nombre, horas, días, etc.)
  Future<void> actualizarConfiguracion(ConfiguracionUsuarioTableCompanion companion) async {
    final config = await obtenerConfiguracion();
    await (_db.update(_db.configuracionUsuarioTable)
          ..where((t) => t.id.equals(config.id)))
        .write(companion);
  }

  /// Guarda las respuestas del flujo de Onboarding inicial y lo marca como completado.
  Future<void> completarOnboarding({
    required String nombre,
    required List<int> dias,
    required String horaDevocional,
    required bool avisoPrevio,
    String? horaAviso,
  }) async {
    final config = await obtenerConfiguracion();
    await (_db.update(_db.configuracionUsuarioTable)
          ..where((t) => t.id.equals(config.id)))
        .write(
      ConfiguracionUsuarioTableCompanion(
        nombreUsuario: Value(nombre),
        diasSemana: Value(dias),
        horaDevocional: Value(horaDevocional),
        avisoPrevioActivo: Value(avisoPrevio),
        horaAvisoPrevio: Value(horaAviso),
        onboardingCompletado: const Value(true),
      ),
    );
  }

  /// Restablece el estado de onboarding a no completado para poder volver a probarlo.
  Future<void> restablecerOnboarding() async {
    final config = await obtenerConfiguracion();
    await (_db.update(_db.configuracionUsuarioTable)
          ..where((t) => t.id.equals(config.id)))
        .write(
      const ConfiguracionUsuarioTableCompanion(
        onboardingCompletado: Value(false),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTROL DE SESIÓN DEVOCIONAL (Cronómetro basado en Timestamps)
  // ---------------------------------------------------------------------------

  /// Guarda la marca de tiempo de inicio en la base de datos.
  /// No utiliza temporizadores en memoria; sobrevive a reinicios y al Doze Mode de Android.
  Future<void> guardarInicioSesion([DateTime? fechaInicio]) async {
    final inicio = fechaInicio ?? DateTime.now();
    final config = await obtenerConfiguracion();
    await (_db.update(_db.configuracionUsuarioTable)
          ..where((t) => t.id.equals(config.id)))
        .write(
      ConfiguracionUsuarioTableCompanion(
        sesionActivaInicio: Value(inicio),
      ),
    );
  }

  /// Cancela la sesión activa actual sin registrar minutos.
  Future<void> cancelarSesion() async {
    final config = await obtenerConfiguracion();
    await (_db.update(_db.configuracionUsuarioTable)
          ..where((t) => t.id.equals(config.id)))
        .write(
      const ConfiguracionUsuarioTableCompanion(
        sesionActivaInicio: Value(null),
      ),
    );
  }

  /// Finaliza la sesión activa: calcula los minutos transcurridos respecto al timestamp guardado,
  /// registra la sesión en `SesionDevocional` y apaga el estado activo.
  /// Retorna la cantidad de minutos computados (mínimo 1 minuto).
  Future<int> finalizarSesion([DateTime? fechaFin]) async {
    final config = await obtenerConfiguracion();
    final inicio = config.sesionActivaInicio;
    final fin = fechaFin ?? DateTime.now();

    // Si no había sesión iniciada, consideramos una sesión mínima de 1 minuto
    int minutos = 1;
    if (inicio != null) {
      final diff = fin.difference(inicio).inMinutes;
      minutos = diff <= 0 ? 1 : diff;
    }

    final fechaYmd = AppDateUtils.toYmd(fin);

    // Verificamos si ya existe una sesión en la misma fecha para acumular o actualizar
    final sesionExistente = await (_db.select(_db.sesionDevocionalTable)
          ..where((t) => t.fecha.equals(fechaYmd)))
        .getSingleOrNull();

    if (sesionExistente != null) {
      await (_db.update(_db.sesionDevocionalTable)
            ..where((t) => t.id.equals(sesionExistente.id)))
          .write(
        SesionDevocionalTableCompanion(
          duracionMinutos: Value(sesionExistente.duracionMinutos + minutos),
          completado: const Value(true),
        ),
      );
    } else {
      await _db.into(_db.sesionDevocionalTable).insert(
        SesionDevocionalTableCompanion.insert(
          fecha: fechaYmd,
          duracionMinutos: Value(minutos),
          registroManual: const Value(false),
          completado: const Value(true),
        ),
      );
    }

    // Apagamos la sesión activa en la configuración
    await (_db.update(_db.configuracionUsuarioTable)
          ..where((t) => t.id.equals(config.id)))
        .write(
      const ConfiguracionUsuarioTableCompanion(
        sesionActivaInicio: Value(null),
      ),
    );

    return minutos;
  }

  // ---------------------------------------------------------------------------
  // REGISTRO MANUAL Y CONSULTAS DE HISTORIAL
  // ---------------------------------------------------------------------------

  /// Registra o actualiza manualmente un día devocional pasado en el calendario.
  Future<void> registrarDiaManual(DateTime fecha, {int duracionMinutos = 15}) async {
    final fechaYmd = AppDateUtils.toYmd(fecha);
    final sesionExistente = await (_db.select(_db.sesionDevocionalTable)
          ..where((t) => t.fecha.equals(fechaYmd)))
        .getSingleOrNull();

    if (sesionExistente != null) {
      await (_db.update(_db.sesionDevocionalTable)
            ..where((t) => t.id.equals(sesionExistente.id)))
          .write(
        SesionDevocionalTableCompanion(
          duracionMinutos: Value(duracionMinutos),
          registroManual: const Value(true),
          completado: const Value(true),
        ),
      );
    } else {
      await _db.into(_db.sesionDevocionalTable).insert(
        SesionDevocionalTableCompanion.insert(
          fecha: fechaYmd,
          duracionMinutos: Value(duracionMinutos),
          registroManual: const Value(true),
          completado: const Value(true),
        ),
      );
    }
  }

  /// Elimina el registro devocional de una fecha determinada.
  Future<void> eliminarRegistroDia(DateTime fecha) async {
    final fechaYmd = AppDateUtils.toYmd(fecha);
    await (_db.delete(_db.sesionDevocionalTable)
          ..where((t) => t.fecha.equals(fechaYmd)))
        .go();
  }

  /// Obtiene las sesiones devocionales completadas en un mes y año específico.
  Future<List<SesionDevocionalData>> obtenerHistorialMes(int anio, int mes) async {
    final mesPrefijo = '$anio-${mes.toString().padLeft(2, '0')}';
    return await (_db.select(_db.sesionDevocionalTable)
          ..where((t) => t.fecha.like('$mesPrefijo%') & t.completado.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
        .get();
  }

  /// Observa en tiempo real las sesiones devocionales de un mes específico.
  Stream<List<SesionDevocionalData>> vigilarHistorialMes(int anio, int mes) {
    final mesPrefijo = '$anio-${mes.toString().padLeft(2, '0')}';
    return (_db.select(_db.sesionDevocionalTable)
          ..where((t) => t.fecha.like('$mesPrefijo%') & t.completado.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
        .watch();
  }

  /// Calcula la suma total de minutos acumulados en el mes en curso o especificado.
  Future<int> calcularMinutosMes([int? anio, int? mes]) async {
    final now = DateTime.now();
    final targetYear = anio ?? now.year;
    final targetMonth = mes ?? now.month;
    final sesiones = await obtenerHistorialMes(targetYear, targetMonth);
    return sesiones.fold<int>(0, (sum, s) => sum + s.duracionMinutos);
  }

  /// Observa en tiempo real los minutos del mes.
  Stream<int> vigilarMinutosMes([int? anio, int? mes]) {
    final now = DateTime.now();
    final targetYear = anio ?? now.year;
    final targetMonth = mes ?? now.month;
    return vigilarHistorialMes(targetYear, targetMonth).map(
      (sesiones) => sesiones.fold<int>(0, (sum, s) => sum + s.duracionMinutos),
    );
  }

  /// Calcula la cantidad total de días completados en la historia del usuario.
  Future<int> calcularDiasAcumulados() async {
    final query = _db.selectOnly(_db.sesionDevocionalTable)
      ..where(_db.sesionDevocionalTable.completado.equals(true))
      ..addColumns([_db.sesionDevocionalTable.id.count()]);
    final result = await query.getSingle();
    return result.read(_db.sesionDevocionalTable.id.count()) ?? 0;
  }

  /// Observa en tiempo real el total de días acumulados.
  Stream<int> vigilarDiasAcumulados() {
    final countCol = _db.sesionDevocionalTable.id.count();
    final query = _db.selectOnly(_db.sesionDevocionalTable)
      ..where(_db.sesionDevocionalTable.completado.equals(true))
      ..addColumns([countCol]);
    return query.watchSingle().map((row) => row.read(countCol) ?? 0);
  }

  /// Obtiene la fecha más reciente en que se completó un devocional.
  Future<DateTime?> obtenerUltimoRegistro() async {
    final query = _db.select(_db.sesionDevocionalTable)
      ..where((t) => t.completado.equals(true))
      ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
      ..limit(1);
    final sesion = await query.getSingleOrNull();
    if (sesion == null) return null;
    return AppDateUtils.fromYmd(sesion.fecha);
  }

  // ---------------------------------------------------------------------------
  // GUÍA DE ACTIVIDADES DEVOCIONALES
  // ---------------------------------------------------------------------------

  /// Obtiene todas las actividades devocionales ordenadas por su campo `orden`.
  Future<List<ActividadGuiaData>> obtenerActividades() async {
    return await (_db.select(_db.actividadGuiaTable)
          ..where((t) => t.activa.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.orden)]))
        .get();
  }

  /// Observa en tiempo real la lista de actividades ordenadas.
  Stream<List<ActividadGuiaData>> vigilarActividades() {
    return (_db.select(_db.actividadGuiaTable)
          ..where((t) => t.activa.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.orden)]))
        .watch();
  }

  /// Guarda el nuevo orden de actividades tras una acción de arrastrar y soltar (drag & drop).
  Future<void> guardarOrdenActividades(List<ActividadGuiaData> actividades) async {
    await _db.batch((b) {
      for (int i = 0; i < actividades.length; i++) {
        final actividad = actividades[i];
        final nuevoOrden = i + 1;
        b.update(
          _db.actividadGuiaTable,
          ActividadGuiaTableCompanion(orden: Value(nuevoOrden)),
          where: (t) => t.id.equals(actividad.id),
        );
      }
    });
  }

  /// Agrega una nueva actividad devocional al final de la lista.
  Future<int> agregarActividad(String titulo) async {
    final actividades = await obtenerActividades();
    final nuevoOrden = actividades.isEmpty ? 1 : (actividades.map((a) => a.orden).reduce((a, b) => a > b ? a : b) + 1);

    return await _db.into(_db.actividadGuiaTable).insert(
      ActividadGuiaTableCompanion.insert(
        titulo: titulo.trim(),
        orden: nuevoOrden,
        activa: const Value(true),
      ),
    );
  }

  /// Elimina una actividad devocional por su identificador.
  Future<void> eliminarActividad(int id) async {
    await (_db.delete(_db.actividadGuiaTable)..where((t) => t.id.equals(id))).go();
  }
}
