import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tiempo_con_dios/core/notifications/notification_service.dart';

void main() {
  test('tz.local after initializeTimeZones', () {
    tz.initializeTimeZones();
    // ignore: avoid_print
    print('tz.local name: ${tz.local.name}');
  });

  test('NotificationService inicializar en entorno de pruebas', () async {
    final service = NotificationService();
    // En tests esto no es Android nativo
    await service.inicializar();
    expect(service, isNotNull);
  });
}
