import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showArrivalAlert({
    required String lineSign,
    required String stopName,
    required int minutesAway,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'arrival_alerts',
      'Alertas de Chegada',
      channelDescription:
          'Notificações quando um ônibus está próximo da parada.',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      lineSign.hashCode,
      'Ônibus chegando: $lineSign',
      '$minutesAway min para a parada $stopName',
      details,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
