import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tdlabs/config/language.dart';
import 'package:tdlabs/screens/home/home.dart';
import 'package:tdlabs/screens/medical/others/medical_ledger.dart';
import 'package:tdlabs/screens/user/login.dart';
import 'package:tdlabs/screens/widget/splash.dart';
import 'services/notification.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  debugPaintSizeEnabled = false;
  // Only call clearSavedSettings() during testing to reset internal values.

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  ));

  // // Firebase Cloud Messaging (FCM)

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.ios,
    );
  } else if (Platform.isAndroid) {
    await Firebase.initializeApp(
      name: 'com.tedainternational.tdlabs',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await FirebaseMessaging.instance.requestPermission(
      alert: true, badge: true, sound: true, provisional: false);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await setupFlutterNotifications();
  await NotificationService().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
 
    return GetCupertinoApp(
      builder: (context, child) {
        return MediaQuery(
          child: child!,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      title: 'TD-LABS',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: CupertinoColors.white,
        primaryColor: Color.fromARGB(255, 24, 112, 141),
        textTheme: CupertinoTextThemeData(
          primaryColor: Color.fromARGB(255, 24, 112, 141),
          textStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Color.fromARGB(255, 104, 104, 104),
              fontWeight: FontWeight.w300),
        ),
      ),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      translationsKeys: Language().keys,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [Locale('en'), Locale('zh')],
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const Home(),
        '/login': (context) => const LoginScreen(),
        '/ledger': (context) => const MedicalLedgerScreen(),
      },
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    name:
        'com.tedainternational.tdlabs', // Replace with your app name if needed
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupFlutterNotifications();
  // Your added code for handling messages while the app is in the background
  print('Handling background message:');
  print('Message data: ${message.data}');
  if (message.notification != null) {
    print('Message also contained a notification: ${message.messageType}');
  }
}

bool isFlutterLocalNotificationsInitialized = false;
late AndroidNotificationChannel channel;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}
