import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdlabs/screens/info/discovery_screen.dart';
import 'package:tdlabs/screens/user/profile.dart';

class HistoryRobot {
  const HistoryRobot(this.tester);

  final WidgetTester tester;
  Future<void> init() async {
    await tester.pumpAndSettle();
    expect(find.byKey(const Key("history_screen")), findsWidgets);
  }

  Future<void> scrollThePage({bool scrollUp = false}) async {
    final listFinder = find.byKey(const Key('history_scroll'));

    if (scrollUp) {
      await tester.fling(listFinder, const Offset(0, 500), 10000);
      await tester.pumpAndSettle();
    } else {
      await tester.fling(listFinder, const Offset(0, -500), 10000);
      await tester.pumpAndSettle();
    }
  }

  Future<void> tapPending() async {
    final navFinder = find.byKey(const Key("history_tab1"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
  }

  Future<void> tapActive() async {
    final navFinder = find.byKey(const Key("history_tab2"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
  }

  Future<void> tapComplete() async {
    final navFinder = find.byKey(const Key("history_tab3"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
  }

  Future<void> tapHistory() async {
    final navFinder = find.byKey(const Key("history_tap 0"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
    sleep(const Duration(seconds: 2));
  }

  Future<void> navInfo() async {
    final navFinder = find.byKey(const Key("info_nav"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
  }

  Future<void> tapDone() async {
    final navFinder = find.byKey(const Key("done"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
    sleep(const Duration(seconds: 2));
  }

  Future<void> navHome() async {
    final navFinder = find.byKey(const Key("home_nav"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
  }

  Future<void> navDiscovery() async {
    final navFinder = find.byKey(const Key("discovery_screen"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
    expect(find.byType(DiscoveryScreen), findsWidgets);
  }

  Future<void> navProfile() async {
    final navFinder = find.byKey(const Key("profile_screen"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsWidgets);
  }
}

class FinderType extends Finder {
  FinderType(this.finder, this.key);

  final Finder finder;
  final Key key;

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    return finder.apply(candidates);
  }

  @override
  String get description => finder.description;

  Finder get title => find.descendant(of: this, matching: find.byKey(key));
}
