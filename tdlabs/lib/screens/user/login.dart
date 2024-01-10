import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdlabs/screens/info/helpdesk.dart';
import 'package:tdlabs/screens/user/password_request.dart';
import 'package:tdlabs/screens/user/register_form.dart';
import '../../adapters/util/google_link.dart';
import '../../config/main.dart';
import '../../services/notification.dart';
import '../../utils/progress_dialog.dart';
import '../../utils/toast.dart';
import '../../utils/web_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  int language = 0;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo? androidInfo;
  bool info = false;
  final locales = [
    {
      'name': 'English',
      'locale': const Locale('en', 'US'),
    },
    {'name': 'Bahasa Malaysia', 'locale': const Locale('ms', 'MY')},
    {'name': '简体中文'.tr, 'locale': const Locale('zh', 'ZH')},
  ];
  int messageCount = 0;

  @override
  void initState() {
    super.initState();
  
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
  
    return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: CupertinoPageScaffold(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(top: 25),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/Background-01.png"),
                    fit: BoxFit.fill),
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Visibility(
                          visible: (MainConfig.modeLive == false),
                          child: Container(
                            width: double.infinity,
                            color: Colors.red,
                            child: const Center(
                                child: Text(
                              "Dev",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300),
                            )),
                          )),
                      _logoImage(),
                      _userInput(),
                      const SizedBox(
                        height: 15,
                      ),
                      _passwordInput(),
                      _forgotPassword(),
                      _logInButton(),
                      _registerButton(),
                      const SizedBox(
                        height: 25,
                      ),
                      if (info == true)
                        (androidInfo!.manufacturer != "HUAWEI")
                            ? GoogleLink(
                                title: "Sign in with Google",
                                method: 0,
                              )
                            : Container(),
                      /*  const SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3),
                        child: GestureDetector(
                          onTap: () async {
                            _googleSignIn(context);
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 0, 0, 0)
                                      .withOpacity(0.6),
                                  spreadRadius: 1,
                                  blurRadius: 1, // changes position of shadow
                                ),
                              ],
                            ),
                            child: Image.network(
                                'http://pngimg.com/uploads/google/google_PNG19635.png',
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Text('Login with google',
                          style: TextStyle(
                              color: Color.fromARGB(255, 104, 104, 104),
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),*/
                      GestureDetector(
                        onTap: () async {
                          showLocaleDialog(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: Text('Language'.tr,
                              style: TextStyle(
                                color: CupertinoTheme.of(context).primaryColor,
                              )),
                        ),
                      ),
                      _helpButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  showLocaleDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Choose your language'.tr),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) => GestureDetector(
                          onTap: () async {
                            setState(() {
                              language = index;
                            });
                            updateLocale(
                                locales[index]['locale'] as Locale, context);
                            Navigator.pop(context);
                          },
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(locales[index]['name'].toString())),
                        ),
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: 3),
              ),
            ));
  }

  void updateLocale(Locale? locale, BuildContext context) {
    Get.updateLocale(locale!);
  }

  Widget _logoImage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
      child: Image.asset(
        'assets/images/TD-LABS-01.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _userInput() {
    return Container(
      height: 46,
      width: 300,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: CupertinoTextField(
        key: const Key("username"),
        enableSuggestions: false,
        autocorrect: false,
        controller: _usernameController,
        placeholder: 'Email/Contact No'.tr,
        prefix: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(CupertinoIcons.person),
        ),
      ),
    );
  }

  Widget _passwordInput() {
    return Container(
      height: 46,
      width: 300,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: CupertinoTextField(
        key: const Key("password"),
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
        controller: _passwordController,
        placeholder: 'Password'.tr,
        prefix: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(CupertinoIcons.lock),
        ),
      ),
    );
  }

  Widget _forgotPassword() {
    return SizedBox(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) {
            return const PasswordRequestScreen();
          }));
        },
        child: Text('Forgot your password?'.tr,
            style: const TextStyle(
                fontFamily: 'Montserrat',
                color: CupertinoColors.white,
                fontWeight: FontWeight.w300)),
      ),
    );
  }

  Widget _logInButton() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 52, 169, 176),
            Color.fromARGB(255, 49, 42, 130),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      width: 160,
      height: 40,
      child: CupertinoButton(
        key: const Key('login_button'),
        disabledColor: CupertinoColors.inactiveGray,
        padding: EdgeInsets.zero,
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          if (_formKey.currentState!.validate()) {
            _submitForm(_formKey.currentContext!);
          }
        },
        child: Text('Log in'.tr,
            style: const TextStyle(
                fontFamily: 'Montserrat',
                color: CupertinoColors.white,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _registerButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: SizedBox(
        width: 150,
        height: 40,
        child: CupertinoButton(
          borderRadius: BorderRadius.circular(25),
          color: CupertinoColors.lightBackgroundGray,
          disabledColor: CupertinoColors.inactiveGray,
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) {
                      return RegisterFormScreen();
                    },
                    settings: const RouteSettings(name: '/register-form')));
          },
          child: Text('Register'.tr,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  color: Color.fromARGB(255, 104, 104, 104))),
        ),
      ),
    );
  }

  Widget _helpButton() {
    return SizedBox(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return const HelpdeskScreen();
          }));
        },
        child: Text('Need help?'.tr,
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: CupertinoTheme.of(context).primaryColor,
                fontWeight: FontWeight.w300)),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    final webService = WebService(context);
    String username = _usernameController.text;
    String password = _passwordController.text;
    List<String> errors = [];
    if (username.isEmpty) errors.add('Phone No. field cannot be blank.');
    if (password.isEmpty) errors.add('Password field cannot be blank.');
    if (errors.isEmpty) {
      String? messagingToken =
          await NotificationService().getFirebaseMessagingToken();
      final GlobalKey progressDialogKey = GlobalKey<State>();
      ProgressDialog.show(context, progressDialogKey);
      var result = await webService.authenticate(username, password,
          messagingToken: messagingToken);
      ProgressDialog.hide(progressDialogKey);
      if (result != null) {
        if (result) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          errors.add('Incorrect username or password.');
        }
      } else {
        errors.add('Server connection timeout.');
      }
    }

    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
  }
}
