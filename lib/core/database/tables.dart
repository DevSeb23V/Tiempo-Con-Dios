import 'dart:convert';
import 'package:drift/drift.dart';

/// Convertidor para almacenar una lista de enteros (días de la semana 1-7) como JSON en SQLite.
class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    try {
      final decoded = json.decode(fromDb);
      if (decoded is List) {
        return decoded.map((e) => (e as num).toInt()).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  String toSql(List<int> value) {
    return json.encode(value);
  }
}

/// Tabla: ConfiguracionUsuario (Registro único / Singleton)
/// Almacena las preferencias del usuario, horarios y el timestamp de sesión activa si la hay.
@DataClassName('ConfiguracionUsuarioData')
class ConfiguracionUsuarioTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Nombre del usuario para el saludo personalizado (ej: "Sebastian")
  TextColumn get nombreUsuario => text().withDefault(const Constant('Sebastian'))();

  /// Días seleccionados para devocional (1 = Lunes, 7 = Domingo)
  TextColumn get diasSemana => text()
      .map(const IntListConverter())
      .withDefault(const Constant('[1,2,3,4,5,6,7]'))();

  /// Hora pactada del devocional en formato 24h 'HH:mm' (ej: '07:00')
  TextColumn get horaDevocional => text().withDefault(const Constant('07:00'))();

  /// Hora del aviso previo o null si está inactivo (ej: '21:30' o '06:30')
  TextColumn get horaAvisoPrevio => text().nullable()();

  /// Indica si el aviso previo está habilitado
  BoolColumn get avisoPrevioActivo => boolean().withDefault(const Constant(false))();

  /// Timestamp exacto de inicio si hay una sesión activa en curso; null si no hay sesión.
  /// Este valor sobrevive a que Android cierre la app o se reinicie el dispositivo.
  DateTimeColumn get sesionActivaInicio => dateTime().nullable()();

  /// Indica si el usuario ya completó el flujo de bienvenida / onboarding inicial
  BoolColumn get onboardingCompletado => boolean().withDefault(const Constant(false))();
}

/// Tabla: SesionDevocional (Historial diario)
/// Almacena cada tiempo devocional completado con fecha indexada y minutos calculados.
@DataClassName('SesionDevocionalData')
@TableIndex(name: 'idx_sesion_fecha', columns: {#fecha})
class SesionDevocionalTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Fecha en formato 'YYYY-MM-DD' para consultas directas y búsquedas en calendario
  TextColumn get fecha => text()();

  /// Duración real transcurrida en minutos
  IntColumn get duracionMinutos => integer().withDefault(const Constant(0))();

  /// True si el devocional se marcó manualmente en el calendario; false si fue con temporizador
  BoolColumn get registroManual => boolean().withDefault(const Constant(false))();

  /// Indica si la sesión fue completada satisfactoriamente
  BoolColumn get completado => boolean().withDefault(const Constant(true))();
}

/// Tabla: ActividadGuia
/// Pasos devocionales sugeridos o personalizados por el usuario (ej: Orar, Leer la Biblia).
@DataClassName('ActividadGuiaData')
class ActividadGuiaTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Título de la actividad (ej: "Orar", "Leer la Biblia")
  TextColumn get titulo => text()();

  /// Orden secuencial para el reordenamiento por arrastre
  IntColumn get orden => integer()();

  /// Indica si la actividad está activa en la guía diaria
  BoolColumn get activa => boolean().withDefault(const Constant(true))();
}
