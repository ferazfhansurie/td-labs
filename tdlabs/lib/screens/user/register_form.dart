// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/screens/user/register_verify.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/widgets/form/text_input.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/user/user.dart';

// ignore: must_be_immutable
class RegisterFormScreen extends StatefulWidget {
  String? inviteCode;
  RegisterFormScreen({Key? key, this.inviteCode}) : super(key: key);
  @override
  _RegisterFormScreenState createState() => _RegisterFormScreenState();
}

class _RegisterFormScreenState extends State<RegisterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referrerReferenceController = TextEditingController();

  bool terms = false;
   bool terms2 = false;
  int termsNum = 0;
 int terms2Num = 0;
  @override
  void initState() {
    super.initState();
    _populateData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNoController.dispose();
    _passwordController.dispose();
    _referrerReferenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/Background-01.png"),
                fit: BoxFit.fill),
          ),
          child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
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
                          Text(
                            "User Registration".tr,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          const Spacer()
                        ],
                      ),
                    ),
                  ),
                  _registerForm(),
                ],
              )),
        ),
      ),
    );
  }

  _registerForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                TextInput(
                    prefixWidth: 85,
                    label: 'Name'.tr,
                    controller: _nameController,
                    maxLength: 255),
                TextInput(
                    prefixWidth: 85,
                    label: 'Email'.tr,
                    placeHolder: 'Optional'.tr,
                    controller: _emailController,
                    type: 'email',
                    maxLength: 255),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                const Divider(color: CupertinoColors.systemGrey5, height: 1),
                TextInput(
                    prefixWidth: 85,
                    label: 'Phone No.'.tr,
                    controller: _phoneNoController,
                    type: 'phoneNo',
                    maxLength: 20),
                TextInput(
                    prefixWidth: 85,
                    label: 'Password'.tr,
                    controller: _passwordController,
                    type: 'password',
                    maxLength: 20),
                TextInput(
                    prefixWidth: 150,
                    label: 'Confirm Password'.tr,
                    controller: _confirmPasswordController,
                    placeHolder: 'Please confirm your password'.tr,
                    type: 'password',
                    maxLength: 20),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                const Divider(color: CupertinoColors.systemGrey5, height: 1),
                TextInput(
                    prefixWidth: 85,
                    label: 'Referrer ID'.tr,
                    placeHolder: 'Optional'.tr,
                    controller: _referrerReferenceController,
                    maxLength: 255),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: terms,
                      activeColor: CupertinoTheme.of(context).primaryColor,
                      onChanged: (bool? newValue) {
                        setState(() {
                          terms = newValue!;
                          terms ? termsNum = 1 : termsNum = 0;
                        });
                      },
                    ),
                    Flexible(
                      child: Row(
                        children: [
                          Text('I agree to the '.tr),
                          GestureDetector(
                            onTap: () {
                              showAlertPermissionConsentDialog(context);
                            },
                            child: Text(
                              'Terms & Conditions.'.tr,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w300,
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: terms2,
                      activeColor: CupertinoTheme.of(context).primaryColor,
                      onChanged: (bool? newValue) {
                        setState(() {
                          terms2 = newValue!;
                          terms2 ? terms2Num = 1 : terms2Num = 0;
                        });
                      },
                    ),
                    Flexible(
                      child: Row(
                        children: [
                          Text('I agree to the '.tr),
                          GestureDetector(
                            onTap: () {
                              _launchURL('https://tdlabs.co/web/privacy.html');
                            },
                            child: Text(
                              'Privacy Policy.'.tr,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w300,
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: CupertinoColors.white,
              border: Border(
                bottom: BorderSide(color: CupertinoColors.systemGrey5),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 36,
              child: CupertinoButton(
                color: CupertinoTheme.of(context).primaryColor,
                disabledColor: CupertinoColors.inactiveGray,
                padding: EdgeInsets.zero,
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (_formKey.currentState!.validate()) {
                    _submitForm(_formKey.currentContext!);
                  }
                },
                child: Text('Sign Up'.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w300)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void _populateData() {
    if (widget.inviteCode != null) {
      setState(() {
        _referrerReferenceController.text = widget.inviteCode!;
      });
    }
  }

  bool checkConfirmPassword() {
    if (_passwordController.text == _confirmPasswordController.text) {
      return true;
    } else {
      Toast.show(context, 'danger', 'Password not match');
      return false;
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (checkConfirmPassword()) {
      User user = User();
      user.name = _nameController.text;
      user.phoneNo = _phoneNoController.text;
      user.email = _emailController.text;
      user.password = _passwordController.text;
      user.referrerReference = _referrerReferenceController.text;

      List<String> errors = User.validate(user, scenario: 'create');
      if (errors.isEmpty) {
        if (termsNum == 1) {
          if(terms2Num == 1){
            final GlobalKey progressDialogKey = GlobalKey<State>();
          ProgressDialog.show(context, progressDialogKey);
          var response = await User.create(context, user);
          ProgressDialog.hide(progressDialogKey);
          if (response != null) {
            if (response.status) {
              var responseArray =
                  jsonDecode(response.body!).cast<String, dynamic>();
              user.id = responseArray['id'];
              Navigator.of(context)
                  .pushReplacement(CupertinoPageRoute(builder: (context) {
                return RegisterVerifyScreen(
                  user: user,
                  google: false,
                );
              }));
            } else if (response.error.isNotEmpty) {
              errors.add(response.error.values.toList()[0]);
            }
          } else {
            errors.add('Server connection timeout.');
          }
          }else{
            Toast.show(context, 'danger', 'Please accept privacy policy');
          }
          
        } else {
          Toast.show(context, 'danger', 'Please accept terms & conditions');
        }
      }

      if (errors.isNotEmpty) {
        Toast.show(context, 'danger', errors[0]);
      }
    }
  }

  showAlertPermissionConsentDialog(BuildContext context) async {
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
                                    'Location',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "We request access to your device's location to enhance your experience and provide you with location-based features such as hotspot tracking, location assessment, and locating nearby health facilities",
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
                                    'Files & Photos',
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
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: const Text("Back", style:TextStyle(fontWeight: FontWeight.bold)),
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
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return WillPopScope(
                onWillPop: () => Future.value(true), child: alert);
          });
        });
  }
}
