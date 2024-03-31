import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_push_notification_app/firebase_options.dart';
import 'package:firebase_push_notification_app/notification/notification_service.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Push Notification',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreenView(),
    );
  }
}

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  String deviceToken = "";

  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    _getToken();
    super.initState();
  }

  void _getToken() async {
    notificationService.requestNotificationPermission();
    notificationService.foregroundNotification();
    notificationService.onInit();
    notificationService.subscribeTopic();
    deviceToken = await notificationService.getToken;
    print("notificationService :: [$deviceToken]");
    await Future.delayed(const Duration(seconds: 5));
    RemoteMessage message = const RemoteMessage(
      notification: RemoteNotification(
        title: "Test Title",
        body: "Test Notification body",
      ),
    );
    notificationService.showNotification(message);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Push Notification")),
      body: ListView(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        children: [
          Text("Device Token: $deviceToken"),
        ],
      ),
    );
  }
}
