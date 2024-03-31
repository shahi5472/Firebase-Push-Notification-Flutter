import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_push_notification_app/notification/permission/notification_permission_util.dart';
import 'package:flutter_local_notifications_plus/flutter_local_notifications_plus.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<String> get getToken async => await messaging.getToken() ?? "";

  void refreshToken() async {
    messaging.onTokenRefresh.listen((event) {
      print("refreshToken :: [$event]");
    });
  }

  void subscribeTopic() async {
    await messaging.subscribeToTopic("updateNotification");
  }

  void requestNotificationPermission() async {
    final result = await NotificationPermissionUtil.request();
    print("requestNotificationPermission :: [$result]");
  }

  Future foregroundNotification() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      sound: true,
      badge: true,
    );
  }

  void onInit() async {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? remoteNotification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;
      print("onInit RemoteNotification :: [${remoteNotification?.title}]");
      print("onInit RemoteNotification :: [${remoteNotification?.toMap()}]");
      print("onInit AndroidNotification :: [${androidNotification?.toMap()}]");
      print("onInit :: [${message.toMap()}]");

      if (Platform.isIOS) {
        foregroundNotification();
      }

      if (Platform.isAndroid) {
        initLocalNotification(message);
      }
    });
  }

  void initLocalNotification(RemoteMessage message) async {
    const androidSettings = AndroidInitializationSettings("@mipmap/ic_launcher");
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (payload) => onDidReceiveNotificationResponse(message),
    );
  }

  void onDidReceiveNotificationResponse(RemoteMessage message) {
    handleNotificationMessage(message);
  }

  void handleNotificationMessage(RemoteMessage message) {
    print("handleNotificationMessage :: [${message.data.toString()}]");
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel androidNotificationChannel = const AndroidNotificationChannel(
      "11111",
      "Test1111",
      importance: Importance.high,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      androidNotificationChannel.id,
      androidNotificationChannel.name,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      ticker: "ticker",
      sound: androidNotificationChannel.sound,
    );

    DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    _localNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }
}
