import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdlabs/screens/info/discovery_screen.dart';
import 'package:tdlabs/screens/user/profile.dart';

class CatalogRobot {
  const CatalogRobot(this.tester);

  final WidgetTester tester;
  Future<void> initMall() async {
    await tester.pumpAndSettle();
    expect(find.byKey(const Key("mall_screen")), findsWidgets);
  }

  Future<void> initVM() async {
    await tester.pumpAndSettle();
    expect(find.byKey(const Key("vm_screen")), findsWidgets);
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

  Future<void> tapMallItem() async {
    final itemFinder = find.byKey(const Key("mall_tap 0"));
    await tester.tap(itemFinder);
    await tester.pumpAndSettle();
  }

  Future<void> tapVMItem() async {
    final itemFinder = find.byKey(const Key("vm_tap 0"));
    await tester.tap(itemFinder);
    await tester.pumpAndSettle();
  }

  Future<void> addCart() async {
    final itemFinder = find.byKey(const Key("add_cart"));
    await tester.tap(itemFinder);
    await tester.pumpAndSettle();
  }

  Future<void> enterQuantity() async {
    final inputFinder = find.byKey(const Key("quantity_cart"));
    await tester.tap(inputFinder);
    await tester.enterText(inputFinder, "3");
    await tester.pumpAndSettle();
  }

  Future<void> send() async {
    final inputFinder = find.byKey(const Key("send"));
    await tester.tap(inputFinder);
    await tester.pumpAndSettle();
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
