import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdlabs/screens/catalog/cart_screen.dart';
import 'package:tdlabs/screens/catalog/catalog_screen.dart';
import 'package:tdlabs/screens/history/history_screen.dart';
import 'package:tdlabs/screens/info/discovery_screen.dart';
import 'package:tdlabs/screens/info/info_screen.dart';
import 'package:tdlabs/screens/user/profile.dart';
import 'package:tdlabs/widgets/banner.dart';

class HomeRobot {
  const HomeRobot(this.tester);

  final WidgetTester tester;
  Future<void> init() async {
    await tester.pump(const Duration(seconds: 4000));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key("home_screen")), findsWidgets);
  }

  Future<void> findVar() async {
    final nameFinder = find.byKey(const Key("user_info"));
    expect(nameFinder, findsWidgets);
    await tester.pumpAndSettle();
    final statusFinder = find.byKey(const Key("user_status"));
    expect(statusFinder, findsWidgets);
    await tester.pumpAndSettle();
    final pointFinder = find.byKey(const Key("user_points"));
    expect(pointFinder, findsWidgets);
    await tester.pumpAndSettle();
    final bannerFinder = find.byType(BannerAdapter);
    expect(bannerFinder, findsWidgets);
    await tester.pumpAndSettle();
  }

  Future<void> findMall() async {
    final mallFinder = find.byKey(const Key("home_button6"));
    await tester.tap(mallFinder);
    await tester.pumpAndSettle();
    expect(find.byType(CatalogScreen), findsWidgets);
  }

  Future<void> findCart() async {
    final cartFinder = find.byKey(const Key("cart_button"));
    await tester.tap(cartFinder);
    await tester.pumpAndSettle();
    expect(find.byType(CartScreen), findsWidgets);
  }

  Future<void> scrollThePage({bool scrollUp = false}) async {
    final listFinder = find.byKey(const Key('singleChildScrollView'));

    if (scrollUp) {
      await tester.fling(listFinder, const Offset(0, 500), 10000);
      await tester.pumpAndSettle();
    } else {
      await tester.fling(listFinder, const Offset(0, -500), 10000);
      await tester.pumpAndSettle();
    }
  }

  Future<void> navHistory() async {
    final navFinder = find.byKey(const Key("history_nav"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsWidgets);
  }

  Future<void> navInfo() async {
    final navFinder = find.byKey(const Key("info_nav"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
    expect(find.byType(InfoScreen), findsWidgets);
  }

  Future<void> navDiscovery() async {
    final navFinder = find.byKey(const Key("discovery_nav"));
    await tester.tap(navFinder);
    await tester.pumpAndSettle();
    expect(find.byType(DiscoveryScreen), findsWidgets);
  }

  Future<void> navProfile() async {
    final navFinder = find.byKey(const Key("profile_nav"));
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
