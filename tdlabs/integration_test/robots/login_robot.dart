import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdlabs/screens/home/home_screen.dart';

class LoginRobot {
  const LoginRobot(this.tester);

  final WidgetTester tester;
  Future<void> init() async {
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  Future<void> enterId() async {
    final inputFinder = find.byKey(const Key("username"));
    await tester.tap(inputFinder);
    await tester.enterText(inputFinder, "6969");
  }

  Future<void> enterPassword() async {
    final inputFinder = find.byKey(const Key("password"));
    await tester.tap(inputFinder);
    await tester.enterText(inputFinder, "123456");
  }

  Future<void> login() async {
    final btnFinder = find.byKey(const Key("login_button"));
    await tester.tap(btnFinder);

    await tester.pumpAndSettle(const Duration(milliseconds: 1000));
    expect(find.byType(HomeScreen), findsWidgets);
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
