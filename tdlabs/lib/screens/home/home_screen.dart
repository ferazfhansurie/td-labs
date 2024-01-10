// ignore_for_file: curly_braces_in_flow_control_structures, prefer_final_fields, non_constant_identifier_names, unused_element, unused_local_variable, deprecated_member_use, duplicate_ignore, library_prefixes, empty_catches, unused_field, unnecessary_null_comparison, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' as Get;
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:health/health.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:tdlabs/adapters/util/pdf_view.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/commerce/catalog.dart';
import 'package:tdlabs/models/content/banners.dart';
import 'package:tdlabs/models/commerce/cart.dart';
import 'package:tdlabs/models/content/event.dart';
import 'package:tdlabs/models/health/goals.dart';
import 'package:tdlabs/models/util/id_verify.dart';
import 'package:tdlabs/models/commerce/product_history.dart';
import 'package:tdlabs/models/util/redeem.dart';
import 'package:tdlabs/screens/catalog/cart_screen.dart';

import 'package:tdlabs/screens/catalog/catalog_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:tdlabs/screens/catalog/vm_select.dart';
import 'package:tdlabs/screens/catalog/vm_type.dart';
import 'package:tdlabs/screens/free/free_select.dart';

import 'package:tdlabs/screens/health/goal.dart';
import 'package:tdlabs/screens/health/goal_detail.dart';
import 'package:tdlabs/screens/history/history_screen.dart';
import 'package:tdlabs/screens/info/banner_screen.dart';
import 'package:tdlabs/screens/info/subscription.dart';
import 'package:tdlabs/screens/medical/others/health_screening.dart';
import 'package:tdlabs/screens/medical/screening/steps.dart';
import 'package:tdlabs/screens/medical/screening/test_form.dart';
import 'package:tdlabs/screens/medical/travel/travel_select.dart';
import 'package:tdlabs/screens/others/membership.dart';
import 'package:tdlabs/services/notification.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/screens/wellness/wellness_type.dart';
import 'package:tdlabs/screens/user/notification_screen.dart';
import 'package:transition/transition.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/content/popup.dart';
import '../../models/user/user.dart';
import '../../widgets/button/homebutton.dart';
import '../history/product_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  String accessToken = '';
  String _name = '';
  String _points = '';
  String _date = '';
  String reward = '';
  String _testDate = '';
  String days = "";
  String latitude = "";
  String longitude = "";
  String tdc = "";
  String? last_redeem;
  String? avatar;
  int _healthStatus = 0;
  int test = 0;
  int testPositive = 0;
  int redeem_limit = 0;
  int policy = 0;
  int end = 0;
  int diff = 0;
  int language = 0;
  int totalNoti = 0;
  int totalCart = 0;
  int totalOrder = 0;
  int verificationStatus = 0;
  int? redeem_count;
  double latest_app_ver = 0.0;
  double _percent = 0;
  double convert = 0;
  int _current = 0;
  bool showInvite = false;
  bool permissionLocation = false;
  bool permissionStorage = false;
  bool permissionCamera = false;
  bool isPop = false;
  bool? valid_redeem;
  bool? enabledTest = false;
  bool? enabledSimka = false;
  bool? enabledButton1 = false;
  List<int> popup = [];
  List<Redeem> _list = [];
  List<Popup> _poplist = [];
  List<Event> _poplist2 = [];
  List<Banners> _listBanner = [];
  List<dynamic>? _cartList;
  List<dynamic>? _cartList2;
  List<ProductHistory>? _orderList = [];
  DateTime dt = DateTime.now();
  Color _statusColor = CupertinoColors.white;
  PlatformFile? pickedFile;
  File? image;
  int gift_claimed = 0;
  int free_voucher_used = 0;
  NumberFormat myFormat = NumberFormat("#,##0.00", "en_US");
  final keyIsFirstLoaded = 'is_first_loaded';
  bool privacy = false;
  bool isRequestingPermission = false;
  final ScrollController _controllerOne = ScrollController();
  late PageController _pageController;
  late PageController _pageController2;
  int _focusedIndex = 1;
  double bannerSize = 250;
  String steps = "0";
  String bpm = "0";
  String calories = "0";
  Goal? goal;
  List<String> activities = [];
  List<dynamic> oauth = [];
  List<dynamic> _voucherList = [];
  String userQr ="";
  final locales = [
    {
      'name': 'English',
      'locale': const Locale('en', 'US'),
    },
    {'name': 'Bahasa Malaysia', 'locale': const Locale('ms', 'MY')},
    {'name': '简体中文'.tr, 'locale': const Locale('zh', 'ZH')},
  ];
  late Widget _statusWidget;
  late Widget _statusWidget2;
  List<Map<String, dynamic>> goals = [
    {
      "name": "Steps",
      "icon": Icons.directions_walk,
      "value": 0,
    },
    {
      "name": "Heart Rate",
      "icon": Icons.favorite,
      "value": 0,
    },
    {
      "name": "Calories",
      "icon": Icons.local_fire_department,
      "value": 0,
    }
  ];
  bool googleHealthSkip = false;
  bool googleHealth = false;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  String _result = 'HMS availability result code: unknown';
  List<String> _eventList = ['Availability result events will be listed'];
  String _token = '';
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  bool healthShown = false;

  @override
  void initState() {
    super.initState();
  
    if (Platform.isIOS) {
      googleHealth = true;
    }else{
 // _initHuawei();
    }
    if (mounted) {
      _fetchBanners();
      _pageController2 = PageController();
      _refreshContent();
      _getAccessToken();
    }
    //notification trigger
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    _checkPopup(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageController2.dispose();
    super.dispose();
  }

  Future<void> _initHuawei() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.manufacturer == "HUAWEI") {
      initTokenStream();
    }
  }

  void _onTokenEvent(String event) {
    // Requested tokens can be obtained here
    setState(() {
      _token = event;
    });
  }

  void _onTokenError(Object error) {
    PlatformException e = error as PlatformException;
  }

  Future<void> initTokenStream() async {
    if (!mounted) return;

  }

  void getToken() {
    // Call this method to request a token

  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    });
  }

  daysLeft() {
    if (_healthStatus == 0) {
      days = "0";
    } else if (_healthStatus == 4) {
      for (int i = 0; i < 8; i++) {
        if (percentCalculate(test, _healthStatus) * 7 == i) {
          days = (i).toString();
        }
      }
    } else {
      for (int i = 0; i < 15; i++) {
        if (percentCalculate(test, _healthStatus) * 14 == i) {
          days = (i).toString();
        }
      }
    }
    return days;
  }

  percentCalculate(int test, int healthstatus) {
    int day = dt.day;
    int lastday = DateTime(dt.year, dt.month, 0).day;
    if (_healthStatus != 4) {
      end = test + 14;
    } else {
      end = testPositive;
    }
    if (end > lastday) {
      end = end - lastday;
      if (end - day < 0) {
        day = day - lastday;
      }
    }
    if (end - day > 14) {
      end = end - lastday;
    }
    diff = end - day;
    if (_healthStatus == 4) {
      for (int i = 0; i < 8; i++) {
        if (diff == i) {
          setState(() {
            _percent = i / 7;
          });
        }
      }
    } else if (diff < 0 && healthstatus != 0 && healthstatus != 4) {
      end = end + 14;
      diff = end - day;
      _percent = diff / 14;
      if (diff < 0) {
        end = end + 14;
        diff = end - day;
        _percent = diff / 14;
      }
    } else {
      for (int i = 0; i < 15; i++) {
        if (diff == i) {
          _percent = i / 14;
        }
      }
    }
    return _percent;
  }

  healthStatus() {
    String statusText = 'No Status';
    switch (_healthStatus) {
      case 1:
        // GREEN status
        statusText = daysLeft();
        _statusColor = const Color.fromARGB(255, 19, 209, 67);
        break;
      case 2:
        // YELLOW status
        statusText = daysLeft();
        _statusColor = const Color.fromARGB(255, 255, 214, 52);
        break;
      case 3:
        // ORANGE status
        statusText = daysLeft();
        _statusColor = const Color.fromARGB(255, 255, 175, 62);
        break;
      case 4:
        // RED status
        statusText = daysLeft();
        _statusColor = const Color.fromARGB(255, 255, 29, 17);
        break;
      default:
    }
  }

  status() {
    double complete = (goal != null) ? double.parse(steps) / goal!.steps : 0;
    if (complete <= 1) {
      complete = complete;
    } else {
      complete = 1;
    }
    _statusWidget = GestureDetector(
      onTap: () async {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return const GoalScreen();
        }));
      },
      child: CircularPercentIndicator(
        radius: 80,
        lineWidth: 15.0,
        percent: 1,
        progressColor: Colors.white,
        center: CircularPercentIndicator(
            backgroundColor: Colors.white,
            radius: 75.0,
            lineWidth: 5.0,
            percent: complete,
            animation: true,
            animationDuration: 1200,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  (goal != null)
                      ? "${(complete * 100).toStringAsFixed(0)}%"
                      : "0 %",
                  style: const TextStyle(
                      fontSize: 38,
                      color: Color.fromARGB(255, 100, 233, 104),
                      fontWeight: FontWeight.w700),
                ),
                const Text(
                  "Complete",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            progressColor: const Color.fromARGB(255, 100, 233, 104)),
      ),
    );
  }

  Widget status2() {
    return _statusWidget2 = GestureDetector(
      onTap: () {
        showPicture(context);
      },
      child: CircularPercentIndicator(
          radius: 45.0,
          lineWidth: 55.0,
          percent: (_percent < 0 || _healthStatus == 3 || _healthStatus == 0)
              ? 1
              : _percent,
          animation: true,
          animationDuration: 1200,
          center: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
                height: 70,
                width: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: (image == null)
                    ? (avatar == null)
                        ? Image.asset('assets/images/icons-colored-00.png',
                            fit: BoxFit.fill)
                        : Image.network(
                            avatar!,
                            fit: BoxFit.cover,
                          )
                    : Image.file(
                        File(image!.path),
                        fit: BoxFit.cover,
                      )),
          ),
          progressColor: _statusColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    //set status color
    healthStatus();
    //set status pic
    status();
    return WillPopScope(
      onWillPop: () async {
        const shouldPop = true;
        showExit(context);
        return shouldPop;
      },
      child: Stack(
        children: [
          CupertinoPageScaffold(
              key: const Key("home_screen"),
              child: RefreshIndicator(
                  onRefresh: _refreshContent,
                  child: Column(
                    children: [
                      Container(height: 32, color: Colors.white),
                      Flexible(
                          child: SingleChildScrollView(
                        key: const Key('singleChildScrollView'),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(children: [
                          Padding(
                              padding: EdgeInsets.only(
                               
                                  left: 20,
                                  right: 20),
                              child: _header()),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15,
                              left: 15,
                              right: 15,
                            ),
                            child: SizedBox(
                              height: 300,
                              child: Column(
                                children: [
                                  Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(80.0),
                                          topLeft: Radius.circular(20.0),
                                          bottomLeft: Radius.circular(20.0),
                                          bottomRight: Radius.circular(20.0),
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color.fromARGB(255, 52, 169, 176),
                                            Color.fromARGB(255, 49, 42, 130),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 260,
                                                child: PageView.builder(
                                                  itemCount: 2,
                                                  controller: _pageController2,
                                                  onPageChanged: (index) {
                                                    setState(() {
                                                      _current = index;
                                                    });
                                                  },
                                                  itemBuilder: ((context, index) {
                                                    return Column(
                                                      children: [
                                                        (index == 0)
                                                            ? _historyWidget()
                                                            : _healthWidget(),
                                                        const Spacer(),
                                                      ],
                                                    );
                                                  }),
                                                ),
                                              ),
                                              Container(
                                                alignment: Alignment.bottomCenter,
                                                height: 20,
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    itemCount: 2,
                                                    itemBuilder: (context, index) {
                                                      return Padding(
                                                        padding: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 4),
                                                        child: Container(
                                                            width: 8.0,
                                                            height: 8.0,
                                                            decoration: BoxDecoration(
                                                                shape:
                                                                    BoxShape.circle,
                                                                color: (_current !=
                                                                        index
                                                                    ? const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        233,
                                                                        233,
                                                                        233)
                                                                    : const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        80,
                                                                        80,
                                                                        80)))),
                                                      );
                                                    }),
                                              )
                                            ],
                                          ))),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              const Text("Other Functions",
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400)),
                              _navButton(),
                              if (_listBanner.length > 2) _displayBanners(),
                            ],
                          ),
                        ]),
                      )),
                    ],
                  ))),
                  Positioned(
                    right: 15,
                    bottom: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12)
                        ,color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                   
                      child: 
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                               decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                                              color: Color.fromARGB(255, 49, 42, 130),
                                              ),
                                              height: 50,
                        
                          child: Row(children: [
                            SizedBox(width: 10,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(_points,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                                Text('TDC',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700),)
                              ],
                            ),
                            SizedBox(width: 10,),
                            QrImageView(
                              padding: EdgeInsets.zero,
                              size: 30,
                                  version: QrVersions.auto,
                                  data: userQr,
                                  gapless: true,
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                ),
                                 SizedBox(width: 10,),
                          ]),
                        ),
                      ),))
        ],
      ),
    );
  }

  Future<void> _refreshContent() async {
    _fetchUser();
    _fetchCart();
    fetchOrder();
    if (MainConfig.test == false) {
      _checkRedeem();
    }
  }

  Future removeImage() async {
    var response = await User.deletedAvatar(context);
    if (response != null) {
      if (response.status) {
        Toast.show(context, 'success', 'Avatar Deleted.');
      } else if (response.error.isNotEmpty) {
        Toast.show(context, 'danger', 'Fail');
      }
      setState(() {
        avatar = null;
        image = null;
      });
    }
  }

  Future selectImage() async {
    final GlobalKey progressDialogKey = GlobalKey<State>();
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      ProgressDialog.show(context, progressDialogKey);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException {}
    Uint8List imageData = await File(image!.path).readAsBytes();
    final decodedImage = img.bakeOrientation(img.decodeImage(imageData)!);
    var imageData2 = Uint8List.fromList(img.encodePng(decodedImage));
    String imageDecode = base64.encode(imageData2);
    var response = await User.uploadAvatar(context, imageDecode);
    ProgressDialog.hide(progressDialogKey);
    if (response != null) {
      if (response.status) {
        Toast.show(context, 'success', 'Avatar Uploaded.');
      } else if (response.error.isNotEmpty) {
        Toast.show(context, 'danger', 'Fail');
      }
    }
  }

  Future<List<dynamic>?> _fetchCart() async {
    final webService = WebService(context);
    if (mounted) {
      var response = await CatalogCart.fetchCart(context, 0);
      var response2 = await CatalogCart.fetchCart(context, 1);
      if (response == null) return null;
      if (response.status || response2!.status) {
        _cartList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        _cartList2 =
            jsonDecode(response2!.body.toString()).cast<Map<String, dynamic>>();
        setState(() {
          totalCart = _cartList!.length + _cartList2!.length;
          setState(() {
            totalNoti = 0;
            totalNoti = totalCart;
          });
        });
      }
    }

    return _cartList;
  }

  Future<List<ProductHistory>?> fetchOrder() async {
    List<String> errors = [];
    var response = await ProductHistory.fetchHistory(context);
    if (response != null) {
      if (response.status) {
        var array =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<ProductHistory> productHistory = array
            .map<ProductHistory>((json) => ProductHistory.fromJson(json))
            .toList();
        setState(() {
          totalOrder = 0;
          _orderList!.addAll(productHistory);
          for (int i = 0; i < productHistory.length; i++) {
            if (productHistory[i].statusLabel == "Submitted" ||
                productHistory[i].statusLabel == "Shipped" ||
                productHistory[i].statusLabel == "Paid") {}
          }
          totalNoti = 0;
          totalNoti = totalCart;
        });
      }
    } else if (response!.error.isNotEmpty) {
      errors.add(response.error.values.toList()[0]);
    } else {
      errors.add('Server connection timeout.');
    }
    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
    return _orderList;
  }

  Future<String?> _getAccessToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    accessToken = sharedPreferences.getString('api.access_token')!;
    return accessToken;
  }

  void _handleMessage(RemoteMessage message) {
    print(message.data['url']);
    Future.delayed(Duration(seconds: 1)).then((_) {
      // Check if the state is still mounted before accessing the context.
      if (!mounted) return;

      if (message.data['type'] == '4') {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return PDFView(
            pdfUrl: message.data['url'],
            isTest: false,
          );
        }));
      } else if (message.data['type'] == '3') {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return HealthScreening(
            url: message.data['url'],
          );
        }));
      } else {
        _launchZoon(message.data['url']);
      }
    });
  }

  Future<void> _fetchUser() async {
       String? messagingToken = "";
    user = await User.fetchOne(context); // get current user
   messagingToken = await NotificationService().getFirebaseMessagingToken();
   
    getToken();
 
   
    print("messagingToken: " + messagingToken!);
    if (user != null) {
      setState(() {
        _name = user!.name!;
        if (user!.avatar_url != null) {
          avatar = user!.avatar_url;
        }
        latest_app_ver = double.parse(user!.latest_app_ver!.toString());
        language = user!.language!;
        _healthStatus = user!.healthStatus!;
        var convert = double.parse(user!.credit_cash!);
        tdc = myFormat.format(convert);
        var convert2 = double.parse(user!.credit!);
        _points = myFormat.format(convert2);
        var arr = _points.split('.');
        _points = arr[0];
         userQr = "tdlabs.co?reference_no=" +
            user!.referrerReference! +
            "&phone_no=" +
            user!.phoneNo!;
        _testDate = (user!.latest_test_at != null)
            ? user!.latest_test_at!.substring(0, 2)
            : "0";
        _fetchGoals();
        if (_healthStatus == 4) {
          testPositive = int.tryParse((user!.stat_lock != null)
              ? user!.stat_lock!.substring(8, 10)
              : "0")!;
          test = int.tryParse(_testDate)!;
        }
        if (_healthStatus != 0) {
          test = int.tryParse(_testDate)!;
        }
        if (user!.device_token == null ||
            user!.device_token != messagingToken) {
          User.updateDeviceToken(context, messagingToken!);
          _fetchUser();
        }
        if (MainConfig.test == false) {
          if (user!.policyAccepted != 1 &&
              Theme.of(context).platform == TargetPlatform.android &&
              privacy == false) {
            showAlertPermissionConsentDialog(context);
          }
          if (user!.policyAccepted == 1) {
            _checkPermission();
          }
        }
        oauth = user!.oauth_social!;
      });
      updateLocale(locales[language]['locale'] as Locale?, context);
      if (double.tryParse(MainConfig.APP_VER)! < latest_app_ver) {
        showUpdate(context);
      }
      setState(() {
        gift_claimed = user!.redeem_gift_status!;
        free_voucher_used = user!.gift_vouchers_used!;
      });
      fetchStatus(context);
      _percent = percentCalculate(test, _healthStatus);
    }
  }

  void updateLocale(Locale? locale, BuildContext context) {
    Get.Get.updateLocale(locale!);
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchZoon(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Goal?> _fetchGoals() async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('identity/user-biodata-goals/get');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      setState(() {
        Goal temp = Goal.fromJson(jsonDecode(response.body.toString()));
        goal = temp;
      });
    }
    goal ??= await _submitGoals(1000);
    return goal;
  }

  Future<Goal?> _submitGoals(int steps) async {
    final webService = WebService(context);
    webService
        .setMethod('POST')
        .setEndpoint('identity/user-biodata-goals/update');
    Map<String, String> data = {};
    data['steps'] = steps.toString();
    data['duration'] = "0";
    var response = await webService.setData(data).send();
    if (response == null) return null;
    if (response.status) {
      Goal temp = Goal.fromJson(jsonDecode(response.body.toString()));
      goal = temp;
    }
    return goal;
  }

  Future<List?> _checkFreeGift() async {
    _poplist2.clear();
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('marketing/events');
    Map<String, String> filter = {};
    filter.addAll({'type': '1'});
    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Event> event =
          parseList.map<Event>((json) => Event.fromJson(json)).toList();
      setState(() {
        _poplist2.addAll(event);
      });
      if (_poplist2.isNotEmpty) {
        isPop = true;
        _showFree(context);
      }
    }

    return _poplist2;
  }

  Future<List?> _checkPopup(int? i) async {
    _poplist.clear();
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('feed/popups');
    Map<String, String> filter = {};
    filter.addAll({'type': '0'});
    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Popup> pop =
          parseList.map<Popup>((json) => Popup.fromJson(json)).toList();
      setState(() {
        _poplist.addAll(pop);
        if (popup.isEmpty) {
          for (int i = 0; i < _poplist.length; i++) {
            popup.add(0);
          }
        }
      });
      if (_poplist.isNotEmpty) {
        for (int i = 0; i < _poplist.length; i++) {
          await Future.delayed((i == 0)
              ? const Duration(seconds: 3)
              : const Duration(seconds: 25));
          var route = Get.Get.currentRoute;
          if (route == "/home" &&
              popup[i] == 0 &&
              isPop == false &&
              privacy == false) {
            setState(() {
              popup[i] = 1;
              isPop = true;
            });
            showPopup(context, i);
          }
        }
      }
    }
    return _poplist;
  }

  Future<List?> _checkRedeem() async {
    _list.clear();
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('plan/rewards/get-package');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Redeem> redeem =
          parseList.map<Redeem>((json) => Redeem.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _list.addAll(redeem);
          valid_redeem = _list[0].is_valid!;
          reward = (valid_redeem == true) ? _list[0].reward_amount! : "0";
          var arr = reward.split('.');
          reward = arr[0];
          redeem_limit =
              (_list[0].redeem_limit != null) ? _list[0].redeem_limit! : 0;
          redeem_count =
              (_list[0].redeem_count != null) ? _list[0].redeem_count! : 0;
          _date = (_list[0].redeem_at != null)
              ? _list[0].redeem_at.toString()
              : "0";
        });
      }
      if (valid_redeem == true) {
        showAlertDialog(context);
      }
    }
    return _list;
  }

  Future<void> _sendPolicyStatus() async {
    final webService = WebService(context);
    webService.setMethod('PUT').setEndpoint('identity/users/accept-policy');
    Map<String, String> data = {};
    data.addAll({'policy_accepted': policy.toString()});
    var response = await webService.setData(data).send();
    if (response == null) return;
  }

  Future<void> fetchStatus(BuildContext context) async {
    var response = await IdVerify.fetch(context);
    if (response != null) {
      setState(() {
        verificationStatus = response['status'];
      });
    }
  }

  Future<List<Banners>?> _fetchBanners() async {
    _listBanner.clear();
    final webService = WebService(context);
    webService.setEndpoint('feed/banners');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Banners> banners =
          parseList.map<Banners>((json) => Banners.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _listBanner.addAll(banners);
        });
      }
    }
    _pageController = PageController(viewportFraction: 0.7, initialPage: 1);
    return _listBanner;
  }

  Widget _header() {
    return Column(
      children: [
        (!MainConfig.modeLive)
            ? Padding(
                padding: const EdgeInsets.all(1),
                child: Container(
                  alignment: Alignment.center,
                  color: CupertinoColors.systemRed,
                  width: MediaQuery.of(context).size.width * 10 / 100,
                  child: const Text(
                    'Dev',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white),
                  ),
                ),
              )
            : Container(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                key: const Key("user_info"),
                children: [
                  Row(
                    children: [
                      Text(
                        "Hello, ".tr,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          _name.length > 20
                              ? '${_name.substring(0, 20)}...'
                              : _name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
         //noti_icon.png
         GestureDetector(
          onTap: (){
  Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return NotificationScreen();
                      }));
          },
           child: Container(
            height: 35,
            child: Image.asset('assets/images/noti_icon.png')),
         ),
              const SizedBox(width: 8),
              GestureDetector(
                  onTap: () async {
                    await _refreshContent().then(
                      (value) {
                        _showMore(context);
                      },
                    );
                  },
                  child: Stack(
                    children: [
                      const Icon(
                        CupertinoIcons.ellipsis,
                        size: 30,
                      ),
                      if (totalNoti > 0)
                        Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemRed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 15,
                              minHeight: 15,
                            ),
                            child: Text(
                              totalNoti.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  )),
            ],
          )
        ]),
      ],
    );
  }

  Widget _healthWidget() {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Progress".tr,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: 105,
                    height: 200,
                    child: ListView.builder(
                        itemCount: 3,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: ((context, index) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    goals[index]['icon'],
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        (goals[index]['value'] != 0 &&
                                                goals[index]['value'] != "0" &&
                                                goals[index]['value'] != null)
                                            ? goals[index]['value'].toString()
                                            : "No Data",
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize:
                                                (goals[index]['value'] != 0 &&
                                                        goals[index]['value'] !=
                                                            "0")
                                                    ? 26
                                                    : 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.zero,
                                        child: Text(
                                          goals[index]['name'],
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 10,
                                              color: Color.fromARGB(
                                                  255, 214, 214, 214),
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Color.fromARGB(255, 214, 214, 214),
                              ),
                            ],
                          );
                        }))),
                Padding(
                    padding: const EdgeInsets.only(right: 10.0, top: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _statusWidget,
                        const SizedBox(
                          height: 15,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (oauth == [] || googleHealth == true) {
                              Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return const GoalDetail();
                              })).then((value) => {_refreshContent()});
                            } else {
                             // showGoogle(context, 1);
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                "Coming Soon ".tr,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400),
                              ),
                              const Icon(
                                Icons.arrow_right_alt,
                                size: 30,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyWidget() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return HistoryScreen(
            tab: true,
          );
        }));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Surveillance Status".tr,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(right: 10.0, top: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    status2(),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      key: const Key('user_status'),
                      children: [
                        Text(
                          (daysLeft() != "0") ? daysLeft() : "--",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 22,
                            color: _statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          " Days".tr,
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: _statusColor),
                        ),
                      ],
                    ),
                    Text(
                      "since your last screening".tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Details ".tr,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w400),
                          ),
                          const Icon(
                            Icons.arrow_right_alt,
                            size: 30,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _balance() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
              return Subscription(
                limit: redeem_limit,
                count: redeem_count,
                points: _points,
                date: _date,
                redeem: _list,
                tabIndex: 1,
                url: (!MainConfig.modeLive)
                    ? 'http://dev.tdlabs.co/subscription?token=$accessToken'
                    : 'http://cloud.tdlabs.co/subscription?token=$accessToken',
              );
            }));
          },
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
                height: 55,
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 24, 112, 141)
                          .withOpacity(0.6),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      key: const Key("user_points"),
                      children: [
                        Container(
                          alignment: Alignment.bottomCenter,
                          width: 100,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 24, 112, 141),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              "$_points TDC ",
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 5,
                            left: 5,
                          ),
                          child: Text(
                            "RM $tdc",
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Color.fromARGB(255, 24, 112, 141),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
              return Subscription(
                limit: redeem_limit,
                count: redeem_count,
                points: _points,
                date: _date,
                redeem: _list,
                tabIndex: 0,
                url: (!MainConfig.modeLive)
                    ? 'http://dev.tdlabs.co/subscription?token=$accessToken'
                    : 'http://cloud.tdlabs.co/subscription?token=$accessToken',
              );
            }));
          },
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
                height: 55,
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 24, 112, 141)
                          .withOpacity(0.6),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      key: const Key("user_points"),
                      children: [
                        Container(
                          width: 100,
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 24, 112, 141),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              "Daily Reward".tr,
                              maxLines: 1,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 5,
                            left: 5,
                          ),
                          child: Text(
                            (reward != "") ? "+$reward TDC" : "+0 TDC",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Color.fromARGB(255, 24, 112, 141),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Widget _navButton() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: ListView.builder(
        controller: _controllerOne,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: 4,
        itemBuilder: (context, index) {
          int number = index + 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: HomeButton(
              home: true,
              latitude: latitude,
              longitude: longitude,
              url: (!MainConfig.modeLive)
                  ? 'http://dev.tdlabs.co/subscription?token=$accessToken'
                  : 'http://cloud.tdlabs.co/subscription?token=$accessToken',
              index: index,
              image: 'assets/images/icons-colored-0$number.png',
              image2: 'assets/images/icons-white-0$number.png',
              limit: redeem_limit,
              count: redeem_count,
              accessToken: accessToken,
              points: _points,
              date: _date,
              redeem: _list,
              label: (index == 0)
                  ? 'Medical'.tr
                  : (index == 6)
                      ? 'Rewards'.tr
                      : (index == 4)
                          ? 'Smart Programme'.tr
                          : (index == 3)
                              ? 'More'.tr
                              : (index == 2)
                                  ? 'Vending Machine'.tr
                                  : (index == 5)
                                      ? 'Traveller Program'.tr
                                      : (index == 1)
                                          ? 'E-Commerce'.tr
                                          : 'More'.tr,
            ),
          );
        },
      ),
    );
  }

  Widget _displayBanners() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: SizedBox(
        height: 165,
        child: PageView.builder(
          clipBehavior: Clip.none,
          controller: _pageController,
          onPageChanged: (int index) {
            setState(() {
              _focusedIndex = index;
            });
          },
          itemCount: _listBanner.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
              child: Opacity(
                opacity: _focusedIndex == index ? 1.0 : 0.5,
                child: GestureDetector(
                  onTap: () async {
                    if (_listBanner[index].title == "Premium") {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return Membership(
                          url: (!MainConfig.modeLive)
                              ? 'http://dev.tdlabs.co/membership?token=$accessToken'
                              : 'http://cloud.tdlabs.co/membership?token=$accessToken',
                        );
                      }));
                    } else if (_listBanner[index].title ==
                        "Traveller's Programme") {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return const TravelSelectScreen();
                      }));
                    } else if (_listBanner[index].title == "Wellness") {
                      await _fetchProducts(context);
                    } else if (_listBanner[index].title == "Promotions") {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return Steps();
                      }));
                    } else if (_listBanner[index].title == "Self-Test Kit") {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return CatalogScreen();
                      }));
                    } else if (_listBanner[index].title == "RTK Travelers") {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return TestFormScreen(
                          optTestId: 1,
                          optTestName: "RT-PCR",
                        );
                      }));
                    } else if (_listBanner[index].title == "TD-Mart") {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return VmTypeScreen(
                          latitude: latitude,
                          longitude: longitude,
                        );
                      }));
                    } else if (_listBanner[index].url == "Free-Machine") {
                      final GlobalKey progressDialogKey = GlobalKey<State>();
                      ProgressDialog.show(context, progressDialogKey);
                      await _fetchUser();
                      ProgressDialog.hide(progressDialogKey);
                      if (free_voucher_used == 0) {
                        if (gift_claimed == 1) {
                          _checkFreeGift();
                        } else if (_listBanner[index].title == "VM-Select") {
                          Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return VmSelectScreen(
                                latitude: latitude,
                                longitude: longitude,
                                type: 0);
                          }));
                        } else {
                          Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return VmFreeSelectScreen();
                          }));
                        }
                      } else {
                        showPopupFree(context, _listBanner[index].imageUrl);
                      }
                    } else {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return BannerScreen(
                          title: _listBanner[index].title,
                        );
                      }));
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: bannerSize,
                    height: 165,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _listBanner[index].imageUrl,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _checkPermission() async {
    if (isRequestingPermission)
      return; // add a check to avoid making multiple requests
    isRequestingPermission =
        true; // set to true to indicate a permission request is in progress
    var statusLocation = await Permission.locationWhenInUse.request();
    var statusStorage = await Permission.storage.request();
    var statusCamera = await Permission.camera.request();
    var statusActivity = await Permission.activityRecognition.request();
    var permissionLocationStatus = await Permission.locationWhenInUse.status;
    var permissionCameraStatus = await Permission.camera.status;
    var permissionStorageStatus = await Permission.storage.status;
    var permissionActivity = await Permission.activityRecognition.status;
    if (permissionLocationStatus == PermissionStatus.granted) if (mounted) {
      setState(() {
        permissionLocation = true;
        getLocation();
      });
    }
    if (permissionCameraStatus == PermissionStatus.granted) if (mounted) {
      setState(() {
        permissionCamera = true;
      });
    }
    if (permissionStorageStatus == PermissionStatus.granted) if (mounted) {
      setState(() {
        permissionStorage = true;
      });
    }
    if (permissionActivity == PermissionStatus.granted) if (mounted) {
      setState(() {
        if (googleHealth == false) {
          if (user!.oauth_social!.isEmpty || user!.oauth_social == null) {
            if (googleHealthSkip == false &&
                user!.policyAccepted == 1 &&
                healthShown == false) {
              setState(() {
                healthShown = true;
              });
              //showGoogle(context, 0);
            }
          } else {
           // _getHealth();
          }
        } else {
          //_getHealth();
        }
      });
    }
    isRequestingPermission =
        false; // set to false to indicate the permission request is complete
  }

  _getHealth() async {
    googleHealth = true;
    HealthFactory health = HealthFactory();
    var types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];
    try {
      bool requested = await health.requestAuthorization(types);
    } catch (e) {
      // Handle any errors that occurred during data retrieval
      // You can choose to handle the error in a specific way or continue with the function
    }

    int totalSteps = 0;
    double heartRate = 0.0;
    double caloriesBurned = 0.0;
    double bmi = 0.0;
    double bfp = 0.0;
    int mindful = 0;
    double sleep = 0.0;
    int exercise = 0;
    WorkoutHealthValue work;
    try {
      var now = DateTime.now();
      DateTime startTime = now.subtract(const Duration(hours: 12));
      DateTime endTime = now;
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        startTime,
        endTime,
        types,
      );

      activities.clear();
      if (healthData != null) {
        for (var point in healthData) {
          switch (point.type) {
            case HealthDataType.WORKOUT:
              setState(() {
                work = point.value as WorkoutHealthValue;
                var temp = work.workoutActivityType.toString().split('.');
                activities.add(temp[1].toLowerCase());
              });
              break;
            case HealthDataType.STEPS:
              totalSteps += int.parse(point.value.toString());
              break;
            case HealthDataType.HEART_RATE:
              heartRate += double.parse(point.value.toString());
              break;
            case HealthDataType.ACTIVE_ENERGY_BURNED:
              caloriesBurned += double.parse(point.value.toString());
              break;
            default:
              break;
          }
        }
      }
    } catch (e) {
      print('Error during health data iteration: $e');
    }

    setState(() {
      print(totalSteps);
      steps = totalSteps.toString();
      bpm = heartRate.toStringAsFixed(0);
      calories = caloriesBurned.toStringAsFixed(0);
      for (int i = 0; i < goals.length; i++) {
        if (goals[i]['name'] == "Steps") {
          goals[i]['value'] = steps;
        } else if (goals[i]['name'] == "Heart Rate") {
          goals[i]['value'] = bpm;
        } else if (goals[i]['name'] == "Calories") {
          goals[i]['value'] = calories;
        } else if (goals[i]['name'] == "Body Mass Index") {
          goals[i]['value'] = bmi;
        } else if (goals[i]['name'] == "Body Fat Percentage") {
          goals[i]['value'] = bfp;
        } else if (goals[i]['name'] == "Mindfulness") {
          goals[i]['value'] = mindful;
        } else if (goals[i]['name'] == "Exercise") {
          goals[i]['value'] = exercise;
        } else if (goals[i]['name'] == "Sleep") {
          goals[i]['value'] = sleep.toStringAsFixed(0);
        }
      }
    });
  }

  Future<void> _fetchVoucher(List<Map<String, dynamic>> orderList,
      List<Map<String, dynamic>> orderNameList, List<Catalog> products) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('catalog/voucher-codes');
    var response = await webService.send();
    print(response!.body);
    if (response.status) {
      _voucherList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return WellnessTypeScreen(
          orderList: orderList,
          orderNameList: orderNameList,
          product: products[0],
          voucherList: _voucherList,
        );
      }));
    } else {
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return WellnessTypeScreen(
          orderList: orderList,
          orderNameList: orderNameList,
          product: products[0],
        );
      }));
    }
  }

  Future<void> _fetchProducts(BuildContext context) async {
    final webService = WebService(context);
    final GlobalKey progressDialogKey = GlobalKey<State>();
    webService.setEndpoint('catalog/catalog-products');
    Map<String, String> filter = {};
    filter.addAll({'type': '5'});
    ProgressDialog.show(context, progressDialogKey);
    var response = await webService.setFilter(filter).send();
    print(response!.body);
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Catalog> products =
          parseList.map<Catalog>((json) => Catalog.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          List<Map<String, dynamic>> orderList = [];
          List<Map<String, dynamic>> orderNameList = [];
          orderList.add({
            'product_id': products[0].id,
            'quantity': 1,
            'price': products[0].price,
            'total': 1,
            'cart_type': 0
          });
          orderNameList.add({
            'product_name': products[0].name,
            'product_url': products[0].image_url,
            'quantity': 1,
          });
          ProgressDialog.hide(progressDialogKey);
          _fetchVoucher(orderList, orderNameList, products);
        });
      }
    }
  }

  showPicture(BuildContext context) {
    Widget cancelButton = CupertinoButton(
      child: Center(
        child: Text(
          'Back'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget deleteButton = CupertinoButton(
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Text(
          'Remove Picture'.tr,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w300,
            color: Color.fromARGB(255, 104, 104, 104),
          ),
        ),
      ),
      onPressed: () {
        removeImage();
        Navigator.pop(context);
        _fetchUser();
      },
    );
    Widget continueButton = CupertinoButton(
      color: CupertinoTheme.of(context).primaryColor,
      child: Center(
        child: Text(
          'Select Picture'.tr,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w300,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      onPressed: () {
        selectImage();
        Navigator.pop(context);
        _fetchUser();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      title: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 5),
            child: Text(
              "Change Profile Picture".tr,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
                height: 100,
                width: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: (image == null)
                    ? (avatar == null)
                        ? Image.asset('assets/images/icons-colored-00.png',
                            fit: BoxFit.fill)
                        : FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: avatar!,
                            fit: BoxFit.cover,
                          )
                    : Image.file(
                        File(image!.path),
                        fit: BoxFit.cover,
                      )),
          ),
        ],
      ),
      actions: [
        continueButton,
        deleteButton,
        cancelButton,
      ],
    );
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(false), child: alert);
      },
    );
  }

  showExit(BuildContext context) {
    Widget cancelButton = CupertinoButton(
      key: const Key("pop_button"),
      child: Text(
        'Cancel'.tr,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        isPop = false;
        Navigator.pop(context);
      },
    );
    Widget continueButton = CupertinoButton(
      child: Text(
        'Quit'.tr,
        style: const TextStyle(
          color: Color.fromARGB(255, 255, 0, 0),
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(0);
        }
      },
    );
    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      contentPadding: const EdgeInsets.all(0.0),
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 52, 169, 176),
              Color.fromARGB(255, 49, 42, 130),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "Are you sure you want to exit the app?".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  continueButton,
                  cancelButton,
                ],
              ),
            )
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(true), child: alert);
      },
    );
  }

  showUpdate(BuildContext context) {
    Widget cancelButton = CupertinoButton(
      child: Text(
        'Skip'.tr,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = CupertinoButton(
      child: Text(
        'Update'.tr,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        StoreRedirect.redirect(
            androidAppId: "com.tedainternational.tdlabs",
            iOSAppId: "1554227226");
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "TD-LABS App Update Required".tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
      content: Text(
        "A new version of the app is available for download. Please update your app to continue using it"
            .tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 11,
          fontWeight: FontWeight.w300,
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(false), child: alert);
      },
    );
  }

  showGoogle(BuildContext context, int type) {
    Widget cancelButton = CupertinoButton(
      child: Text(
        'Skip'.tr,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
          color: Colors.red,
        ),
      ),
      onPressed: () {
        googleHealthSkip = true;
        Navigator.pop(context);
      },
    );
    Widget continueButton = GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        googleHealth = true;
        if (type == 0) {
         // _getHealth();
        } else {
         Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return const GoalDetail();
          }));
        }
      },
      child: Container(
          width: 200,
          height: 40,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 65, 133, 244),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Row(
              children: [
                Container(
                  height: 40,
                  color: Colors.white,
                  child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image:
                          'http://pngimg.com/uploads/google/google_PNG19635.png',
                      height: 20,
                      fit: BoxFit.cover),
                ),
                const SizedBox(width: 15),
                const Text('Sign in with Google',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          )),
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Column(
        children: [
          Text(
            "Google Sign In Required".tr,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: CupertinoTheme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      content: SizedBox(
        height: 165,
        child: Column(
          children: [
            Text(
              "To track your health data, please sign in to your Google account to authorize the necessary permissions for the app"
                  .tr,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Divider(),
            continueButton,
            cancelButton,
          ],
        ),
      ),
    );
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(false), child: alert);
      },
    );
  }

  _showMore(BuildContext context) {
    // set up the AlertDialog
    Widget alert = Container(
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        children: [
          AlertDialog(
            title: Text(
              'Options'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [

                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return OrderHistoryScreen();
                      }));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order History'.tr,
                            style: const TextStyle(fontSize: 16),
                          ),
                          Stack(
                            children: [
                              const Icon(
                                CupertinoIcons.clock_fill,
                                size: 30,
                              ),
                              if (totalOrder > 0)
                                Positioned(
                                  top: 0.0,
                                  right: 0.0,
                                  child: Container(
                                    padding: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 15,
                                      minHeight: 15,
                                    ),
                                    child: Text(
                                      totalOrder.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          Transition(
                              child: CartScreen(tab: 0),
                              transitionEffect:
                                  TransitionEffect.BOTTOM_TO_TOP));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cart'.tr,
                            style: const TextStyle(fontSize: 16),
                          ),
                          Stack(
                            children: [
                              const Icon(
                                CupertinoIcons.cart_fill,
                                size: 30,
                              ),
                              Positioned(
                                top: 0.0,
                                right: 0.0,
                                child: Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 15,
                                    minHeight: 15,
                                  ),
                                  child: Text(
                                    totalCart.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showFree(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = CupertinoButton(
      color: CupertinoTheme.of(context).primaryColor,
      key: const Key("pop_button"),
      child: Text(
        'Claim'.tr,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        _submitClaim(context);
      },
    );

    // set up the AlertDialog
    Container alert = Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  ClipRRect(
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: _poplist2[0].vouchers[0]['image_url'],
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(height: 10),
                  cancelButton
                ],
              ),
            ),
          ],
        ));
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(true), child: alert);
      },
    );
  }

  Future<void> _submitClaim(BuildContext context) async {
    Response? response;
    final GlobalKey progressDialogKey = GlobalKey<State>();
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('marketing/events/claim');
    Map<String, String> data = {};
    data['event_id'] = _poplist2[0].id.toString();
    ProgressDialog.show(context, progressDialogKey);
    response = await webService.setData(data).send();
    ProgressDialog.hide(progressDialogKey);
    if (response!.status) {
      isPop = false;
      Navigator.pop(context);
    } else {
      Toast.show(context, 'danger', "Unable to claim");
    }
  }

  showPopupFree(BuildContext context, String image) {
    // set up the buttons
    // ignore: deprecated_member_use
    // set up the AlertDialog
    Container alert = Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        const Text(
                          "You've already claimed your free gift",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        CupertinoButton(
                          color: CupertinoTheme.of(context).primaryColor,
                          child: Text(
                            'Go to Order History'.tr,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context)
                                .push(CupertinoPageRoute(builder: (context) {
                              return OrderHistoryScreen();
                            }));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                  },
                  child: const Icon(CupertinoIcons.clear_circled,
                      size: 40, color: Colors.white),
                ),
              )
            ],
          ),
        ));
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async {
              const shouldPop = true;
              Navigator.pop(context);
              return shouldPop;
            },
            child: alert);
      },
    );
  }

  showPopup(BuildContext context, int i) {
    // set up the buttons
    // ignore: deprecated_member_use
    // set up the AlertDialog
    Container alert = Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: GestureDetector(
          onTap: () {
            if (_poplist[i].url == "Promotion-Mall") {
              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                return CatalogScreen(
                  categoryId: 5,
                  promo: true,
                );
              }));
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FadeInImage.memoryNetwork(
                    fit: BoxFit.cover,
                    width: 300.0,
                    height: 400.0,
                    placeholder: kTransparentImage,
                    image: _poplist[i].image_url!),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    isPop = false;
                    Navigator.pop(context);
                    _checkPopup(1);
                  },
                  child: const Icon(CupertinoIcons.clear_circled,
                      size: 40, color: Colors.white),
                ),
              )
            ],
          ),
        ));
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async {
              const shouldPop = true;
              isPop = false;
              Navigator.pop(context);
              _checkPopup(1);
              return shouldPop;
            },
            child: alert);
      },
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = CupertinoButton(
      child: Text(
        'Cancel'.tr,
        style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w300,
            color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // ignore: deprecated_member_use
    Widget continueButton = CupertinoButton(
      child: Text(
        'Collect'.tr,
        style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return Subscription(
            limit: redeem_limit,
            count: redeem_count,
            date: _date,
            points: _points,
            redeem: _list,
            tabIndex: 0,
            url: (!MainConfig.modeLive)
                ? 'http://dev.tdlabs.co/subscription?token=$accessToken'
                : 'http://cloud.tdlabs.co/subscription?token=$accessToken',
          );
        }));
      },
    );

    Widget alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      content: Container(
        height: 200,
        width: 115,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 52, 169, 176),
              Color.fromARGB(255, 49, 42, 130),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: RichText(
                text: TextSpan(
                  text: 'Collect your '.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Daily Reward'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: ' Now!'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 75,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [continueButton, cancelButton],
              ),
            )
          ],
        ),
      ),
      contentPadding: const EdgeInsets.all(0.0),
    );
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(false), child: alert);
      },
    );
  }

  showAlertPermissionConsentDialog(BuildContext context) async {
    bool isAgreed = false;
    int isAgreedNum = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLoaded;
    bool? getFromPref = prefs.getBool(keyIsFirstLoaded);
    privacy = true;
    if (getFromPref != null) {
      isFirstLoaded = getFromPref;
    } else {
      isFirstLoaded = true;
    }
    // ignore: deprecated_member_use
    Widget continueButton = ElevatedButton(
      child: Text('Agree'.tr),
      onPressed: () {
        setState(() {
          prefs.setBool(keyIsFirstLoaded, false);
        });
        Navigator.pop(context);
        showAlertPrivacyConsentDialog(context);
      },
    );
    Widget alert = AlertDialog(
      insetPadding: const EdgeInsets.all(5),
      titlePadding: EdgeInsets.zero,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, left: 15),
            child: Text(
              'Consent & Permission Request'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Column(children: [
          SizedBox(
              height: MediaQuery.of(context).size.height * 57 / 100,
              child: const Scrollbar(
              
                child: Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Updated on 9th June 2023',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 13),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Our Privacy Policy is designed to give you a comprehensive understanding of the steps that we take to protect the personal information that you share with us, and we would always recommend that you read it in full.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 13),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'We would ask for the following permission while using respective features in the App to give you a better experience and assist in managing, monitor and mitigate the COVID-19 outbreaks in Malaysia via TD-Labs,TD-Labs provide end-to-end solutions services of RTK Antigen Self-Test monitoring result and its status to determine the individual’s eligibility for travel or entry into public spaces.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 13),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'I hereby consent to the processing of the personal data that I have provided and declare my agreement with the data protection regulations in the data privacy statement below: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 13),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GPS Location',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "We request access to your device's gps location to enhance your experience and provide you with location-based features such as hotspot tracking, location assessment, and locating nearby health facilities",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.storage,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Image & Files',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'We may request access to your files and photos to allow you to set up your profile picture, download infographic announcements, and access test results within the app',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.video_camera_back,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Audio & Videos Recording',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'During the self-test process, we may request permission to record audio and video to generate SIMKA verification reports by Point of Care. This data is solely used for diagnostic purposes and is not shared with any third parties',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.camera,
                              color: Colors.green,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Camera',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "We request access to your device's camera to enable you to scan QR codes on the cassette provided for the purpose of self-testing. The camera access is only used for this specific functionality and is not used for any other purpose",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.phone,
                              color: Colors.yellow,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Phone',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'To facilitate compliance with the rules and Standard Operating Procedures (SOP) issued under the Prevention and Control of Infectious Diseases Act 1988, we request permission to register and allow you to directly dial the Health Centre dealing with COVID-19',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.directions_run,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Google Fit',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "We provide the opportunity to sync our Products with Google’s Fit SDK which is an open platform that lets users control their fitness data.Within Google Fits settings you can decide if you want to allow the Products to read personal data listed in Google Fit and import it to the Products, to write personal data collected in our Products in Google Fit or both",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              color: Colors.purple,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Activity Recognition',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "We collect physical activity data obtained through activity recognition to track exercise activity, including steps, heart rate, calories burned, and other relevant metrics. This data helps us provide personalized insights, set goals, and monitor your progress towards achieving a healthy lifestyle",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
          Column(
            children: [
              const Divider(
                height: 5,
                thickness: 2,
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text(
                  'I hereby agree and confirm to the terms and conditions stipulated herein',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                value: isAgreed,
                activeColor: CupertinoTheme.of(context).primaryColor,
                onChanged: (bool? newValue) {
                  setState(() {
                    isAgreed = newValue!;
                    isAgreed ? isAgreedNum = 1 : isAgreedNum = 0;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //cancelButton,
                    (isAgreedNum == 1)
                        ? continueButton
                        : ElevatedButton(
                            onPressed: null,
                            child: Text('Agree'.tr),
                          ),
                  ],
                ),
              ),
            ],
          )
        ]);
      }),
      actions: const [
        //cancelButton,
        //continueButton,
      ],
    );
    // show the dialog
    //if (isFirstLoaded)
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return WillPopScope(
                onWillPop: () => Future.value(false), child: alert);
          });
        });
  }

  showAlertPrivacyConsentDialog(BuildContext context) async {
    bool isAgreed = false;
    int isAgreedNum = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLoaded;
    bool? getFromPref = prefs.getBool(keyIsFirstLoaded);
    if (getFromPref != null) {
      isFirstLoaded = getFromPref;
    } else {
      isFirstLoaded = true;
    }
    Widget continueButton = ElevatedButton(
      child: Text('Agree'.tr),
      onPressed: () {
        if (mounted) {
          setState(() {
            policy = 1;
            prefs.setBool(keyIsFirstLoaded, false);
            _sendPolicyStatus();
          });

          Navigator.pop(context);
          _checkPermission();
        }
      },
    );

    Widget alert = AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      titlePadding: EdgeInsets.zero,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, left: 15),
            child: Text(
              'Privacy Policy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Column(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 57 / 100,
            child: const Scrollbar(
          
              child: Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last updated: 10th July 2023',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      Text(
                        'This Data Protection Policy applies to all personal data collected by the Teda GH International, Tdlabs Co, subdomain and Tdlabs MyCSP Mobile Apps (referred to herein as the MyCSP, us, we or our). Teda GH Technology Tdlabs present My Surveillance Programme (MyCSP), MyCSP provide end-to-end solutions services of RTK Antigen Self-Test monitoring result and its status.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Tdlabs Application (hereinafter referred to as App), is an application developed to assist in managing the COVID-19 outbreaks in Malaysia. It allows you (hereinafter referred to as User) to perform a self-Test assessment, monitor their health status and share it with the Tdlabs Application to enable immediate actions in providing treatments if required.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Teda GH International respects the privacy of individuals with regards to their personal data (Personal Data) and is committed to protecting the privacy of our customers and participants (Users). This policy serves to share how we process your personal data in accordance with the Malaysia Personal Data Protection Act 2010 (ACT). To Process means to collect, use, store, transfer, disclose, alter, correct, delete or destroy personal data. In accordance with the Malaysia Personal Data Protection Act 2010 (PDPA) and the laws of Malaysia, this privacy policy describes how your Personal Information is collected and used and informs your choices with respect to your Personal Data. The following discloses our information gathering and dissemination practices.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'This Policy applies to all personal data that you may provide to us and the personal data we hold about you. By interacting with us and submitting with your personal data or by accessing, using or viewing the applicable Tdlabs Apps or any of its services, functions or contents (including transmitting, caching or storing of any such personal data), you shall be deemed to have agreed and consent to each and all the terms, conditions, and notices in this Policy. If you do not agree, please cease use of the relevant website(s) and/or service(s) and DO NOT provide any personal data to us.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Tdlabs may from time to time update this Data Protection Policy to ensure that this Data Protection Policy is consistent with our future developments, industry trends, and/or any changes in legal or regulatory requirements. Subject to your rights at law, you agree to be bound by the prevailing terms of this Data Protection Policy as updated from time to time on our websites, applications, and digital services. Please check back regularly for updated information on the handling of your Personal Data.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'The purpose of this Data Protection Policy is to inform you of how Tdlabs manages Personal Data which is subject to personal data protection principles applicable to government agencies. Our Privacy Policy is designed to give you comprehensive understanding of the steps that we take to protect the personal information that you share with us and please take a moment to read this Data Protection Policy so that you know and understand the purposes for which we collect, use and disclose your Personal Data and by providing your personal data to us, you are agreeing to the provisions of this Privacy Notice and the processing of your personal data as described in this Privacy Notice.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 13),
                      Text(
                        'Defining Personal Data',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'In this Data Protection Policy, "Personal" Data refers to any data, whether true or not, about an individual who can be identified (a) from that data; or (b) from that data and other information to which we have or are likely to have access, including data in our records as may be updated from time to time.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Examples of such Personal Data you may provide to us include (depending on the nature of your interaction with us) your name, NRIC, passport or other identification number, telephone number(s), mailing address, email address and any other information relating to any individuals which you have provided us in any forms you may have submitted to us, or via other forms of interaction with you.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "The app will not record user's Personal Data except with the permission and voluntarily provided by the user. Information collected are used for monitoring purposes in dealing with the COVID-19 pandemic. This information is not shared with other organizations for other purposes save and except specifically stated herein.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 13),
                      Text(
                        'Your Consent and Our Use of Your Personal Data',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "By creating a profile or registering to use our app, you expressly agree to the following permissions to give you a better experience and service:",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "-Image & Files: To allow you to set up your profile picture and download infographic announcements and test results in the app",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "-GPS Location: To identify your location to use our built-in location-based features (E.g. Hotspot tracker, location assessment)",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "-Audio & Video recording: To allow video & audio recording during Self-Test process to get SIMKA verification report by Point of Care",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "-Camera: To allow you to scan QR codes on the cassette provided for the purpose of self-test",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "-Phone: To register and allow you to directly dial the Health centre deal with COVID-19 to comply with the rules and Standard Operating Procedure(SOP) issued under the Prevention and Control of Infectious Diseases Act 1988",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "-Google Fit: We provide the opportunity to sync our Products with Google’s Fit SDK which is an open platform that lets users control their fitness data.Within Google Fits settings you can decide if you want to allow the Products to read personal data listed in Google Fit and import it to the Products, to write personal data collected in our Products in Google Fit or both",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "-Physical Activity Data: With your consent, we may import into the app personal data about your health and activity from third party services such as apple healthkit and google fit. The imported personal data may include: weight, height, calories burnt, heartbeat rate, number of steps/distance traveled and other data about your health, we will handle any such third-party information in accordance with this Privacy Policy.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 13),
                      Text(
                        'Collection of Personal Data',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "We may collect, hold, use and disclose your Personal Data to provide our services to you. In addition, we may also collect, hold, use and disclose your Personal Data for other reasons as provided further in this Privacy Policy. This app collects data with the consent of the user and is done voluntarily through, but not limited to, registration process, adding dependent information, answering health assessments, scan in at the cassette provided along with RTK Antigen Self-Test using a QR code scan and contacting app support via email or technical support form to comply with applicable laws, regulation and/or requirements from government agencies, regulatory bodies, statutory board or other relevant bodies in Malaysia. Your Personal Data that we collect, hold, use and disclose consists of the information described below.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "When User are using the site, we may request you to create an account in order to process your MyCSP programme",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Data are also collected when user register to the service of MyCSP programme on Mobile App with Google Playstore & Apple Store, etc",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Location Data will only only be collected once the permission to access device location services is granted and allowed by the user.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Location data will only be collected once the permission to access device location services is granted and allowed by the user',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Data collected when the user Register or subscribe for our RTK Antigen Self-Test product',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Data collected when the user Register interest for information of (through our online portals or other available channels) about our products and/or services",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "The Personal Data that are usually collected are as follows:",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "a.User Registration - \ni.Name \nii.Current Address \niii.National identity card number / Passport Number\niv.Telephone or Mobile number\nv.Date of birth\nvi.Email address\nvii.Gender",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "b.Scanning QR Code \ni.Validation of Test Kit",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "c.Audio & Video Recording \ni.Capture video for self-test process to get SIMKA verification report",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "d.Activity Recognition \ni.We collect physical activity data obtained through activity recognition,The types of data we collect include:\n-Steps\n-Heart rate\n-Active energy burned\n-Body mass index\n-Body fat percentage\n-Sleep duration in bed",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "These data types are collected to provide personalized insights, track fitness activities and monitor overall health and well-being.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "e.GPS Location (ACCESS_COURSE_LOCATION and ACCESS_FINE_LOCATION)\ni. We use GPS location data to track workouts of the user. This allows us to provide accurate information on distance covered, route taken, and other location-related details.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Please note that we do not collect any personal or sensitive user data without the adequate and prominent disclosure and consent required by Google Play. The permissions listed below are requested to enable specific functionalities within the app, and we ensure that user data accessed through these permissions is handled in compliance with privacy regulations and user consent requirements",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "-Camera(required for capturing video during the self-test process): The app needs access to your device's camera to allow you to capture video during the self-test process. This video is used to generate the SIMKA verification report, ensuring accurate and reliable results",
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "-Image & Files(required for accessing external storage to save the SIMKA verification report): The app requires access to your device's external storage to save the SIMKA verification report securely. This allows you to conveniently retrieve and review the generated report whenever needed",
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "-Images(required for accessing external storage to save the SIMKA verification report): The app needs access to your device's image storage to save the SIMKA verification report. This ensures that the report is accessible and can be easily shared or viewed by you",
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "-GPS Location(required to track workouts, find nearest health facilities, vending machines, and enable location-based services with explicit user permission): The app requests permission to access your device's GPS location. This enables the app to track your workouts accurately, providing detailed information on distance covered, route taken, and other location-related data. With your explicit permission, this also allows the app to find the nearest health-facilities in case of emergencies, locate nearby vending machines, and provide other location-based services that enhance your user experience",
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "-Activity Recognition(required for tracking exercise activity and sleep patterns): The app utilizes activity recognition to track your exercise activity and sleep patterns. By monitoring your physical activity\n\nThe types of data we collect include:\nSteps\nHeart rate\nActive energy burned\nBody mass index\nBody fat percentage\nSleep duration in bed",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 13),
                      Text(
                        "Sensitive Personal Data",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Some of the Personal Data that we collect is sensitive in nature. This includes Personal Data pertaining to your race, national ID information, background information where legally permissible, health data, disability, marital status and biometric data, as applicable. We collect this information only with your consent and/or in strict compliance with applicable laws.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 13),
                      Text(
                        "Geographic Location",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Our website and mobile or web-based applications may offer location-enabled services, such as Google Maps and Bing Maps to provide you the nearest health services including but not limited to Government Hospitals in compliance with to all Movement Control Order (MCO) rules and Standard Operating Procedures (SOP) issued under the Prevention and Control of Infectious Diseases Act 1988 and statistic of Covid-19 cases, in the relevant location as provided in the Site. If you use those mobile or web-based applications, they may receive information about your actual location (such as GPS signals sent by a mobile device) or information that can be used to approximate a location. You are always asked if the geo- location service can be activated and you can also object to this geo-location service within the respective mobile or web-based application.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 13),
                      Text(
                        "User Permission",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "We would ask for the following permissions while using respective features in the app to give you a better experience and service :",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Files, Photos: To allow you to set up your profile picture and download infographic announcements and test result in the app",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Audio & Video recording : To allow video & audio recording during Self-Test process to get SIMKA verification report by Point of Care",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Camera: To allow you to scan QR codes on the cassette provided for the purpose of self-test",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Location : To identify your location to use our built-in location-based features (E.g. Hotspot tracker, location assessment)",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Phone :To register and allow you to directly dial the Health centre deal with COVID- 19 to comply with the rules and Standard Operating Procedures (SOP) issued under the Prevention and Control of Infectious Diseases Act 1988",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 13),
                      Text(
                        "Purposes of Data Collection",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "We may process personal data from you as identified in this Privacy Notice, for one or more of the following purposes : -",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To verify your identity",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To enable you to be provided with products and/or services as well as facilities and/or benefits offered by us and/or related corporations",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To facilitate, assess and/or process your application(s)/request(s) for our and/or our related corporation's products and/or services",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To assess your risk of being infected by Covid-19 based on the information you provided on your health based on the test taken via using our MyCSP program monitoring system",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To detect and/or prevent fraudulent activity by MyCSP program",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To Keep you in contact with you and provide you with any information have requested",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To communicate with you in case your condition requires a follow up from nearest healthcare personnel",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To process any test report or communication that you send us vis MyCSP program with our certified swabber officer for the purpose of identifying the cassette submitted and generating appropriate test report",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Administering the relevant examinations and test",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Notifying you of the test details, report and updates, facilitating your use of the application",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To help us monitor and improve the performance of our network, product and services",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To respond to you about any comment or enquiry you have submitted",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To suggest the nearest medical/screening facility to your location\nTo produce data, reports and statistics",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To maintain records required for security, claims or other legal purposes",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To comply with legal and regulatory requirements",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To notify you about benefits and changes to the features of our products and/or services",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "For any other purposes that is required or permitted by any law, regulations, guidelines and/or relevant regulatory authorities",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 13),
                      Text(
                        "Disclosures of Personal Data",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Tdlabs will take reasonable steps to protect your Personal Data against unauthorised disclosure. Subject to the provisions of any applicable law, your Personal Data may be disclosed by Tdlabs, for the purposes listed above (where applicable), to the following entities or parties, whether they are located overseas or in Malaysia : -",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Teda GH International, Tdlabs Co, subdomain and Tdlabs MyCSP Mobile Apps",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Relevant government ministries, regulators, statutory boards or authorities or law enforcements agencies to comply with any law, rules, guidelines and regulations or schemes imposed by any government authorities",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Your personal information might be shared with enforcement authority for follow-up and resolution of any complaints you submitted via this App",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "The Personal Data collected will not be used for any purpose other than those mentioned above, unless if required in order to comply with any legal obligation.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "No Personal Data collected by this App will be disclosed to any third party or transferred to a place outside of Malaysia for commercial purposes without the consent of the user",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Carrying out security and safety measures and services such as performing network or service enhancement and protecting our platforms from unauthorised access or use",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Carrying out market-related, evaluation or similar research and analysis for our operational strategy and policy planning purposes, including providing data to authorised external parties for any purposes to review, develop and improve the quality of healthcare products and services.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Carrying due diligence in accordance with legal and regulatory obligations or our risk management procedures and policies such as conducting audits to prevent, detect and investigate crime or offences or uncover non-conforming process.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "We will take reasonable steps to make sure the personal data we collect, use or disclose is accurate, complete and up to date. To enable us to ensure the quality and accuracy of personal data, you are obliged to provide relevant and accurate information to us.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "If the Personal Data provided is insufficient or unsatisfactory, then the User's application or request for any of the above purposes may not be accepted, or action taken or use of the services offered by the App may be rejected or affected.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "The Site may contain links to other websites. You should note that we do not have any control over such other websites. Please note that we are not responsible for the privacy policy or practices of such other websites and advise you to read the privacy policy of each website you visit which collects any of your Personal Data.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Any other party whom you authorise us to disclose your personal data to",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 13),
                      Text(
                        "Data Security",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Tdlabs will take reasonable efforts to protect Personal Data in our possession or our control by making reasonable security arrangements to prevent unauthorised access, collection, use, disclosure, copying, modification, disposal or similar risks. However, we cannot completely guarantee the security of any Personal Data we may have collected from or about you, or that for example no harmful code will enter our websites, applications, and digital services (for example viruses, bugs, trojan horses, spyware or adware). You should be aware of the risks associated with using websites, applications, and digital services.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "While we strive to protect your Personal Data, we cannot ensure the security of the information you transmit to us via the Internet, when you browse our websites, or use our applications and/or digital services, and the method of electronic storage. We urge you to take every precaution to protect your Personal Data when you are on the Internet, when you browse our websites, or use our applications and/or digital services. We recommend that you change your passwords often, use a combination of letters and numbers, and ensure that you use a secure browser.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "If applicable, you undertake to keep your username and password secure and confidential and shall not disclose or permit it to be disclosed to any unauthorised person, and to inform us as soon as reasonably practicable if you know or suspect that someone else knows your username and password or believe the confidentiality of your username and password has been lost, stolen or compromised in any way or that actual or possible unauthorised transactions have taken place. We are not liable for any damages resulting from any security breaches, on unauthorised and/or fraudulent use of your username and password.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Security is our top priority, Tdlabs will strive at all times to ensure that your personal data will be protected against unauthorised or accidental access, processing or erasure. We maintain this commitment to data security by implementing appropriate physical, electronic and managerial measures to safeguard the personal data.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "We use the Personal Information you provide in connection with the Services and internal purposes, such as confirming and tracking your registration, or order, analysing tends and statistics, services and offers and providing you with information from and about the website, Mobile App on Google PlayStore & Apple Store, TedaCompany or related companies. If you do not wish to receive e-mailings, please let us know by: calling us at +603-8999 2552 or sending us an email:customer@tdlabs.co and Attention: Customer Service.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 13),
                      Text(
                        "Data Confidentiality",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Personal Data collected by the App will be kept confidential in accordance with this Privacy Policy and any applicable laws which may take effect from time to time.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 13),
                      Text(
                        "Product & Promotional Information",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "When you access certain pages on the website, Mobile App on Google PlayStore & Apple Store, subscribe for a Service, purchase products, or register for competitions or other services, you may be given the opportunity to receive information by post, e-mail, or telephone, about products, promotions or special offers which we feel may be of interest to you. In the event you do not wish to be contacted for such purposes, ensure that you tick the appropriate box as you go through the registration or other process. You may unsubscribe from our contact list at any time by replying to a promotional e-mail with the word unsubscribe in the subject line, bye-mailing us at customer@tdlabs.co or telephoning us on the contact numbers provided.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 13),
                      Text(
                        "Contacting us - Feedback, Withdrawal of Consent, Access & Correction of your Personal Data",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "If you have any questions about this website, concerns on any aspect of this Privacy Statement, or you wish to exercise your rights in respect of your personal data, you may contact us with any enquiries or complaints via :- Customer Service customer@tdlabs.co, or you may contact us directly at 603-8999 2552 your latest written instructions to us will prevail. Would like to withdraw your consent to any use of your Personal Data as set out in this Data Protection Policy; or would like more information on or access and make corrections to your Personal Data records. This website may display content of, and provide links to, our advertising partners, content partners, third party social media and third party video websites. The practices on handling information and cookies by third parties are governed by the privacy statements of such other third party and you are expected to refer to their privacy statements. We may amend this Privacy Notice from time to time and the updated version shall apply and supersede any and all previous versions, including, leaflets or hard copy versions. You are encouraged to check our website and re-visit this Privacy Notice periodically for our most upto-date Privacy Notice (as reflected by the date of the update set out below).",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Retention of Your Data & Deletion",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Where you are a registered user of this MyCSP App, subject to exercising your rights details of this policy, we retain Your Data for as long as you remain as active user of your account. Where there has not been any activity of your account for three years we will contact you to check you still wish to retain your account with us.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Where you decide to cancel or delete of your account or we do not hear further from you, your account will be de-activated and all Your Data will be delete. Where you have subscribe to receive any marketing correnspondence from us, we will keep your data for marketing purposes whilst your account remain active and for the period of time refer above. This is subject to exercing your rights to unsubscribe from receiving such correspondence at any time",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 13),
                      Text(
                        "Governing Law",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "This Data Protection Policy, your browsing of our websites, and use of our applications and/or digital services shall be governed in all respects by the laws of Malaysia.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To help us improve our privacy policy and practice, please give us your feedback.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "You may email us customer@tdlabs.co or write to us at the Teda Company, of [No.11-2, Jalan Jalil Jaya 3, Jalil Link, 57000, Bukit Jalil, Kuala Lumpur.].",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Attention: Customer Service.[Data Protection Privacy Policy & Security Statement updated [1st November, 2021]]",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              const Divider(
                height: 5,
                thickness: 2,
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text(
                  'I hereby agree and confirm to the terms and conditions stipulated herein',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                value: isAgreed,
                activeColor: CupertinoTheme.of(context).primaryColor,
                onChanged: (bool? newValue) {
                  setState(() {
                    isAgreed = newValue!;
                    isAgreed ? isAgreedNum = 1 : isAgreedNum = 0;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //cancelButton,
                    (isAgreedNum == 1)
                        ? continueButton
                        : ElevatedButton(
                            child: Text('Agree'.tr),
                            onPressed: null,
                          ),
                  ],
                ),
              ),
            ],
          )
        ]);
      }),
      actions: const [
        //cancelButton,
        //continueButton,
      ],
    );
    // show the dialog
    //if (isFirstLoaded)
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return WillPopScope(
                onWillPop: () => Future.value(false), child: alert);
          });
        });
  }
}
