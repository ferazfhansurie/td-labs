import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdlabs/screens/user/login.dart';

class SplashRobot {
  SplashRobot(this.tester);

  final WidgetTester tester;
  Future<void> init() async {
    await tester.pumpAndSettle(const Duration(milliseconds: 5000));
  }

  Future<void> checkLogin() async {
    await tester.pumpAndSettle(const Duration(milliseconds: 1000));
    expect(find.byType(LoginScreen), findsWidgets);
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
