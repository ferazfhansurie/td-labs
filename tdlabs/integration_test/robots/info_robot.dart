import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdlabs/screens/info/discovery_screen.dart';

class InfoRobot {
  const InfoRobot(this.tester);

  final WidgetTester tester;
  Future<void> init() async {
    await tester.pumpAndSettle();
    expect(find.byKey(const Key("info_screen")), findsWidgets);
  }

  Future<void> findWebview() async {
    final webFinder = find.byKey(const Key("web_view"));

    expect(webFinder, findsWidgets);
    await tester.pumpAndSettle();
  }

  Future<void> scrollThePage({bool scrollUp = false}) async {
    final listFinder = find.byKey(const Key('singleChildScrollView'));
    sleep(const Duration(seconds: 2));
    if (scrollUp) {
      await tester.fling(listFinder, const Offset(0, 500), 10000);
      await tester.pumpAndSettle();
    } else {
      await tester.fling(listFinder, const Offset(0, -500), 10000);
      await tester.pumpAndSettle();
    }
  }

  Future<void> navDiscovery() async {
    final navFinder = find.byKey(const Key("discovery_nav"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
    expect(find.byType(DiscoveryScreen), findsWidgets);
  }

  Future<void> navHome() async {
    final navFinder = find.byKey(const Key("home_nav"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
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
