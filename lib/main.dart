import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_task_manager/app.dart';
import 'package:firebase_task_manager/utlis/notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void _handleNotificationOpened(RemoteMessage message) {
  debugPrint(
    'Notification opened: ${message.messageId}; data: ${message.data}',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationHelper.initNotification();
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: false,
    sound: false,
  );
  await FirebaseMessaging.instance.subscribeToTopic('test');
  FirebaseMessaging.onMessage.listen((message) async {
    await NotificationHelper.showNotification(message);
  });
  FirebaseMessaging.onBackgroundMessage((message) async {
    await NotificationHelper.showNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleNotificationOpened(initialMessage);
  }

  runApp(const FirebaseTaskManager());
}
