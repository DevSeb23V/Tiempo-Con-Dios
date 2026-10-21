// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ConfiguracionUsuarioTableTable extends ConfiguracionUsuarioTable
    with TableInfo<$ConfiguracionUsuarioTableTable, ConfiguracionUsuarioData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfiguracionUsuarioTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nombreUsuarioMeta =
      const VerificationMeta('nombreUsuario');
  @override
  late final GeneratedColumn<String> nombreUsuario = GeneratedColumn<String>(
      'nombre_usuario', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Sebastian'));
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> diasSemana =
      GeneratedColumn<String>('dias_semana', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[1,2,3,4,5,6,7]'))
          .withConverter<List<int>>(
              $ConfiguracionUsuarioTableTable.$converterdiasSemana);
  static const VerificationMeta _horaDevocionalMeta =
      const VerificationMeta('horaDevocional');
  @override
  late final GeneratedColumn<String> horaDevocional = GeneratedColumn<String>(
      'hora_devocional', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('07:00'));
  static const VerificationMeta _horaAvisoPrevioMeta =
      const VerificationMeta('horaAvisoPrevio');
  @override
  late final GeneratedColumn<String> horaAvisoPrevio = GeneratedColumn<String>(
      'hora_aviso_previo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avisoPrevioActivoMeta =
      const VerificationMeta('avisoPrevioActivo');
  @override
  late final GeneratedColumn<bool> avisoPrevioActivo = GeneratedColumn<bool>(
      'aviso_previo_activo', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("aviso_previo_activo" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sesionActivaInicioMeta =
      const VerificationMeta('sesionActivaInicio');
  @override
  late final GeneratedColumn<DateTime> sesionActivaInicio =
      GeneratedColumn<DateTime>('sesion_activa_inicio', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _onboardingCompletadoMeta =
      const VerificationMeta('onboardingCompletado');
  @override
  late final GeneratedColumn<bool> onboardingCompletado = GeneratedColumn<bool>(
      'onboarding_completado', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("onboarding_completado" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nombreUsuario,
        diasSemana,
        horaDevocional,
        horaAvisoPrevio,
        avisoPrevioActivo,
        sesionActivaInicio,
        onboardingCompletado
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configuracion_usuario_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ConfiguracionUsuarioData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre_usuario')) {
      context.handle(
          _nombreUsuarioMeta,
          nombreUsuario.isAcceptableOrUnknown(
              data['nombre_usuario']!, _nombreUsuarioMeta));
    }
    if (data.containsKey('hora_devocional')) {
      context.handle(
          _horaDevocionalMeta,
          horaDevocional.isAcceptableOrUnknown(
              data['hora_devocional']!, _horaDevocionalMeta));
    }
    if (data.containsKey('hora_aviso_previo')) {
      context.handle(
          _horaAvisoPrevioMeta,
          horaAvisoPrevio.isAcceptableOrUnknown(
              data['hora_aviso_previo']!, _horaAvisoPrevioMeta));
    }
    if (data.containsKey('aviso_previo_activo')) {
      context.handle(
          _avisoPrevioActivoMeta,
          avisoPrevioActivo.isAcceptableOrUnknown(
              data['aviso_previo_activo']!, _avisoPrevioActivoMeta));
    }
    if (data.containsKey('sesion_activa_inicio')) {
      context.handle(
          _sesionActivaInicioMeta,
          sesionActivaInicio.isAcceptableOrUnknown(
              data['sesion_activa_inicio']!, _sesionActivaInicioMeta));
    }
    if (data.containsKey('onboarding_completado')) {
      context.handle(
          _onboardingCompletadoMeta,
          onboardingCompletado.isAcceptableOrUnknown(
              data['onboarding_completado']!, _onboardingCompletadoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConfiguracionUsuarioData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfiguracionUsuarioData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nombreUsuario: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre_usuario'])!,
      diasSemana: $ConfiguracionUsuarioTableTable.$converterdiasSemana.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}dias_semana'])!),
      horaDevocional: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}hora_devocional'])!,
      horaAvisoPrevio: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}hora_aviso_previo']),
      avisoPrevioActivo: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}aviso_previo_activo'])!,
      sesionActivaInicio: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}sesion_activa_inicio']),
      onboardingCompletado: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}onboarding_completado'])!,
    );
  }

  @override
  $ConfiguracionUsuarioTableTable createAlias(String alias) {
    return $ConfiguracionUsuarioTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<int>, String> $converterdiasSemana =
      const IntListConverter();
}

class ConfiguracionUsuarioData extends DataClass
    implements Insertable<ConfiguracionUsuarioData> {
  final int id;

  /// Nombre del usuario para el saludo personalizado (ej: "Sebastian")
  final String nombreUsuario;

  /// Días seleccionados para devocional (1 = Lunes, 7 = Domingo)
  final List<int> diasSemana;

  /// Hora pactada del devocional en formato 24h 'HH:mm' (ej: '07:00')
  final String horaDevocional;

  /// Hora del aviso previo o null si está inactivo (ej: '21:30' o '06:30')
  final String? horaAvisoPrevio;

  /// Indica si el aviso previo está habilitado
  final bool avisoPrevioActivo;

  /// Timestamp exacto de inicio si hay una sesión activa en curso; null si no hay sesión.
  /// Este valor sobrevive a que Android cierre la app o se reinicie el dispositivo.
  final DateTime? sesionActivaInicio;

  /// Indica si el usuario ya completó el flujo de bienvenida / onboarding inicial
  final bool onboardingCompletado;
  const ConfiguracionUsuarioData(
      {required this.id,
      required this.nombreUsuario,
      required this.diasSemana,
      required this.horaDevocional,
      this.horaAvisoPrevio,
      required this.avisoPrevioActivo,
      this.sesionActivaInicio,
      required this.onboardingCompletado});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre_usuario'] = Variable<String>(nombreUsuario);
    {
      map['dias_semana'] = Variable<String>($ConfiguracionUsuarioTableTable
          .$converterdiasSemana
          .toSql(diasSemana));
    }
    map['hora_devocional'] = Variable<String>(horaDevocional);
    if (!nullToAbsent || horaAvisoPrevio != null) {
      map['hora_aviso_previo'] = Variable<String>(horaAvisoPrevio);
    }
    map['aviso_previo_activo'] = Variable<bool>(avisoPrevioActivo);
    if (!nullToAbsent || sesionActivaInicio != null) {
      map['sesion_activa_inicio'] = Variable<DateTime>(sesionActivaInicio);
    }
    map['onboarding_completado'] = Variable<bool>(onboardingCompletado);
    return map;
  }

  ConfiguracionUsuarioTableCompanion toCompanion(bool nullToAbsent) {
    return ConfiguracionUsuarioTableCompanion(
      id: Value(id),
      nombreUsuario: Value(nombreUsuario),
      diasSemana: Value(diasSemana),
      horaDevocional: Value(horaDevocional),
      horaAvisoPrevio: horaAvisoPrevio == null && nullToAbsent
          ? const Value.absent()
          : Value(horaAvisoPrevio),
      avisoPrevioActivo: Value(avisoPrevioActivo),
      sesionActivaInicio: sesionActivaInicio == null && nullToAbsent
          ? const Value.absent()
          : Value(sesionActivaInicio),
      onboardingCompletado: Value(onboardingCompletado),
    );
  }

  factory ConfiguracionUsuarioData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfiguracionUsuarioData(
      id: serializer.fromJson<int>(json['id']),
      nombreUsuario: serializer.fromJson<String>(json['nombreUsuario']),
      diasSemana: serializer.fromJson<List<int>>(json['diasSemana']),
      horaDevocional: serializer.fromJson<String>(json['horaDevocional']),
      horaAvisoPrevio: serializer.fromJson<String?>(json['horaAvisoPrevio']),
      avisoPrevioActivo: serializer.fromJson<bool>(json['avisoPrevioActivo']),
      sesionActivaInicio:
          serializer.fromJson<DateTime?>(json['sesionActivaInicio']),
      onboardingCompletado:
          serializer.fromJson<bool>(json['onboardingCompletado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombreUsuario': serializer.toJson<String>(nombreUsuario),
      'diasSemana': serializer.toJson<List<int>>(diasSemana),
      'horaDevocional': serializer.toJson<String>(horaDevocional),
      'horaAvisoPrevio': serializer.toJson<String?>(horaAvisoPrevio),
      'avisoPrevioActivo': serializer.toJson<bool>(avisoPrevioActivo),
      'sesionActivaInicio': serializer.toJson<DateTime?>(sesionActivaInicio),
      'onboardingCompletado': serializer.toJson<bool>(onboardingCompletado),
    };
  }

  ConfiguracionUsuarioData copyWith(
          {int? id,
          String? nombreUsuario,
          List<int>? diasSemana,
          String? horaDevocional,
          Value<String?> horaAvisoPrevio = const Value.absent(),
          bool? avisoPrevioActivo,
          Value<DateTime?> sesionActivaInicio = const Value.absent(),
          bool? onboardingCompletado}) =>
      ConfiguracionUsuarioData(
        id: id ?? this.id,
        nombreUsuario: nombreUsuario ?? this.nombreUsuario,
        diasSemana: diasSemana ?? this.diasSemana,
        horaDevocional: horaDevocional ?? this.horaDevocional,
        horaAvisoPrevio: horaAvisoPrevio.present
            ? horaAvisoPrevio.value
            : this.horaAvisoPrevio,
        avisoPrevioActivo: avisoPrevioActivo ?? this.avisoPrevioActivo,
        sesionActivaInicio: sesionActivaInicio.present
            ? sesionActivaInicio.value
            : this.sesionActivaInicio,
        onboardingCompletado: onboardingCompletado ?? this.onboardingCompletado,
      );
  ConfiguracionUsuarioData copyWithCompanion(
      ConfiguracionUsuarioTableCompanion data) {
    return ConfiguracionUsuarioData(
      id: data.id.present ? data.id.value : this.id,
      nombreUsuario: data.nombreUsuario.present
          ? data.nombreUsuario.value
          : this.nombreUsuario,
      diasSemana:
          data.diasSemana.present ? data.diasSemana.value : this.diasSemana,
      horaDevocional: data.horaDevocional.present
          ? data.horaDevocional.value
          : this.horaDevocional,
      horaAvisoPrevio: data.horaAvisoPrevio.present
          ? data.horaAvisoPrevio.value
          : this.horaAvisoPrevio,
      avisoPrevioActivo: data.avisoPrevioActivo.present
          ? data.avisoPrevioActivo.value
          : this.avisoPrevioActivo,
      sesionActivaInicio: data.sesionActivaInicio.present
          ? data.sesionActivaInicio.value
          : this.sesionActivaInicio,
      onboardingCompletado: data.onboardingCompletado.present
          ? data.onboardingCompletado.value
          : this.onboardingCompletado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracionUsuarioData(')
          ..write('id: $id, ')
          ..write('nombreUsuario: $nombreUsuario, ')
          ..write('diasSemana: $diasSemana, ')
          ..write('horaDevocional: $horaDevocional, ')
          ..write('horaAvisoPrevio: $horaAvisoPrevio, ')
          ..write('avisoPrevioActivo: $avisoPrevioActivo, ')
          ..write('sesionActivaInicio: $sesionActivaInicio, ')
          ..write('onboardingCompletado: $onboardingCompletado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      nombreUsuario,
      diasSemana,
      horaDevocional,
      horaAvisoPrevio,
      avisoPrevioActivo,
      sesionActivaInicio,
      onboardingCompletado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfiguracionUsuarioData &&
          other.id == this.id &&
          other.nombreUsuario == this.nombreUsuario &&
          other.diasSemana == this.diasSemana &&
          other.horaDevocional == this.horaDevocional &&
          other.horaAvisoPrevio == this.horaAvisoPrevio &&
          other.avisoPrevioActivo == this.avisoPrevioActivo &&
          other.sesionActivaInicio == this.sesionActivaInicio &&
          other.onboardingCompletado == this.onboardingCompletado);
}

class ConfiguracionUsuarioTableCompanion
    extends UpdateCompanion<ConfiguracionUsuarioData> {
  final Value<int> id;
  final Value<String> nombreUsuario;
  final Value<List<int>> diasSemana;
  final Value<String> horaDevocional;
  final Value<String?> horaAvisoPrevio;
  final Value<bool> avisoPrevioActivo;
  final Value<DateTime?> sesionActivaInicio;
  final Value<bool> onboardingCompletado;
  const ConfiguracionUsuarioTableCompanion({
    this.id = const Value.absent(),
    this.nombreUsuario = const Value.absent(),
    this.diasSemana = const Value.absent(),
    this.horaDevocional = const Value.absent(),
    this.horaAvisoPrevio = const Value.absent(),
    this.avisoPrevioActivo = const Value.absent(),
    this.sesionActivaInicio = const Value.absent(),
    this.onboardingCompletado = const Value.absent(),
  });
  ConfiguracionUsuarioTableCompanion.insert({
    this.id = const Value.absent(),
    this.nombreUsuario = const Value.absent(),
    this.diasSemana = const Value.absent(),
    this.horaDevocional = const Value.absent(),
    this.horaAvisoPrevio = const Value.absent(),
    this.avisoPrevioActivo = const Value.absent(),
    this.sesionActivaInicio = const Value.absent(),
    this.onboardingCompletado = const Value.absent(),
  });
  static Insertable<ConfiguracionUsuarioData> custom({
    Expression<int>? id,
    Expression<String>? nombreUsuario,
    Expression<String>? diasSemana,
    Expression<String>? horaDevocional,
    Expression<String>? horaAvisoPrevio,
    Expression<bool>? avisoPrevioActivo,
    Expression<DateTime>? sesionActivaInicio,
    Expression<bool>? onboardingCompletado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombreUsuario != null) 'nombre_usuario': nombreUsuario,
      if (diasSemana != null) 'dias_semana': diasSemana,
      if (horaDevocional != null) 'hora_devocional': horaDevocional,
      if (horaAvisoPrevio != null) 'hora_aviso_previo': horaAvisoPrevio,
      if (avisoPrevioActivo != null) 'aviso_previo_activo': avisoPrevioActivo,
      if (sesionActivaInicio != null)
        'sesion_activa_inicio': sesionActivaInicio,
      if (onboardingCompletado != null)
        'onboarding_completado': onboardingCompletado,
    });
  }

  ConfiguracionUsuarioTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? nombreUsuario,
      Value<List<int>>? diasSemana,
      Value<String>? horaDevocional,
      Value<String?>? horaAvisoPrevio,
      Value<bool>? avisoPrevioActivo,
      Value<DateTime?>? sesionActivaInicio,
      Value<bool>? onboardingCompletado}) {
    return ConfiguracionUsuarioTableCompanion(
      id: id ?? this.id,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      diasSemana: diasSemana ?? this.diasSemana,
      horaDevocional: horaDevocional ?? this.horaDevocional,
      horaAvisoPrevio: horaAvisoPrevio ?? this.horaAvisoPrevio,
      avisoPrevioActivo: avisoPrevioActivo ?? this.avisoPrevioActivo,
      sesionActivaInicio: sesionActivaInicio ?? this.sesionActivaInicio,
      onboardingCompletado: onboardingCompletado ?? this.onboardingCompletado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombreUsuario.present) {
      map['nombre_usuario'] = Variable<String>(nombreUsuario.value);
    }
    if (diasSemana.present) {
      map['dias_semana'] = Variable<String>($ConfiguracionUsuarioTableTable
          .$converterdiasSemana
          .toSql(diasSemana.value));
    }
    if (horaDevocional.present) {
      map['hora_devocional'] = Variable<String>(horaDevocional.value);
    }
    if (horaAvisoPrevio.present) {
      map['hora_aviso_previo'] = Variable<String>(horaAvisoPrevio.value);
    }
    if (avisoPrevioActivo.present) {
      map['aviso_previo_activo'] = Variable<bool>(avisoPrevioActivo.value);
    }
    if (sesionActivaInicio.present) {
      map['sesion_activa_inicio'] =
          Variable<DateTime>(sesionActivaInicio.value);
    }
    if (onboardingCompletado.present) {
      map['onboarding_completado'] = Variable<bool>(onboardingCompletado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracionUsuarioTableCompanion(')
          ..write('id: $id, ')
          ..write('nombreUsuario: $nombreUsuario, ')
          ..write('diasSemana: $diasSemana, ')
          ..write('horaDevocional: $horaDevocional, ')
          ..write('horaAvisoPrevio: $horaAvisoPrevio, ')
          ..write('avisoPrevioActivo: $avisoPrevioActivo, ')
          ..write('sesionActivaInicio: $sesionActivaInicio, ')
          ..write('onboardingCompletado: $onboardingCompletado')
          ..write(')'))
        .toString();
  }
}

class $SesionDevocionalTableTable extends SesionDevocionalTable
    with TableInfo<$SesionDevocionalTableTable, SesionDevocionalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SesionDevocionalTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
      'fecha', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _duracionMinutosMeta =
      const VerificationMeta('duracionMinutos');
  @override
  late final GeneratedColumn<int> duracionMinutos = GeneratedColumn<int>(
      'duracion_minutos', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _registroManualMeta =
      const VerificationMeta('registroManual');
  @override
  late final GeneratedColumn<bool> registroManual = GeneratedColumn<bool>(
      'registro_manual', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("registro_manual" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completadoMeta =
      const VerificationMeta('completado');
  @override
  late final GeneratedColumn<bool> completado = GeneratedColumn<bool>(
      'completado', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completado" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, fecha, duracionMinutos, registroManual, completado];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sesion_devocional_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<SesionDevocionalData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('duracion_minutos')) {
      context.handle(
          _duracionMinutosMeta,
          duracionMinutos.isAcceptableOrUnknown(
              data['duracion_minutos']!, _duracionMinutosMeta));
    }
    if (data.containsKey('registro_manual')) {
      context.handle(
          _registroManualMeta,
          registroManual.isAcceptableOrUnknown(
              data['registro_manual']!, _registroManualMeta));
    }
    if (data.containsKey('completado')) {
      context.handle(
          _completadoMeta,
          completado.isAcceptableOrUnknown(
              data['completado']!, _completadoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SesionDevocionalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SesionDevocionalData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fecha'])!,
      duracionMinutos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duracion_minutos'])!,
      registroManual: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}registro_manual'])!,
      completado: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completado'])!,
    );
  }

  @override
  $SesionDevocionalTableTable createAlias(String alias) {
    return $SesionDevocionalTableTable(attachedDatabase, alias);
  }
}

class SesionDevocionalData extends DataClass
    implements Insertable<SesionDevocionalData> {
  final int id;

  /// Fecha en formato 'YYYY-MM-DD' para consultas directas y búsquedas en calendario
  final String fecha;

  /// Duración real transcurrida en minutos
  final int duracionMinutos;

  /// True si el devocional se marcó manualmente en el calendario; false si fue con temporizador
  final bool registroManual;

  /// Indica si la sesión fue completada satisfactoriamente
  final bool completado;
  const SesionDevocionalData(
      {required this.id,
      required this.fecha,
      required this.duracionMinutos,
      required this.registroManual,
      required this.completado});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha'] = Variable<String>(fecha);
    map['duracion_minutos'] = Variable<int>(duracionMinutos);
    map['registro_manual'] = Variable<bool>(registroManual);
    map['completado'] = Variable<bool>(completado);
    return map;
  }

  SesionDevocionalTableCompanion toCompanion(bool nullToAbsent) {
    return SesionDevocionalTableCompanion(
      id: Value(id),
      fecha: Value(fecha),
      duracionMinutos: Value(duracionMinutos),
      registroManual: Value(registroManual),
      completado: Value(completado),
    );
  }

  factory SesionDevocionalData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SesionDevocionalData(
      id: serializer.fromJson<int>(json['id']),
      fecha: serializer.fromJson<String>(json['fecha']),
      duracionMinutos: serializer.fromJson<int>(json['duracionMinutos']),
      registroManual: serializer.fromJson<bool>(json['registroManual']),
      completado: serializer.fromJson<bool>(json['completado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fecha': serializer.toJson<String>(fecha),
      'duracionMinutos': serializer.toJson<int>(duracionMinutos),
      'registroManual': serializer.toJson<bool>(registroManual),
      'completado': serializer.toJson<bool>(completado),
    };
  }

  SesionDevocionalData copyWith(
          {int? id,
          String? fecha,
          int? duracionMinutos,
          bool? registroManual,
          bool? completado}) =>
      SesionDevocionalData(
        id: id ?? this.id,
        fecha: fecha ?? this.fecha,
        duracionMinutos: duracionMinutos ?? this.duracionMinutos,
        registroManual: registroManual ?? this.registroManual,
        completado: completado ?? this.completado,
      );
  SesionDevocionalData copyWithCompanion(SesionDevocionalTableCompanion data) {
    return SesionDevocionalData(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      duracionMinutos: data.duracionMinutos.present
          ? data.duracionMinutos.value
          : this.duracionMinutos,
      registroManual: data.registroManual.present
          ? data.registroManual.value
          : this.registroManual,
      completado:
          data.completado.present ? data.completado.value : this.completado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SesionDevocionalData(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('duracionMinutos: $duracionMinutos, ')
          ..write('registroManual: $registroManual, ')
          ..write('completado: $completado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fecha, duracionMinutos, registroManual, completado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SesionDevocionalData &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.duracionMinutos == this.duracionMinutos &&
          other.registroManual == this.registroManual &&
          other.completado == this.completado);
}

class SesionDevocionalTableCompanion
    extends UpdateCompanion<SesionDevocionalData> {
  final Value<int> id;
  final Value<String> fecha;
  final Value<int> duracionMinutos;
  final Value<bool> registroManual;
  final Value<bool> completado;
  const SesionDevocionalTableCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.duracionMinutos = const Value.absent(),
    this.registroManual = const Value.absent(),
    this.completado = const Value.absent(),
  });
  SesionDevocionalTableCompanion.insert({
    this.id = const Value.absent(),
    required String fecha,
    this.duracionMinutos = const Value.absent(),
    this.registroManual = const Value.absent(),
    this.completado = const Value.absent(),
  }) : fecha = Value(fecha);
  static Insertable<SesionDevocionalData> custom({
    Expression<int>? id,
    Expression<String>? fecha,
    Expression<int>? duracionMinutos,
    Expression<bool>? registroManual,
    Expression<bool>? completado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (duracionMinutos != null) 'duracion_minutos': duracionMinutos,
      if (registroManual != null) 'registro_manual': registroManual,
      if (completado != null) 'completado': completado,
    });
  }

  SesionDevocionalTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? fecha,
      Value<int>? duracionMinutos,
      Value<bool>? registroManual,
      Value<bool>? completado}) {
    return SesionDevocionalTableCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      registroManual: registroManual ?? this.registroManual,
      completado: completado ?? this.completado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (duracionMinutos.present) {
      map['duracion_minutos'] = Variable<int>(duracionMinutos.value);
    }
    if (registroManual.present) {
      map['registro_manual'] = Variable<bool>(registroManual.value);
    }
    if (completado.present) {
      map['completado'] = Variable<bool>(completado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SesionDevocionalTableCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('duracionMinutos: $duracionMinutos, ')
          ..write('registroManual: $registroManual, ')
          ..write('completado: $completado')
          ..write(')'))
        .toString();
  }
}

class $ActividadGuiaTableTable extends ActividadGuiaTable
    with TableInfo<$ActividadGuiaTableTable, ActividadGuiaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActividadGuiaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
      'titulo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
      'orden', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _activaMeta = const VerificationMeta('activa');
  @override
  late final GeneratedColumn<bool> activa = GeneratedColumn<bool>(
      'activa', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("activa" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [id, titulo, orden, activa];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'actividad_guia_table';
  @override
  VerificationContext validateIntegrity(Insertable<ActividadGuiaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('titulo')) {
      context.handle(_tituloMeta,
          titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta));
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
          _ordenMeta, orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta));
    } else if (isInserting) {
      context.missing(_ordenMeta);
    }
    if (data.containsKey('activa')) {
      context.handle(_activaMeta,
          activa.isAcceptableOrUnknown(data['activa']!, _activaMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActividadGuiaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActividadGuiaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      titulo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}titulo'])!,
      orden: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}orden'])!,
      activa: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}activa'])!,
    );
  }

  @override
  $ActividadGuiaTableTable createAlias(String alias) {
    return $ActividadGuiaTableTable(attachedDatabase, alias);
  }
}

