import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotification() async {
    // 1. Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 2. iOS / macOS settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    // 3. Combine platform settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // 4. Initialize with tap response handler
    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final String? payload = response.payload;
        if (payload != null) {
          // Handle navigation or payload logic when notification is tapped
          print('Notification tapped with payload: $payload');
        }
      },
    );
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'channel_id', // id
              'Notifications Channel', // title
              description:
                  'This channel is used for notifications.', // description
              importance: Importance.max,
            ),
          );
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    await _plugin.show(
      id: Random().nextInt(1000), // Unique ID for each notification
      title: message.notification?.title ?? "New Task",
      body: message.notification?.body ?? "You have a new task",
      payload: message.data.toString(),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'Notifications Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
