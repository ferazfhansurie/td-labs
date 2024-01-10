import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/screens/history/history_screen.dart';
import 'package:tdlabs/screens/info/discovery_screen.dart';
import 'package:tdlabs/screens/info/info_screen.dart';
import 'package:tdlabs/screens/user/profile.dart';
import 'package:uni_links/uni_links.dart';
import '../../global.dart' as global;
import '../../utils/toast.dart';
import 'home_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home> {
  late StreamSubscription _streamSubscription;
  @override
  void initState() {
    super.initState();
    _initUniLinks();
    global.homeState = this;
  }
  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          iconSize: 20,
          inactiveColor: CupertinoColors.white,
          activeColor: const Color.fromARGB(255, 121, 121, 121),
          backgroundColor: const Color.fromARGB(255, 49, 42, 130),
          onTap: (index) {
            final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
            if (index == 1) {
              firebaseAnalytics.setCurrentScreen(screenName: '/history');
            } else if (index == 2) {
              firebaseAnalytics.setCurrentScreen(screenName: '/info');
            } else if (index == 3) {
              firebaseAnalytics.setCurrentScreen(screenName: '/discovery');
            } else if (index == 4) {
              firebaseAnalytics.setCurrentScreen(screenName: '/profile');
            } else {
              firebaseAnalytics.setCurrentScreen(screenName: '/home');
            }
          },
          items: [
            BottomNavigationBarItem(
                icon: Text("Home".tr,
                    key: const Key("home_nav"),
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 10))),
            BottomNavigationBarItem(
                icon: Text("History".tr,
                    key: const Key("history_nav"),
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 10))),
            BottomNavigationBarItem(
                icon: Text("Covid Info".tr,
                    key: const Key("info_nav"),
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 11))),
            BottomNavigationBarItem(
                icon: Text("Article & News".tr,
                    key: const Key("discovery_nav"),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 11))),
            BottomNavigationBarItem(
                icon: Text("Me".tr,
                    key: const Key("profile_nav"),
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 11))),
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 1:return HistoryScreen();
            case 2:return const InfoScreen();
            case 3:return  const DiscoveryScreen();
            case 0:return const HomeScreen();
            default:return const ProfileScreen();
          }
        });
  }

  Future<void> _initUniLinks() async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _processReferral(initialUri);
      }

      _streamSubscription = uriLinkStream.listen((Uri? uri) {
        if (uri != null) _processReferral(uri);
      }, onError: (err) {
        Toast.show(context, 'danger', 'Failed to execute link.');
      });
    } on FormatException {
      Toast.show(context, 'danger', 'Failed to execute link.');
    } on PlatformException {
      Toast.show(context, 'danger', 'Failed to execute link.');
    }
  }
  Future<void> _processReferral(Uri uri) async {
  
  }
}
