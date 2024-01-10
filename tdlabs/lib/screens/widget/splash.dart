// ignore_for_file: prefer_final_fields, unused_field

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlabs/config/main.dart';
import '../../models/settings.dart';
import '../../services/notification.dart';
import '../../utils/web_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppUpdateInfo? _updateInfo;
  bool _flexibleUpdateAvailable = false;
  String availableVersion = "";
  // Platform messages are asynchronous, so we initialize in an async method.\
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _autoLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Center(
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
    );
  }

  Future<void> _autoLogin(context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // Fetch server version and settings
    await Settings.fetchServerSettings(context);

    String? refreshToken = sharedPreferences.getString('api.refresh_token');
    if (refreshToken != null) {
      String? messagingToken =await NotificationService().getFirebaseMessagingToken();
      if (MainConfig.modeLive == false) {
        FirebaseMessaging.instance.subscribeToTopic("Testing");
      }
      final webService = WebService(context);
      var result = await webService.authenticateRefresh(refreshToken,
          messagingToken: messagingToken);
      if ((result != null) && result) {
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }
    }
    Navigator.pushReplacementNamed(context, '/login');
  }
}