class ActividadGuiaData extends DataClass
    implements Insertable<ActividadGuiaData> {
  final int id;

  /// Título de la actividad (ej: "Orar", "Leer la Biblia")
  final String titulo;

  /// Orden secuencial para el reordenamiento por arrastre
  final int orden;

  /// Indica si la actividad está activa en la guía diaria
  final bool activa;
  const ActividadGuiaData(
      {required this.id,
      required this.titulo,
      required this.orden,
      required this.activa});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['titulo'] = Variable<String>(titulo);
    map['orden'] = Variable<int>(orden);
    map['activa'] = Variable<bool>(activa);
    return map;
  }

  ActividadGuiaTableCompanion toCompanion(bool nullToAbsent) {
    return ActividadGuiaTableCompanion(
      id: Value(id),
      titulo: Value(titulo),
      orden: Value(orden),
      activa: Value(activa),
    );
  }

  factory ActividadGuiaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActividadGuiaData(
      id: serializer.fromJson<int>(json['id']),
      titulo: serializer.fromJson<String>(json['titulo']),
      orden: serializer.fromJson<int>(json['orden']),
      activa: serializer.fromJson<bool>(json['activa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'titulo': serializer.toJson<String>(titulo),
      'orden': serializer.toJson<int>(orden),
      'activa': serializer.toJson<bool>(activa),
    };
  }

  ActividadGuiaData copyWith(
          {int? id, String? titulo, int? orden, bool? activa}) =>
      ActividadGuiaData(
        id: id ?? this.id,
        titulo: titulo ?? this.titulo,
        orden: orden ?? this.orden,
        activa: activa ?? this.activa,
      );
  ActividadGuiaData copyWithCompanion(ActividadGuiaTableCompanion data) {
    return ActividadGuiaData(
      id: data.id.present ? data.id.value : this.id,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      orden: data.orden.present ? data.orden.value : this.orden,
      activa: data.activa.present ? data.activa.value : this.activa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActividadGuiaData(')
          ..write('id: $id, ')
          ..write('titulo: $titulo, ')
          ..write('orden: $orden, ')
          ..write('activa: $activa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, titulo, orden, activa);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActividadGuiaData &&
          other.id == this.id &&
          other.titulo == this.titulo &&
          other.orden == this.orden &&
          other.activa == this.activa);
}

class ActividadGuiaTableCompanion extends UpdateCompanion<ActividadGuiaData> {
  final Value<int> id;
  final Value<String> titulo;
  final Value<int> orden;
  final Value<bool> activa;
  const ActividadGuiaTableCompanion({
    this.id = const Value.absent(),
    this.titulo = const Value.absent(),
    this.orden = const Value.absent(),
    this.activa = const Value.absent(),
  });
  ActividadGuiaTableCompanion.insert({
    this.id = const Value.absent(),
    required String titulo,
    required int orden,
    this.activa = const Value.absent(),
  })  : titulo = Value(titulo),
        orden = Value(orden);
  static Insertable<ActividadGuiaData> custom({
    Expression<int>? id,
    Expression<String>? titulo,
    Expression<int>? orden,
    Expression<bool>? activa,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titulo != null) 'titulo': titulo,
      if (orden != null) 'orden': orden,
      if (activa != null) 'activa': activa,
    });
  }

  ActividadGuiaTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? titulo,
      Value<int>? orden,
      Value<bool>? activa}) {
    return ActividadGuiaTableCompanion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      orden: orden ?? this.orden,
      activa: activa ?? this.activa,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (activa.present) {
      map['activa'] = Variable<bool>(activa.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActividadGuiaTableCompanion(')
          ..write('id: $id, ')
          ..write('titulo: $titulo, ')
          ..write('orden: $orden, ')
          ..write('activa: $activa')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConfiguracionUsuarioTableTable configuracionUsuarioTable =
      $ConfiguracionUsuarioTableTable(this);
  late final $SesionDevocionalTableTable sesionDevocionalTable =
      $SesionDevocionalTableTable(this);
  late final $ActividadGuiaTableTable actividadGuiaTable =
      $ActividadGuiaTableTable(this);
  late final Index idxSesionFecha = Index('idx_sesion_fecha',
      'CREATE INDEX idx_sesion_fecha ON sesion_devocional_table (fecha)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        configuracionUsuarioTable,
        sesionDevocionalTable,
        actividadGuiaTable,
        idxSesionFecha
      ];
}

typedef $$ConfiguracionUsuarioTableTableCreateCompanionBuilder
    = ConfiguracionUsuarioTableCompanion Function({
  Value<int> id,
  Value<String> nombreUsuario,
  Value<List<int>> diasSemana,
  Value<String> horaDevocional,
  Value<String?> horaAvisoPrevio,
  Value<bool> avisoPrevioActivo,
  Value<DateTime?> sesionActivaInicio,
  Value<bool> onboardingCompletado,
});
typedef $$ConfiguracionUsuarioTableTableUpdateCompanionBuilder
    = ConfiguracionUsuarioTableCompanion Function({
  Value<int> id,
  Value<String> nombreUsuario,
  Value<List<int>> diasSemana,
  Value<String> horaDevocional,
  Value<String?> horaAvisoPrevio,
  Value<bool> avisoPrevioActivo,
  Value<DateTime?> sesionActivaInicio,
  Value<bool> onboardingCompletado,
});

class $$ConfiguracionUsuarioTableTableFilterComposer
    extends Composer<_$AppDatabase, $ConfiguracionUsuarioTableTable> {
  $$ConfiguracionUsuarioTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombreUsuario => $composableBuilder(
      column: $table.nombreUsuario, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<int>, List<int>, String> get diasSemana =>
      $composableBuilder(
          column: $table.diasSemana,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get horaDevocional => $composableBuilder(
      column: $table.horaDevocional,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get horaAvisoPrevio => $composableBuilder(
      column: $table.horaAvisoPrevio,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get avisoPrevioActivo => $composableBuilder(
      column: $table.avisoPrevioActivo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sesionActivaInicio => $composableBuilder(
      column: $table.sesionActivaInicio,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onboardingCompletado => $composableBuilder(
      column: $table.onboardingCompletado,
      builder: (column) => ColumnFilters(column));
}

class $$ConfiguracionUsuarioTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfiguracionUsuarioTableTable> {
  $$ConfiguracionUsuarioTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombreUsuario => $composableBuilder(
      column: $table.nombreUsuario,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diasSemana => $composableBuilder(
      column: $table.diasSemana, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get horaDevocional => $composableBuilder(
      column: $table.horaDevocional,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get horaAvisoPrevio => $composableBuilder(
      column: $table.horaAvisoPrevio,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get avisoPrevioActivo => $composableBuilder(
      column: $table.avisoPrevioActivo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sesionActivaInicio => $composableBuilder(
      column: $table.sesionActivaInicio,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onboardingCompletado => $composableBuilder(
      column: $table.onboardingCompletado,
      builder: (column) => ColumnOrderings(column));
}

class $$ConfiguracionUsuarioTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfiguracionUsuarioTableTable> {
  $$ConfiguracionUsuarioTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombreUsuario => $composableBuilder(
      column: $table.nombreUsuario, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>, String> get diasSemana =>
      $composableBuilder(
          column: $table.diasSemana, builder: (column) => column);

  GeneratedColumn<String> get horaDevocional => $composableBuilder(
      column: $table.horaDevocional, builder: (column) => column);

  GeneratedColumn<String> get horaAvisoPrevio => $composableBuilder(
      column: $table.horaAvisoPrevio, builder: (column) => column);

  GeneratedColumn<bool> get avisoPrevioActivo => $composableBuilder(
      column: $table.avisoPrevioActivo, builder: (column) => column);

  GeneratedColumn<DateTime> get sesionActivaInicio => $composableBuilder(
      column: $table.sesionActivaInicio, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompletado => $composableBuilder(
      column: $table.onboardingCompletado, builder: (column) => column);
}

class $$ConfiguracionUsuarioTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConfiguracionUsuarioTableTable,
    ConfiguracionUsuarioData,
    $$ConfiguracionUsuarioTableTableFilterComposer,
    $$ConfiguracionUsuarioTableTableOrderingComposer,
    $$ConfiguracionUsuarioTableTableAnnotationComposer,
    $$ConfiguracionUsuarioTableTableCreateCompanionBuilder,
    $$ConfiguracionUsuarioTableTableUpdateCompanionBuilder,
    (
      ConfiguracionUsuarioData,
      BaseReferences<_$AppDatabase, $ConfiguracionUsuarioTableTable,
          ConfiguracionUsuarioData>
    ),
    ConfiguracionUsuarioData,
    PrefetchHooks Function()> {
  $$ConfiguracionUsuarioTableTableTableManager(
      _$AppDatabase db, $ConfiguracionUsuarioTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfiguracionUsuarioTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfiguracionUsuarioTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfiguracionUsuarioTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nombreUsuario = const Value.absent(),
            Value<List<int>> diasSemana = const Value.absent(),
            Value<String> horaDevocional = const Value.absent(),
            Value<String?> horaAvisoPrevio = const Value.absent(),
            Value<bool> avisoPrevioActivo = const Value.absent(),
            Value<DateTime?> sesionActivaInicio = const Value.absent(),
            Value<bool> onboardingCompletado = const Value.absent(),
          }) =>
              ConfiguracionUsuarioTableCompanion(
            id: id,
            nombreUsuario: nombreUsuario,
            diasSemana: diasSemana,
            horaDevocional: horaDevocional,
            horaAvisoPrevio: horaAvisoPrevio,
            avisoPrevioActivo: avisoPrevioActivo,
            sesionActivaInicio: sesionActivaInicio,
            onboardingCompletado: onboardingCompletado,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nombreUsuario = const Value.absent(),
            Value<List<int>> diasSemana = const Value.absent(),
            Value<String> horaDevocional = const Value.absent(),
            Value<String?> horaAvisoPrevio = const Value.absent(),
            Value<bool> avisoPrevioActivo = const Value.absent(),
            Value<DateTime?> sesionActivaInicio = const Value.absent(),
            Value<bool> onboardingCompletado = const Value.absent(),
          }) =>
              ConfiguracionUsuarioTableCompanion.insert(
            id: id,
            nombreUsuario: nombreUsuario,
            diasSemana: diasSemana,
            horaDevocional: horaDevocional,
            horaAvisoPrevio: horaAvisoPrevio,
            avisoPrevioActivo: avisoPrevioActivo,
            sesionActivaInicio: sesionActivaInicio,
            onboardingCompletado: onboardingCompletado,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ConfiguracionUsuarioTableTable,
                        ConfiguracionUsuarioData>(table),
                    BaseReferences<
                        _$AppDatabase,
                        $ConfiguracionUsuarioTableTable,
                        ConfiguracionUsuarioData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConfiguracionUsuarioTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ConfiguracionUsuarioTableTable,
        ConfiguracionUsuarioData,
        $$ConfiguracionUsuarioTableTableFilterComposer,
        $$ConfiguracionUsuarioTableTableOrderingComposer,
        $$ConfiguracionUsuarioTableTableAnnotationComposer,
        $$ConfiguracionUsuarioTableTableCreateCompanionBuilder,
        $$ConfiguracionUsuarioTableTableUpdateCompanionBuilder,
        (
          ConfiguracionUsuarioData,
          BaseReferences<_$AppDatabase, $ConfiguracionUsuarioTableTable,
              ConfiguracionUsuarioData>
        ),
        ConfiguracionUsuarioData,
        PrefetchHooks Function()>;
typedef $$SesionDevocionalTableTableCreateCompanionBuilder
    = SesionDevocionalTableCompanion Function({
  Value<int> id,
  required String fecha,
  Value<int> duracionMinutos,
  Value<bool> registroManual,
  Value<bool> completado,
});
typedef $$SesionDevocionalTableTableUpdateCompanionBuilder
    = SesionDevocionalTableCompanion Function({
  Value<int> id,
  Value<String> fecha,
  Value<int> duracionMinutos,
  Value<bool> registroManual,
  Value<bool> completado,
});

class $$SesionDevocionalTableTableFilterComposer
    extends Composer<_$AppDatabase, $SesionDevocionalTableTable> {
  $$SesionDevocionalTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duracionMinutos => $composableBuilder(
      column: $table.duracionMinutos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get registroManual => $composableBuilder(
      column: $table.registroManual,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completado => $composableBuilder(
      column: $table.completado, builder: (column) => ColumnFilters(column));
}

class $$SesionDevocionalTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SesionDevocionalTableTable> {
  $$SesionDevocionalTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duracionMinutos => $composableBuilder(
      column: $table.duracionMinutos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get registroManual => $composableBuilder(
      column: $table.registroManual,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completado => $composableBuilder(
      column: $table.completado, builder: (column) => ColumnOrderings(column));
}

class $$SesionDevocionalTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SesionDevocionalTableTable> {
  $$SesionDevocionalTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<int> get duracionMinutos => $composableBuilder(
      column: $table.duracionMinutos, builder: (column) => column);

  GeneratedColumn<bool> get registroManual => $composableBuilder(
      column: $table.registroManual, builder: (column) => column);

  GeneratedColumn<bool> get completado => $composableBuilder(
      column: $table.completado, builder: (column) => column);
}

class $$SesionDevocionalTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SesionDevocionalTableTable,
    SesionDevocionalData,
    $$SesionDevocionalTableTableFilterComposer,
    $$SesionDevocionalTableTableOrderingComposer,
    $$SesionDevocionalTableTableAnnotationComposer,
    $$SesionDevocionalTableTableCreateCompanionBuilder,
    $$SesionDevocionalTableTableUpdateCompanionBuilder,
    (
      SesionDevocionalData,
      BaseReferences<_$AppDatabase, $SesionDevocionalTableTable,
          SesionDevocionalData>
    ),
    SesionDevocionalData,
    PrefetchHooks Function()> {
  $$SesionDevocionalTableTableTableManager(
      _$AppDatabase db, $SesionDevocionalTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SesionDevocionalTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$SesionDevocionalTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SesionDevocionalTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> fecha = const Value.absent(),
            Value<int> duracionMinutos = const Value.absent(),
            Value<bool> registroManual = const Value.absent(),
            Value<bool> completado = const Value.absent(),
          }) =>
              SesionDevocionalTableCompanion(
            id: id,
            fecha: fecha,
            duracionMinutos: duracionMinutos,
            registroManual: registroManual,
            completado: completado,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String fecha,
            Value<int> duracionMinutos = const Value.absent(),
            Value<bool> registroManual = const Value.absent(),
            Value<bool> completado = const Value.absent(),
          }) =>
              SesionDevocionalTableCompanion.insert(
            id: id,
            fecha: fecha,
            duracionMinutos: duracionMinutos,
            registroManual: registroManual,
            completado: completado,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SesionDevocionalTableTable,
                        SesionDevocionalData>(table),
                    BaseReferences<_$AppDatabase, $SesionDevocionalTableTable,
                        SesionDevocionalData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SesionDevocionalTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SesionDevocionalTableTable,
        SesionDevocionalData,
        $$SesionDevocionalTableTableFilterComposer,
        $$SesionDevocionalTableTableOrderingComposer,
        $$SesionDevocionalTableTableAnnotationComposer,
        $$SesionDevocionalTableTableCreateCompanionBuilder,
        $$SesionDevocionalTableTableUpdateCompanionBuilder,
        (
          SesionDevocionalData,
          BaseReferences<_$AppDatabase, $SesionDevocionalTableTable,
              SesionDevocionalData>
        ),
        SesionDevocionalData,
        PrefetchHooks Function()>;
typedef $$ActividadGuiaTableTableCreateCompanionBuilder
    = ActividadGuiaTableCompanion Function({
  Value<int> id,
  required String titulo,
  required int orden,
  Value<bool> activa,
});
typedef $$ActividadGuiaTableTableUpdateCompanionBuilder
    = ActividadGuiaTableCompanion Function({
  Value<int> id,
  Value<String> titulo,
  Value<int> orden,
  Value<bool> activa,
});

class $$ActividadGuiaTableTableFilterComposer
    extends Composer<_$AppDatabase, $ActividadGuiaTableTable> {
  $$ActividadGuiaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titulo => $composableBuilder(
      column: $table.titulo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orden => $composableBuilder(
      column: $table.orden, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get activa => $composableBuilder(
      column: $table.activa, builder: (column) => ColumnFilters(column));
}

class $$ActividadGuiaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ActividadGuiaTableTable> {
  $$ActividadGuiaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titulo => $composableBuilder(
      column: $table.titulo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orden => $composableBuilder(
      column: $table.orden, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get activa => $composableBuilder(
      column: $table.activa, builder: (column) => ColumnOrderings(column));
}

class $$ActividadGuiaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActividadGuiaTableTable> {
  $$ActividadGuiaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<bool> get activa =>
      $composableBuilder(column: $table.activa, builder: (column) => column);
}

class $$ActividadGuiaTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActividadGuiaTableTable,
    ActividadGuiaData,
    $$ActividadGuiaTableTableFilterComposer,
    $$ActividadGuiaTableTableOrderingComposer,
    $$ActividadGuiaTableTableAnnotationComposer,
    $$ActividadGuiaTableTableCreateCompanionBuilder,
    $$ActividadGuiaTableTableUpdateCompanionBuilder,
    (
      ActividadGuiaData,
      BaseReferences<_$AppDatabase, $ActividadGuiaTableTable, ActividadGuiaData>
    ),
    ActividadGuiaData,
    PrefetchHooks Function()> {
  $$ActividadGuiaTableTableTableManager(
      _$AppDatabase db, $ActividadGuiaTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActividadGuiaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActividadGuiaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActividadGuiaTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> titulo = const Value.absent(),
            Value<int> orden = const Value.absent(),
            Value<bool> activa = const Value.absent(),
          }) =>
              ActividadGuiaTableCompanion(
            id: id,
            titulo: titulo,
            orden: orden,
            activa: activa,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String titulo,
            required int orden,
            Value<bool> activa = const Value.absent(),
          }) =>
              ActividadGuiaTableCompanion.insert(
            id: id,
            titulo: titulo,
            orden: orden,
            activa: activa,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ActividadGuiaTableTable, ActividadGuiaData>(
                        table),
                    BaseReferences<_$AppDatabase, $ActividadGuiaTableTable,
                        ActividadGuiaData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ActividadGuiaTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActividadGuiaTableTable,
    ActividadGuiaData,
    $$ActividadGuiaTableTableFilterComposer,
    $$ActividadGuiaTableTableOrderingComposer,
    $$ActividadGuiaTableTableAnnotationComposer,
    $$ActividadGuiaTableTableCreateCompanionBuilder,
    $$ActividadGuiaTableTableUpdateCompanionBuilder,
    (
      ActividadGuiaData,
      BaseReferences<_$AppDatabase, $ActividadGuiaTableTable, ActividadGuiaData>
    ),
    ActividadGuiaData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ConfiguracionUsuarioTableTableTableManager get configuracionUsuarioTable =>
      $$ConfiguracionUsuarioTableTableTableManager(
          _db, _db.configuracionUsuarioTable);
  $$SesionDevocionalTableTableTableManager get sesionDevocionalTable =>
      $$SesionDevocionalTableTableTableManager(_db, _db.sesionDevocionalTable);
  $$ActividadGuiaTableTableTableManager get actividadGuiaTable =>
      $$ActividadGuiaTableTableTableManager(_db, _db.actividadGuiaTable);
}
