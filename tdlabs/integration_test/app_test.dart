import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tdlabs/main.dart' as app;
import 'robots/cart_robot.dart';
import 'robots/catalog_robot.dart';
import 'robots/history_robot.dart';
import 'robots/home_robot.dart';
import 'robots/login_robot.dart';
import 'robots/logout_robot.dart';
import 'robots/splash_robot.dart';
import 'robots/category_robot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  SplashRobot splashRobot;
  LoginRobot loginRobot;
  HomeRobot homeRobot;
  HistoryRobot historyRobot;
  CartRobot cartRobot;
  CategoryRobot categoryRobot;
  CatalogRobot catalogRobot;
  LogoutRobot logoutRobot;
  group('e2e test', () {
    testWidgets(
      'whole app',
      (WidgetTester tester) async {
        app.main();
        splashRobot = SplashRobot(tester);
        loginRobot = LoginRobot(tester);
        homeRobot = HomeRobot(tester);
        historyRobot = HistoryRobot(tester);
        cartRobot = CartRobot(tester);
        categoryRobot = CategoryRobot(tester);
        catalogRobot = CatalogRobot(tester);
        logoutRobot = LogoutRobot(tester);
        await tester.pumpAndSettle();
        binding.framePolicy =
            LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
        //splash

        await splashRobot.init();
        //login
        await loginRobot.init();
        await loginRobot.enterId();
        await loginRobot.enterPassword();
        await loginRobot.login();
        //home
        await binding.watchPerformance(() async {
          await homeRobot.init();
          await homeRobot.scrollThePage(scrollUp: true);
          await homeRobot.findVar();
          await homeRobot.navHistory();
          //history
          await historyRobot.init();
          await historyRobot.scrollThePage();
          await historyRobot.scrollThePage(scrollUp: true);
          await historyRobot.navHome();

          //home
          await homeRobot.init();
          await homeRobot.findMall();
          await categoryRobot.tapCategoryItem();
          //mall
          await catalogRobot.initMall();
          await catalogRobot.tapMallItem();
          await catalogRobot.addCart();
          await catalogRobot.enterQuantity();
          await catalogRobot.send();
          //cart
          await cartRobot.init();
          await cartRobot.checkOut();
          await cartRobot.selectAddress();
          await cartRobot.selectState();
          await cartRobot.stateConfirm();
          await cartRobot.submitAddress();
          await cartRobot.confirmCheckout();
          await cartRobot.pay();
          await cartRobot.back();
          await logoutRobot.navProfile();
          await logoutRobot.logout();
        }, reportKey: "home");
      },
    );
  });
}
