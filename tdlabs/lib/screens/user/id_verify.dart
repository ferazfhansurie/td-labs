import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tdlabs/widgets/form/pin_input.dart';
import '../../utils/web_service.dart';
import '../../utils/toast.dart';
import '../../utils/progress_dialog.dart';
import 'package:get/get.dart';
// ignore: must_be_immutable
class IDVerifyScreen extends StatefulWidget {
  String? idVerify;
  int? usernameType;
  String? phoneNo;
  String? email;

  IDVerifyScreen(
      {Key? key, this.idVerify, this.usernameType, this.phoneNo, this.email}): super(key: key);
  @override
  _IDVerifyScreenState createState() => _IDVerifyScreenState();
}

class _IDVerifyScreenState extends State<IDVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  Timer? timer;
  int startTimer = 10;
  bool canResend = false;
  bool isShow = true;
  bool showResendSMS = true;
  int startTimeEmail = 10;
  bool canVerifyEmail = true;
  bool isShowEmail = false;
  @override
  void initState() {
    // implement initState
    super.initState();
    startTimerCountdown(true);
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
    return Scaffold(
      body: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            (widget.usernameType == 0)
                ? 'Verify Phone Number'.tr
                : 'Verify Email'.tr,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
              fontSize: 20,
            ),
          ),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 44,
              bottom: MediaQuery.of(context).padding.bottom),
          color: CupertinoColors.white,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Form(key: _formKey, child: verifyForm()),
          ),
        ),
      ),
    );
  }

  Widget verifyForm() {
    return Column(
      children: [
        // Please verify your PIN.
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          color: CupertinoColors.white,
          child: Center(
            child: Column(
              children: [
                Text('Please key in the 6 digit PIN sent to your'.tr),
                Text((widget.usernameType == 0)
                    ? 'registered mobile phone no.'.tr
                    : 'registered email'.tr),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          color: CupertinoColors.white,
          child: PinInput(
              controller: _pinController,
              onCompleted: (value) {
                FocusScope.of(context).requestFocus(FocusNode());
                if (_formKey.currentState!.validate()) {
                  submitChange(_formKey.currentContext!);
                }
              }),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: CupertinoColors.white,
          child: Center(
            child: Column(
              children: [
                (showResendSMS)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't get your PIN? ".tr,
                          ),
                          (canResend)
                              ? GestureDetector(
                                  onTap: () {
                                    resubmitChange(context);
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
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Lottie.network(
              ((widget.usernameType == 0)
                  ? 'https://assets3.lottiefiles.com/packages/lf20_iZXXuz.json'
                  : 'https://assets2.lottiefiles.com/packages/lf20_ebqz3ltq.json'),
              frameRate: FrameRate(60)),
        )
      ],
    );
  }

  Future<void> resubmitChange(BuildContext context) async {
    final webService = WebService(context);
    String endpointPhone = 'identity/users/change-phone';
    String endpointEmail = 'identity/users/change-email';
    List<String> errors = [];
    webService.setMethod('POST').setEndpoint((widget.usernameType == 0) ? endpointPhone : endpointEmail);
    Map<String, String> data = {};
    if (widget.usernameType == 0) {
      data.addAll({'phone_no': widget.phoneNo!});
      data.addAll({'phone_no_retype': widget.phoneNo!});
    } else {
      data.addAll({'email': widget.email!});
      data.addAll({'email_retype': widget.email!});
    }

    final GlobalKey progressDialogKey = GlobalKey<State>();
    ProgressDialog.show(context, progressDialogKey);
    var response = await webService.setData(data).send();
    ProgressDialog.hide(progressDialogKey);

    if (response == null) return;

    if (response.status) {
      Toast.show(context, 'success', 'Resend Successfully');
      startTimerCountdown(true);
      setState(() {
        startTimer = 10;
        canResend = false;
        isShow = true;
      });
    } else if (response.error.isNotEmpty) {
      errors.add(response.error.values.toList()[0]);
    } else {
      errors.add('Server connection timeout.');
    }
    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
  }

  Future<void> submitChange(BuildContext context) async {
    final webService = WebService(context);
    String endpoint = 'identity/users/verify';
    List<String> errors = [];
    webService.setMethod('POST').setEndpoint(endpoint);
    Map<String, String> data = {};
    if (widget.usernameType == 0) {
      data.addAll({'phone_no': widget.phoneNo!});
      data.addAll({'username_type': widget.usernameType.toString()});
      data.addAll({'pin': _pinController.text});
    } else {
      data.addAll({'email': widget.email!});
      data.addAll({'username_type': widget.usernameType.toString()});
      data.addAll({'pin': _pinController.text});
    }
    final GlobalKey progressDialogKey = GlobalKey<State>();
    ProgressDialog.show(context, progressDialogKey);
    var response = await webService.setData(data).send();
    ProgressDialog.hide(progressDialogKey);
    if (response == null) return;
    if (response.status) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Toast.show(context, 'success', 'Change ID success');
    } else if (response.error.isNotEmpty) {
      errors.add(response.error.values.toList()[0]);
    } else {
      errors.add('Server connection timeout.');
    }
    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
  }
}
