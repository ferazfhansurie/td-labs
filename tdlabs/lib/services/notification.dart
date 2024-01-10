// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// @copyright Copyright (c) 2021
/// @author David Cheang <davidcheang83@gmail.com>
/// @version 1.0.1 (null-safety)

class NotificationService {
  NotificationDetails? notificationDetails;
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        Map<String, dynamic> data = jsonDecode(payload);
        gotoNotification(data);
      }
    });

    if (Platform.isIOS) {
      const IOSNotificationDetails iOSPlatformChannelSpecifics =
          IOSNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      notificationDetails =
          const NotificationDetails(iOS: iOSPlatformChannelSpecifics);
    } else if (Platform.isAndroid) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('default', 'Default Channel',
              channelDescription: 'Default Channel',
              importance: Importance.high,
              icon: 'ic_launcher',);
      notificationDetails =
          const NotificationDetails(android: androidPlatformChannelSpecifics);
    }
  }

  Future<String?> getFirebaseMessagingToken() async {
    bool hasService = true;
   

    if (hasService) {
      FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      return await firebaseMessaging.getToken();
    } 
  }

}

Future<void> gotoNotification(Map<String, dynamic> data) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.containsKey('api.user_id')) {}
}
