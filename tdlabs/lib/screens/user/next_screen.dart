// ignore_for_file: unused_field, unnecessary_null_comparison

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tdlabs/models/util/country_state.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:tdlabs/screens/user/register_verify.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/form/text_input.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
// ignore: must_be_immutable
class NextForm extends StatefulWidget {
  String email;
  Map<String, dynamic>? availableAddress;
  NextForm({Key? key, this.availableAddress, required this.email})
      : super(key: key);
  @override
  _NextFormState createState() => _NextFormState();
}

class _NextFormState extends State<NextForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNoController = TextEditingController();
  final _referrerReferenceController = TextEditingController();
  int? _userId;
  final bool _canSubmit = false;
  final bool _isLoadingCS = false;
  final List<CountryState> _csList = [];
  Map<String, String> stateList = {
    'all': '',
    'my-01': 'Johor',
    'my-02': 'Kedah',
    'my-03': 'Kelantan',
    'my-04': 'Melaka',
    'my-05': 'Negeri Sembilan',
    'my-06': 'Pahang',
    'my-07': 'Pulau Pinang',
    'my-08': 'Perak',
    'my-09': 'Perlis',
    'my-10': 'Selangor',
    'my-11': 'Terengganu',
    'my-12': 'Sabah',
    'my-13': 'Sarawak',
    'my-14': 'Kuala Lumpur',
    'my-15': 'Labuan',
    'my-16': 'Putrajaya',
  };
  int state = 0;
  String? stateName;
  int? stateIndex;
  int country = 0;
  final List<String> _listCountry = ['Malaysia'];
  final List<String> _listCountryCode = ['my'];
  String? countryName;
  String? countryCode;
  final int _pickerIndex = 0;
  final String _stateCode = '';
  Map<String, dynamic> address = {};
  String? street;
  bool isAvailable = false;
  bool terms = false;
  int termsNum = 0;
  @override
  void initState() {
    _fetchUser();
    super.initState();
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
                              signOutGoogle(context: context);
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
                            "Almost there!".tr,
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
 static Future<void> signOutGoogle({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await auth.FirebaseAuth.instance.signOut();
    } catch (e) {
      Toast.show(context, "danger", e.toString());
    }
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
                    label: 'Phone No.'.tr,
                    controller: _phoneNoController,
                    type: 'phoneNo',
                    maxLength: 11),
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
            child: Row(
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
                          _launchURL('https://tdlabs.co/privacy-policy.html');
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
                child: Text('Continue'.tr,
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

  Future<void> _fetchUser() async {
    User? user = await User.fetchOne(context); // get current user
    if (user != null) {
      setState(() {
        _userId = user.id!;
      });
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    final webService = WebService(context);
    User user = User();
    user.email = widget.email;
    user.referrerReference = _referrerReferenceController.text;
    user.phoneNo = _phoneNoController.text;
    if (_phoneNoController.text.length >= 10) {
      webService.setMethod('PUT').setEndpoint('identity/users/update-phone');
      Map<String, String> data = {};
      data.addAll({'phone_no': _phoneNoController.text});
      data.addAll({'referrer_reference': _referrerReferenceController.text});
      if (termsNum == 1) {
        final GlobalKey progressDialogKey = GlobalKey<State>();
        ProgressDialog.show(context, progressDialogKey);
        var response = await webService.setData(data).send();
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
                google:true
              );
            }));
          } else if (response.error.isNotEmpty) {
            Toast.show(context, 'danger', response.error.values.toList()[0]);
          }
        } else {
          Toast.show(context, 'danger', 'Server connection timeout.');
        }
      } else {
        Toast.show(context, 'danger', 'Please accept terms & conditions');
      }
    } else {
      Toast.show(context, 'danger', 'Phone number not valid');
    }
  }
}
