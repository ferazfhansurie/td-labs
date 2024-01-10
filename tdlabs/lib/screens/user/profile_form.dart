// ignore_for_file: prefer_final_fields, unnecessary_null_comparison

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/screens/user/address_form.dart';
import 'package:tdlabs/screens/user/identification_verify.dart';
import 'package:tdlabs/screens/user/profile_password.dart';
import 'package:tdlabs/utils/web_service.dart';
import '../../models/health/biodata.dart';
import '../../models/user/user.dart';
import '../../utils/progress_dialog.dart';
import '../../utils/toast.dart';
import '../../widgets/form/text_input.dart';
import '../../widgets/form/date_input_birthday.dart';
import '../../models/util/id_verify.dart';
import 'package:get/get.dart';
import 'bio_form.dart';
import 'id_change.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({Key? key}) : super(key: key);
  @override
  _ProfileFormScreenState createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _idNumber = TextEditingController();
  final _phoneNoController = TextEditingController();
  String email = "";
  String phoneNo = "";
  bool _canSubmit = false;
  int? _userId;
  int gender = 0;
  List<String> _listGender = ['Male'.tr, 'Female'.tr];
  String? genderName;
  int nationality = 0;
  List<String> _listNationality = ['Malaysian', 'Non-Malaysian'];
  String? nationalityName;
  String? cityName;
  String? stateName;
  List<Map<String, dynamic>> address = [];
  int verificationStatus = 0;
  String imageName = '';
  int? usernameType;
  bool isPhone = true;
  bool isGoogle = false;


  //mh
  List<Map<String, dynamic>> bioHeight = [];
  String bioHeightName='';

  @override
  void initState() {
    super.initState();
    if (nationalityName != null) {
      nationalityName = _listNationality[nationality];
    }
    fetchStatus(context);
    fetchBio(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _idNumber.dispose();
    _phoneNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) _populateForm();
    return CupertinoPageScaffold(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/Background-01.png"),
              fit: BoxFit.fill),
        ),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                          "Update Profile".tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w300),
                        ),
                        const Spacer()
                      ],
                    ),
                  ),
                ),
                _idInfo(),
                _userForm(),
                _changePassword(),
                _submitButton(),
                _deleteButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _idInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Tdlabs ID'.tr,
            style: const TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.w300),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ((usernameType == 0) ? phoneNo : email),
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 16),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(CupertinoPageRoute(builder: (context) {
                    return IDChangeScreen(
                      phoneNo: phoneNo,
                      email: email,
                      usernameType: usernameType,
                    );
                  }));
                },
                child: Text(
                  'Change'.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _userForm() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          TextInput(
            label: 'Name'.tr,
            prefixWidth: 130,
            controller: _nameController,
            maxLength: 255,
            required: true,
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _showPickerGender();
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: CupertinoColors.white,
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.systemGrey5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width:55,
                        child: Text(
                          'Gender'.tr,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (genderName == ''),
                        replacement: Container(
                          width: 17,
                        ),
                        child: Row(
                          children: const [
                            SizedBox(width: 2),
                            Icon(
                              CupertinoIcons.exclamationmark_circle_fill,
                              size: 6,
                              color: CupertinoColors.systemRed,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 62),
                      child: Text((genderName != null) ? genderName! : '',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                    child: Icon(CupertinoIcons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              DateInputBirthday(
                label: 'Birthday'.tr,
                controller: _dobController,
                prefixWidth: 130,
                required: true,
              ),
            ],
          ),
          TextInput(
            label: 'Email'.tr,
            prefixWidth: 130,
            controller: _emailController,
            placeHolder: 'Optional',
            type: 'email',
            maxLength: 255,
            required: false,
            enabled: (usernameType == 1 || isGoogle == true) ? false : true,
          ),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextInput(
                  label: 'Phone No.'.tr,
                  controller: _phoneNoController,
                  prefixWidth: 130,
                  maxLength: 255,
                  type: 'phoneNo',
                  enabled: (usernameType == 0) ? false : true,
                  required: true,
                ),
              ),
            ],
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  BioForm()),
              );
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: CupertinoColors.white,
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.systemGrey5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width:120,
                        child: Text(
                          'Bio Data'.tr,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (bioHeightName == ''),
                        replacement: Container(
                          width: 10,
                        ),
                        child: Row(
                          children: const [
                            SizedBox(width: 2),
                            Icon(
                              CupertinoIcons.exclamationmark_circle_fill,
                              size: 6,
                              color: CupertinoColors.systemRed,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text((bioHeightName.toString() != null) ? bioHeightName.toString() : '',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                    child: Icon(CupertinoIcons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _fetchAddress();
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: CupertinoColors.white,
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.systemGrey5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width:120,
                        child: Text(
                          'Current Address'.tr,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (cityName == ''),
                        replacement: Container(
                          width: 10,
                        ),
                        child: Row(
                          children: const [
                            SizedBox(width: 2),
                            Icon(
                              CupertinoIcons.exclamationmark_circle_fill,
                              size: 6,
                              color: CupertinoColors.systemRed,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text((cityName != null) ? cityName! : '',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                    child: Icon(CupertinoIcons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _showPickerNationality();
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: CupertinoColors.white,
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.systemGrey5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                         width:90,
                        child: Text(
                          'Nationality'.tr,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (nationalityName == ''),
                        replacement: Container(
                          width: 17,
                        ),
                        child: Row(
                          children: const [
                            SizedBox(width: 2),
                            Icon(
                              CupertinoIcons.exclamationmark_circle_fill,
                              size: 6,
                              color: CupertinoColors.systemRed,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text(
                          (nationalityName != null) ? nationalityName! : '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                    child: Icon(CupertinoIcons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 50,
            decoration: const BoxDecoration(
              color: CupertinoColors.white,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 260,
                  child: TextInput(
                    label: 'IC / Passport'.tr,
                    controller: _idNumber,
                    prefixWidth: 130,
                    maxLength: 255,
                    required: true,
                    enabled: (verificationStatus != 1) ? true : false,
                  ),
                ),
                Visibility(
                  visible: _idNumber.text.isNotEmpty,
                  replacement: const SizedBox(
                    width: 100,
                    height: 35,
                  ),
                  child: Visibility(
                    visible: (verificationStatus != 1),
                    replacement: GestureDetector(
                      onTap: () {
                        Toast.show(
                            context, 'success', 'IC/Passport Verified'.tr);
                      },
                      child: Container(
                        width: 75,
                        height: 35,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Verified'.tr,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            color: CupertinoColors.systemGreen,
                          ),
                        ),
                      ),
                    ),
                    child: Visibility(
                      visible: (imageName == '' || verificationStatus == 2),
                      replacement: GestureDetector(
                        onTap: () {
                          Toast.show(context, 'default',
                              'Verifying uploaded IC/Passport...');
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 20 / 100,
                          height: 35,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            'Processing'.tr,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: CupertinoTheme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return IDVerify();
                          })).then((value) {
                            if (value == true) {
                              fetchStatus(context);
                            }
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 20 / 100,
                          height: 35,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Visibility(
                                visible: verificationStatus == 2,
                                replacement: Container(),
                                child: const Icon(
                                  CupertinoIcons.exclamationmark_circle_fill,
                                  size: 15,
                                  color: CupertinoColors.systemRed,
                                ),
                              ),
                              Text(
                                'Verify'.tr,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _changePassword() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () =>
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return ProfilePasswordScreen(
          userId: _userId!,
        );
      })),
      child: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          border: Border(
            top: BorderSide(color: CupertinoColors.systemGrey5),
            bottom: BorderSide(color: CupertinoColors.systemGrey5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Change Password'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
            const SizedBox(
              width: 12,
              child: Icon(CupertinoIcons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  _submitButton() {
    return Container(
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
          onPressed: (!_canSubmit)
              ? null
              : () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (_formKey.currentState!.validate()) {
                    _submitForm(_formKey.currentContext!);
                  }
                },
          child: Text('Save'.tr,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w300)),
        ),
      ),
    );
  }

  _deleteButton() {
    return Container(
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
          color: CupertinoColors.destructiveRed,
          disabledColor: CupertinoColors.inactiveGray,
          padding: EdgeInsets.zero,
          onPressed: () {
            showAlertDialog(context);
          },
          child: Text('Request Delete Account'.tr,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w300)),
        ),
      ),
    );
  }

  _showPickerGender() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 0.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.red,
                          fontWeight: FontWeight.w300),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  ),
                  CupertinoButton(
                    child: Text('Confirm'.tr),
                    onPressed: () {
                      setState(() {
                        genderName = _listGender[gender];
                      });
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: gender),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  setState(() {
                    gender = value;
                  });
                },
                itemExtent: 32.0,
                children: [
                  Text(
                    'Male'.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color.fromARGB(255, 104, 104, 104),
                        fontWeight: FontWeight.w300),
                  ),
                  Text(
                    'Female'.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color.fromARGB(255, 104, 104, 104),
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _showPickerNationality() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 0.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  ),
                  CupertinoButton(
                    child: Text('Confirm'.tr),
                    onPressed: () {
                      setState(() {
                        nationalityName = _listNationality[nationality];
                      });
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: nationality),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  setState(() {
                    nationality = value;
                  });
                },
                itemExtent: 32.0,
                children: const [
                  Text(
                    'Malaysian',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color.fromARGB(255, 104, 104, 104),
                        fontWeight: FontWeight.w300),
                  ),
                  Text(
                    'Non-Malaysian',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color.fromARGB(255, 104, 104, 104),
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = CupertinoButton(
      child: Text('Cancel'.tr),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // ignore: deprecated_member_use
    Widget continueButton = CupertinoButton(
      child: Text('Continue'.tr),
      onPressed: () {
        deleteAccount(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        'Alert'.tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
      content: Text(
          'By continuing, you cannot undo the action, the account will permanently deleted after approval from Tdlabs.'
              .tr),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> fetchStatus(BuildContext context) async {
    var response = await IdVerify.fetch(context);
    if (response != null) {
      setState(() {
        verificationStatus = response['status'];
        imageName = (response['image'] != null) ? response['image'] : '';
      });
    }
  }

  Future<void> _fetchAddress() async {
    address =
        await Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
      return AddressForm(
        availableAddress: (address.isNotEmpty) ? address : [],
      );
    }));
    setState(() {
      cityName = address[0]['city'];
    });
  }



   Future<BioData?> fetchBio(BuildContext context) async {
    final webService = WebService(context);
    BioData? bioData;
    var response = await webService.setEndpoint('identity/user-biodatas/get').send();
    if (response == null) return null;
    if (response.status) {
      BioData bioData = BioData.fromJson(jsonDecode(response.body.toString()));
      if (bioData != null) {
        bioHeightName = bioData.height!;
      }
    }
    return bioData;
  }


  Future<void> _populateForm() async {
    User? user = await User.fetchOne(context);
    if (user != null) {
      setState(() {
        _userId = user.id;
        _nameController.text = (user.name != null) ? user.name! : '';
        _emailController.text = (user.email != null) ? user.email! : '';
        email = (user.email != null) ? user.email! : '';
        _dobController.text = (user.dob != null) ? user.dob! : '';
        _phoneNoController.text = (user.phoneNo != null) ? user.phoneNo! : '';
        phoneNo = (user.phoneNo != null) ? user.phoneNo! : '';
        _idNumber.text = (user.id_no != null) ? user.id_no! : '';
        cityName = (user.city != null) ? user.city : '';
        gender = (user.gender != null) ? user.gender! : 0;
        nationality = (user.nationality != null) ? user.nationality! : 0;
        genderName = (user.gender != null) ? _listGender[user.gender!] : '';
        nationalityName = (user.nationality != null)
            ? _listNationality[user.nationality!]
            : '';
        usernameType = user.usernameType;
        isGoogle = (user.oauth_social != null) ? true : false;

        if (usernameType == 1) {
          setState(() {
            isPhone = false;
          });
        }

        _canSubmit = true;
      });
      if (address.isNotEmpty) {
        setState(() {
          address.add({
            'address1': user.address1!,
            'address2': user.address2!,
            'postcode': user.postcode,
            'city': user.city,
            'state': user.state,
            'country': user.country,
          });
        });
      }
    }

  }

  Future<void> _submitForm(BuildContext context) async {
    User user = User();
    user.name = _nameController.text;
    user.email = _emailController.text;
    user.id_no = _idNumber.text;
    user.dob = _dobController.text;
    user.gender = gender;
    user.nationality = nationality;
    if (address.isNotEmpty) {
      user.address1 = address[0]['address1'];
      user.address2 = address[0]['address2'];
      user.postcode = address[0]['postcode'];
      user.city = address[0]['city'];
      user.state = address[0]['state_code'];
      user.country = address[0]['country'];
    }
    List<String> errors = User.validate(user, scenario: 'update');
    if ((_userId != null) && (errors.isEmpty)) {
      final GlobalKey progressDialogKey = GlobalKey<State>();
      ProgressDialog.show(context, progressDialogKey);
      var response = await User.update(context, _userId!, user);
      ProgressDialog.hide(progressDialogKey);
      if (response != null) {
        if (response.status) {
          Toast.show(context, 'default', 'Record updated.');
        } else if (response.error.isNotEmpty) {
          errors.add(response.error.values.toList()[0]);
        }
      } else {
        errors.add('Server connection timeout.');
      }
    }

    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    final webService = WebService(context);
    String endpoint = 'identity/users/delete';
    List<String> errors = [];
    webService.setMethod('PUT').setEndpoint(endpoint);

    final GlobalKey progressDialogKey = GlobalKey<State>();
    ProgressDialog.show(context, progressDialogKey);
    var response = await webService.send();
    ProgressDialog.hide(progressDialogKey);

    if (response == null) return;

    if (response.status) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Toast.show(context, 'default', 'Request for account deletion success.');
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
