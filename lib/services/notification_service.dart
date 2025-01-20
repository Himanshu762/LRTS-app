import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lrts/models/station.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    
    await _notifications.initialize(initializationSettings);
  }

  static Future<void> showZoneNotification(String zone, List<Station> stations) async {
    final availableRickshaws = stations
        .where((s) => s.zone == zone)
        .fold<int>(0, (sum, s) => sum + s.rickshaws);

    await _notifications.show(
      zone.hashCode,
      'Zone Update: $zone',
      'Available rickshaws: $availableRickshaws',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'zone_updates',
          'Zone Updates',
          importance: Importance.high,
        ),
      ),
    );
  }
} 