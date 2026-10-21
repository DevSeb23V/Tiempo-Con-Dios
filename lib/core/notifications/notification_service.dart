import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Proveedor global del servicio de notificaciones y alarmas exactas.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Servicio de alarmas exactas y notificaciones locales para "Tiempo con Dios".
/// Utiliza canales de alta prioridad, sonido calmado (bell_calm.wav) y fullScreenIntent
/// para despertar el dispositivo respetando el Doze Mode de Android.
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String alarmaChannelId = 'tcd_alarma_channel';
  static const String avisoPrevioChannelId = 'tcd_aviso_channel';

  /// Inicializa Timezone, configuraciones de plataforma y canales nativos con alta resiliencia.
  Future<void> inicializar({void Function(String? payload)? onSelectNotification}) async {
    if (_isInitialized) return;

    _configurarZonaHorariaLocal();

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // En Android se utiliza launcher_icon generado por flutter_launcher_icons
    bool initialized = false;
    for (final iconName in ['@mipmap/launcher_icon', '@mipmap/ic_launcher', '@drawable/splash']) {
      try {
        final initSettings = InitializationSettings(
          android: AndroidInitializationSettings(iconName),
          iOS: darwinSettings,
        );

        await _notifications.initialize(
          initSettings,
          onDidReceiveNotificationResponse: (response) {
            if (response.actionId == 'empezar_devocional') {
              onSelectNotification?.call('empezar_devocional');
            } else {
              onSelectNotification?.call(response.payload);
            }
          },
        );
        initialized = true;
        break;
      } catch (e) {
        debugPrint('Intento con icono $iconName falló: $e');
      }
    }

    if (!initialized) {
      debugPrint('Aviso: FlutterLocalNotifications no pudo inicializarse con iconos por defecto.');
    }

    // Crear canales en Android
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          try {
            // Canal de Alarma Devocional (Máxima importancia + sonido calmado + alerta a pantalla completa)
            await androidPlugin.createNotificationChannel(
              const AndroidNotificationChannel(
                alarmaChannelId,
                'Tiempo con Dios',
                description: 'Alarma de la cita diaria con Dios',
                importance: Importance.max,
                playSound: true,
                sound: RawResourceAndroidNotificationSound('bell_calm'),
                enableVibration: true,
                audioAttributesUsage: AudioAttributesUsage.alarm,
              ),
            );
          } catch (channelError) {
            debugPrint('Aviso: creando canal con sonido del sistema como fallback: $channelError');
            await androidPlugin.createNotificationChannel(
              const AndroidNotificationChannel(
                alarmaChannelId,
                'Tiempo con Dios',
                description: 'Alarma de la cita diaria con Dios',
                importance: Importance.max,
                playSound: true,
                enableVibration: true,
                audioAttributesUsage: AudioAttributesUsage.alarm,
              ),
            );
          }

          // Canal de Aviso Previo (Importancia estándar)
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              avisoPrevioChannelId,
              'Aviso Previo',
              description: 'Recordatorio para preparar tu espacio y Biblia',
              importance: Importance.defaultImportance,
              playSound: true,
              enableVibration: false,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error creando canales de notificación: $e');
      }
    }

    _isInitialized = true;
  }

  /// Configura la base de datos de zonas horarias y alinea tz.local con el offset del dispositivo.
  void _configurarZonaHorariaLocal() {
    try {
      tz.initializeTimeZones();
      final offsetMs = DateTime.now().timeZoneOffset.inMilliseconds;
      for (final location in tz.timeZoneDatabase.locations.values) {
        if (location.currentTimeZone.offset == offsetMs) {
          tz.setLocalLocation(location);
          return;
        }
      }
    } catch (e) {
      debugPrint('Error configurando zona horaria local: $e');
    }
  }

  /// Solicita los permisos requeridos en Android 13+ (Notificaciones y Alarma Exacta).
  Future<bool> solicitarPermisos() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final notifGranted = await androidPlugin.requestNotificationsPermission();
        final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
        return (notifGranted ?? false) && (exactAlarmGranted ?? true);
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        return (await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        )) ?? false;
      }
    }
    return true;
  }

  /// Genera los detalles de notificación para la alarma con o sin sonido personalizado
  AndroidNotificationDetails _crearAlarmaAndroidDetails({bool usarSonidoCalmado = true}) {
    return AndroidNotificationDetails(
      alarmaChannelId,
      'Tiempo con Dios',
      channelDescription: 'Alarma de la cita diaria con Dios',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      playSound: true,
      sound: usarSonidoCalmado ? const RawResourceAndroidNotificationSound('bell_calm') : null,
      enableVibration: true,
      icon: '@mipmap/launcher_icon',
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'empezar_devocional',
          'Empezar',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );
  }

  /// Programa las alarmas devocionales exactas para los días de la semana especificados.
  /// Formato de hora: 'HH:mm' (ej. '07:00').
  /// días de la semana: 1 = Lunes, ..., 7 = Domingo.
  Future<void> programarAlarmaDevocional({
    required String hora,
    required List<int> diasSemana,
  }) async {
    final partes = hora.split(':');
    if (partes.length != 2) return;
    final hour = int.tryParse(partes[0]) ?? 7;
    final minute = int.tryParse(partes[1]) ?? 0;

    // Cancelar alarmas anteriores para evitar duplicados (IDs 10, 20, 30... 70)
    for (int dia = 1; dia <= 7; dia++) {
      try {
        await _notifications.cancel(dia * 10);
      } catch (_) {}
    }

    bool canExact = false;
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        canExact = (await androidPlugin?.canScheduleExactNotifications()) ?? false;
      } catch (e) {
        debugPrint('Error comprobando permisos de alarma exacta: $e');
      }
    }

    for (final dia in diasSemana) {
      final scheduledDate = _nextInstanceOfDayAndTime(dia, hour, minute);
      final notificationDetails = NotificationDetails(
        android: _crearAlarmaAndroidDetails(usarSonidoCalmado: true),
      );

      try {
        await _notifications.zonedSchedule(
          dia * 10,
          'Es momento de tu tiempo con Dios',
          'Tu Padre te espera en lo secreto. Tu Biblia y cuaderno están listos.',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: canExact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: 'alerta_devocional',
        );
      } catch (_) {
        // Fallback resiliente sin sonido personalizado ni exigencia de exactitud estricta
        try {
          await _notifications.zonedSchedule(
            dia * 10,
            'Es momento de tu tiempo con Dios',
            'Tu Padre te espera en lo secreto. Tu Biblia y cuaderno están listos.',
            scheduledDate,
            NotificationDetails(android: _crearAlarmaAndroidDetails(usarSonidoCalmado: false)),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: 'alerta_devocional',
          );
        } catch (e) {
          debugPrint('Aviso: no se pudo programar alarma para el día $dia: $e');
        }
      }
    }
  }

  /// Programa la notificación de aviso previo (ej. 30 minutos antes o la noche anterior).
  Future<void> programarAvisoPrevio({
    required String? hora,
    required List<int> diasSemana,
    required bool activo,
  }) async {
    // Cancelamos avisos previos previos (IDs 11, 21, 31... 71)
    for (int dia = 1; dia <= 7; dia++) {
      await _notifications.cancel(dia * 10 + 1);
    }

    if (!activo || hora == null) return;

    final partes = hora.split(':');
    if (partes.length != 2) return;
    final hour = int.tryParse(partes[0]) ?? 21;
    final minute = int.tryParse(partes[1]) ?? 30;

    for (final dia in diasSemana) {
      final scheduledDate = _nextInstanceOfDayAndTime(dia, hour, minute);

      const androidDetails = AndroidNotificationDetails(
        avisoPrevioChannelId,
        'Aviso Previo',
        channelDescription: 'Recordatorio para preparar tu espacio y Biblia',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      try {
        await _notifications.zonedSchedule(
          dia * 10 + 1,
          'Prepara tu espacio',
          'Deja lista tu Biblia, cuaderno y pluma para tu tiempo con Dios.',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: 'aviso_previo',
        );
      } catch (_) {}
    }
  }

  /// Programa una alarma exacta de posposición por 10 minutos exactos (Snooze).
  Future<void> posponerDevocional10Min() async {
    final now = tz.TZDateTime.now(tz.local);
    final pospuestaTime = now.add(const Duration(minutes: 10));

    bool canExact = false;
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        canExact = (await androidPlugin?.canScheduleExactNotifications()) ?? false;
      } catch (_) {}
    }

    try {
      await _notifications.zonedSchedule(
        999, // ID fijo para posposición
        'Tu tiempo con Dios te espera',
        'Han pasado 10 minutos. Es un buen momento para apartar este tiempo.',
        pospuestaTime,
        NotificationDetails(android: _crearAlarmaAndroidDetails(usarSonidoCalmado: true)),
        androidScheduleMode: canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'alerta_devocional',
      );
    } catch (_) {
      try {
        await _notifications.zonedSchedule(
          999,
          'Tu tiempo con Dios te espera',
          'Han pasado 10 minutos. Es un buen momento para apartar este tiempo.',
          pospuestaTime,
          NotificationDetails(android: _crearAlarmaAndroidDetails(usarSonidoCalmado: false)),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'alerta_devocional',
        );
      } catch (e) {
        debugPrint('Error en posponerDevocional10Min fallback: $e');
      }
    }
  }

  /// Cancela la alarma pospuesta activa.
  Future<void> cancelarPosposicion() async {
    await _notifications.cancel(999);
  }

  /// Cancela absolutamente todas las notificaciones y alarmas programadas.
  Future<void> cancelarTodas() async {
    await _notifications.cancelAll();
  }

  /// Dispara una notificación inmediata de prueba con fullScreenIntent para validación rápida.
  Future<void> dispararAlertaInmediataParaPruebas() async {
    try {
      await _notifications.show(
        888,
        'Es momento de tu tiempo con Dios',
        'Tu Padre te espera en lo secreto. Tu Biblia y cuaderno están listos.',
        NotificationDetails(android: _crearAlarmaAndroidDetails(usarSonidoCalmado: true)),
        payload: 'alerta_devocional',
      );
    } catch (_) {
      await _notifications.show(
        888,
        'Es momento de tu tiempo con Dios',
        'Tu Padre te espera en lo secreto. Tu Biblia y cuaderno están listos.',
        NotificationDetails(android: _crearAlarmaAndroidDetails(usarSonidoCalmado: false)),
        payload: 'alerta_devocional',
      );
    }
  }

  /// Programa una alarma de prueba para dentro de 10 segundos con sonido de campana calmada.
  Future<void> probarAlarmaEn10Segundos() async {
    final now = tz.TZDateTime.now(tz.local);
    final targetTime = now.add(const Duration(seconds: 10));

    bool canExact = false;
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        canExact = (await androidPlugin?.canScheduleExactNotifications()) ?? false;
      } catch (_) {}
    }

    try {
      await _notifications.zonedSchedule(
        777,
        'Prueba: Tiempo con Dios (10 segundos)',
        'Tu campana calmada sonó a tiempo. ¡Las alarmas exactas funcionan a la perfección!',
        targetTime,
        NotificationDetails(android: _crearAlarmaAndroidDetails(usarSonidoCalmado: true)),
        androidScheduleMode: canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'alerta_devocional',
      );
    } catch (_) {
      try {
        await _notifications.zonedSchedule(
          777,
          'Prueba: Tiempo con Dios (10 segundos)',
          'Tu campana calmada sonó a tiempo. ¡Las alarmas funcionan a la perfección!',
          targetTime,
          NotificationDetails(android: _crearAlarmaAndroidDetails(usarSonidoCalmado: false)),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'alerta_devocional',
        );
      } catch (e) {
        debugPrint('Error en probarAlarmaEn10Segundos fallback: $e');
      }
    }
  }

  /// Calcula la próxima ocurrencia de un día de la semana y hora específicos.
  tz.TZDateTime _nextInstanceOfDayAndTime(int targetWeekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != targetWeekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
