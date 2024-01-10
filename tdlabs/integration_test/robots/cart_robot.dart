import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class CartRobot {
  const CartRobot(this.tester);

  final WidgetTester tester;
  Future<void> init() async {
    await tester.pumpAndSettle(const Duration(seconds: 1));
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

  Future<void> findItem() async {
    final itemFinder = find.byKey(const Key("item_tap 0"));
    await tester.tap(itemFinder);
    await tester.pumpAndSettle();
  }

  Future<void> plusItem() async {
    final plusFinder = find.byKey(const Key("plus 0"));
    await tester.tap(plusFinder);
    await tester.pumpAndSettle();
  }

  Future<void> minusItem() async {
    final minusFinder = find.byKey(const Key("minus 0"));
    await tester.tap(minusFinder);
    await tester.pumpAndSettle();
  }

  Future<void> checkOut() async {
    final outFinder = find.byKey(const Key("checkout"));
    await tester.tap(outFinder);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> selectAddress() async {
    final outFinder = find.byKey(const Key("address"));
    await tester.tap(outFinder);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> selectState() async {
    final outFinder = find.byKey(const Key("state"));
    await tester.tap(outFinder);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> stateConfirm() async {
    final outFinder = find.byKey(const Key("state_confirm"));
    await tester.tap(outFinder);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> submitAddress() async {
    final outFinder = find.byKey(const Key("address_submit"));
    await tester.tap(outFinder);
    await tester.pumpAndSettle();
  }

  Future<void> confirmCheckout() async {
    final outFinder = find.byKey(const Key("confirm_checkout"));
    await tester.tap(outFinder);
    await tester.pumpAndSettle();
  }

  Future<void> pay() async {
    final outFinder = find.byKey(const Key("confirm"));
    await tester.tap(outFinder);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  Future<void> back() async {
    final outFinder = find.byKey(const Key("back"));
    await tester.tap(outFinder);
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
