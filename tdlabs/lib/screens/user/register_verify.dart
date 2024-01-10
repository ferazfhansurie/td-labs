// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../../models/user/user.dart';
import '../../utils/progress_dialog.dart';
import '../../utils/toast.dart';
import '../../utils/web_service.dart';
import 'package:lottie/lottie.dart';
import 'package:email_launcher/email_launcher.dart';

class RegisterVerifyScreen extends StatefulWidget {
  User? user;
  bool? google;
  RegisterVerifyScreen({Key? key, this.user, this.google}) : super(key: key);
  @override
  _RegisterVerifyScreenState createState() => _RegisterVerifyScreenState();
}

class _RegisterVerifyScreenState extends State<RegisterVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  User? _user;

  Timer? timer;
  int startTimer = 10;
  bool canResend = false;
  bool isShow = true;
  bool showResendSMS = true;
  int startTimeEmail = 10;
  bool canVerifyEmail = true;
  bool isShowEmail = false;
  int usernameType = 0;
  String phone = "";

  Email email = Email(
      to: ['admin@tdlabs.co'],
      cc: [''],
      bcc: [''],
      subject: 'Help regarding registering',
      body: 'Hello, ');

  @override
  void initState() {
    super.initState();
    startTimerCountdown(true);
    phone = widget.user!.phoneNo!;
  }

  @override
  void dispose() {
    _pinController.dispose();
    timer!.cancel();
    super.dispose();
  }

  void startTimerCountdown(bool isSMS) {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (timer) {
      if (isSMS) {
        if (startTimer == 0) {
          setState(() {
            timer.cancel();
            canResend = true;
            isShow = false;
          });
        } else {
          setState(() {
            startTimer--;
          });
        }
      } else {
        showResendSMS = false;
        if (startTimeEmail == 0) {
          setState(() {
            timer.cancel();
            canVerifyEmail = true;
            isShowEmail = false;
          });
        } else {
          setState(() {
            startTimeEmail--;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _user = widget.user;
    return CupertinoPageScaffold(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/Background-01.png"),
              fit: BoxFit.fill),
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: _verifyForm(),
        ),
      ),
    );
  }

  _verifyForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40,),
                  Text(
                    "Verify PIN".tr,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _launchEmail,
                    child: Text(
                      'Report Us'.tr,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: CupertinoColors.white,
            child: Center(
              child: Column(
                children: [
                  Text('Please key in the 6 digit PIN sent to your'.tr),
                  (usernameType == 0)
                      ? Text('registered mobile phone no.'.tr)
                      : Text('email adress.'.tr),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical:30,horizontal: 75),
            color: CupertinoColors.white,
            child: CupertinoTextField(
              padding: const EdgeInsets.only(right: 18),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
              ),
        enableSuggestions: false,
        autocorrect: false,
        controller: _pinController,
        maxLength: 6,
        keyboardType: TextInputType.number,
        prefix: const Padding(
          padding: EdgeInsets.only(top:8,left:8,bottom: 8),
          child: Icon(CupertinoIcons.lock_circle),
        ),
      ),
          ),
          
          Container(
            color: Colors.white,
        width: double.infinity,
        height: 36,
        child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 75),
          child: CupertinoButton(
            color: CupertinoTheme.of(context).primaryColor,
            disabledColor: CupertinoColors.inactiveGray,
            padding: EdgeInsets.zero,
            onPressed:() {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (_formKey.currentState!.validate()) {
                        _submitForm(_formKey.currentContext!);
                    }
                  },
            child: Text('Submit'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w300)),
          ),
        ),
      ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(25),
            color: CupertinoColors.white,
            child: Center(
              child: Column(
                children: [
                  (showResendSMS)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didnt get your sms?".tr,
                            ),
                            (canResend)
                                ? GestureDetector(
                                    onTap: () {
                                     
                                      _resendForm(context);
                                    },
                                    child: Text(
                                      'Resend'.tr,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        decoration: TextDecoration.underline,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Resend'.tr,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black26),
                                  ),
                          ],
                        )
                      : Container(),
                  (isShow && showResendSMS)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Resend is available in '.tr),
                            Text(startTimer.toString()),
                          ],
                        )
                      : Container(),
                  const SizedBox(height: 30),
                  (usernameType == 0)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (showResendSMS) ? const Text('Or ') : Container(),
                            (canVerifyEmail)
                                ? GestureDetector(
                                    onTap: () {
                                      verifyByEmail();
                                    },
                                    child: Text(
                                      'Verify by email'.tr,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        decoration: TextDecoration.underline,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                    ),
                                  )
                                : Text('Verify by email'.tr,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black26)),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (showResendSMS) ? const Text('Or ') : Container(),
                            (canVerifyEmail)
                                ? GestureDetector(
                                    onTap: () {
                                      _resendForm(context);
                                    },
                                    child: Text(
                                      'Verify by phone'.tr,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        decoration: TextDecoration.underline,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                    ),
                                  )
                                : Text('Verify by phone'.tr,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black26)),
                          ],
                        ),
                  (isShowEmail)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Verify by email is available in '.tr),
                            Text(startTimeEmail.toString()),
                          ],
                        )
                      : Container(),
                  const SizedBox(
                    height: 5,
                  ),
                  (usernameType == 0)
                      ? Text(
                          'By verifying using email, you can only login using email'
                              .tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              color: Colors.black),
                        )
                      : Text(
                          'By verifying using phone no, you can only login using phone no'
                              .tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              color: Colors.black),
                        ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Lottie.network(
                ((usernameType == 0)
                    ? 'https://assets3.lottiefiles.com/packages/lf20_iZXXuz.json'
                    : 'https://assets2.lottiefiles.com/packages/lf20_ebqz3ltq.json'),
                frameRate: FrameRate(60)),
          )
        ],
      ),
    );
  }

  Future<void> verifyByEmail() async {
    if (_user!.email != '') {
      WebService webService = WebService(context);
      webService
          .setAuthType('Basic')
          .setMethod('POST')
          .setEndpoint('identity/signup/update-email');
      Map<String, String> data = {};
      data['email'] = _user!.email!;
      data['id'] = _user!.id.toString();
      setState(() {
        usernameType = 1;
      });

      var response = await webService.setData(data).send();

      if (response != null) {
        setState(() {
          startTimeEmail = 10;
          canVerifyEmail = false;
          isShowEmail = true;
        });
        if (response.status) {
          startTimerCountdown(false);
          Toast.show(context, 'success', 'Email send successfully!');
        }
      }
    } else {
      Navigator.pop(context);
      Toast.show(context, 'danger',
          'Please input your email in registration form to verify using email');
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    String pin = _pinController.text;
    final GlobalKey progressDialogKey = GlobalKey<State>();
    List<String> errors = [];
    if (pin.isEmpty) errors.add('PIN field cannot be blank.');
    if (errors.isEmpty) {
      var response = await User.verify(context, phone, pin, _user!.email!, usernameType);
      if (response != null) {
        if (response.status && widget.google == false) {
          final webService = WebService(context);
          ProgressDialog.show(context, progressDialogKey);
          var result = (usernameType == 0)
              ? await webService.authenticate(_user!.phoneNo!, _user!.password!)
              : await webService.authenticate(_user!.email!, _user!.password!);
          ProgressDialog.hide(progressDialogKey);
            if ((result != null) && result) {
            Toast.show(context, 'default', 'Success!');
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacementNamed(context, '/home');
          }
        }else if(response.status && widget.google == true){
           Toast.show(context, 'default', 'Success!');
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacementNamed(context, '/home');
        } else if (response.error.isNotEmpty) {
          errors.add(response.error.values.toList()[0]);
        }
      } else {
        errors.add('Server connection timeout.');
      }
    }

    if (errors.isNotEmpty) {
      setState(() {
        _pinController.clear();
      });

      Toast.show(context, 'danger', errors[0]);
    }
  }

  Future<void> _resendForm(BuildContext context) async {
    User user = User();
    user.name = _user!.name;
    user.phoneNo = _user!.phoneNo;
    user.email = _user!.email;
    user.password = _user!.password;
    user.referrerReference = _user!.referrerReference;

    List<String> errors = [];
    final GlobalKey progressDialogKey = GlobalKey<State>();
    ProgressDialog.show(context, progressDialogKey);
    var response = await User.create(context, user);
    ProgressDialog.hide(progressDialogKey);

    if (response != null) {
      if (response.status) {
        setState(() {
          usernameType = 0;
        });
        startTimerCountdown(true);
        setState(() {
          startTimer = 10;
          canResend = false;
          isShow = true;
        });
      } else if (response.error.isNotEmpty) {
        errors.add(response.error.values.toList()[0]);
      }
    } else {
      errors.add('Server connection timeout.');
    }

    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
  }

  void _launchEmail() async {
    await EmailLauncher.launch(email);
  }
}
