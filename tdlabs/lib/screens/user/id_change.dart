import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/form/text_input.dart';
import '../../utils/progress_dialog.dart';
import '../../utils/toast.dart';
import 'id_verify.dart';

// ignore: must_be_immutable
class IDChangeScreen extends StatefulWidget {
  String? phoneNo;
  String? email;
  int? usernameType;
  IDChangeScreen({Key? key, this.phoneNo, this.email, this.usernameType})
      : super(key: key);
  @override
  _IDChangeScreenState createState() => _IDChangeScreenState();
}

class _IDChangeScreenState extends State<IDChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPhoneNoController = TextEditingController();
  final _newPhoneNoRetypeController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _newEmailRetypeController = TextEditingController();
  bool isFromEmail = true;
  int usernameType = 0;

  @override
  void initState() {
    //implement initState
    super.initState();
    if (widget.usernameType == 0) {
      setState(() {
        isFromEmail = false;
        usernameType = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/Background-01.png"),
                    fit: BoxFit.fill),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: SingleChildScrollView(
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
                            "Change ID".tr,
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          _dividerId(),
                          _userForm(),
                          _changeButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 7 / 100,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ((isFromEmail)
                    ? (_newPhoneNoController.text == '' ||
                        _newPhoneNoRetypeController.text == '')
                    : (_newEmailController.text == '' ||
                        _newEmailRetypeController.text == ''))
                ? Container(
                    color: CupertinoColors.inactiveGray,
                    height: MediaQuery.of(context).size.height * 8 / 100,
                    width: MediaQuery.of(context).size.width * 20 / 100,
                    child: Center(
                      child: Text(
                        'Confirm'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                            color: CupertinoColors.white),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      submitChange(context);
                    },
                    child: Container(
                      color: CupertinoTheme.of(context).primaryColor,
                      height: MediaQuery.of(context).size.height * 8 / 100,
                      width: MediaQuery.of(context).size.width * 20 / 100,
                      child: Center(
                        child: Text(
                          'Confirm'.tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              color: CupertinoColors.white),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _dividerId() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 52, 169, 176),
            Color.fromARGB(255, 49, 42, 130),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your Tdlabs ID'.tr,
            style: const TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 15),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ((widget.usernameType == 0) ? widget.phoneNo! : widget.email!),
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    fontSize: 15),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  showAlertDialogTerm(context);
                },
                child: const Icon(
                  CupertinoIcons.question_circle,
                  color: CupertinoColors.destructiveRed,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter New Tdlabs ID'.tr,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Color.fromARGB(255, 104, 104, 104),
                  fontWeight: FontWeight.w300,
                ),
              ),
              (isFromEmail)
                  ? TextInput(
                      label: '',
                      placeHolder: 'Phone Number'.tr,
                      controller: _newPhoneNoController,
                      prefixWidth: 10,
                      maxLength: 255,
                      type: 'phoneNo',
                      required: true,
                    )
                  : TextInput(
                      label: '',
                      placeHolder: 'Email'.tr,
                      prefixWidth: 10,
                      controller: _newEmailController,
                      type: 'email'.tr,
                      maxLength: 255,
                      required: true,
                    ),
              (isFromEmail)
                  ? TextInput(
                      label: '',
                      placeHolder: 'Retype Phone Number'.tr,
                      controller: _newPhoneNoRetypeController,
                      prefixWidth: 10,
                      maxLength: 255,
                      type: 'phoneNo',
                      required: true,
                    )
                  : TextInput(
                      label: '',
                      placeHolder: 'Retype Email'.tr,
                      prefixWidth: 10,
                      controller: _newEmailRetypeController,
                      type: 'email',
                      maxLength: 255,
                      required: true,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _changeButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
      ),
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              FocusScope.of(context).unfocus();
              _newPhoneNoController.clear();
              _newPhoneNoRetypeController.clear();
              _newEmailController.clear();
              _newEmailRetypeController.clear();
              isFromEmail = !isFromEmail;
              (isFromEmail) ? usernameType = 0 : usernameType = 1;
            });
          },
          child: Text(
            ((isFromEmail
                ? 'My new ID is an Email'.tr
                : 'My new ID is a phone number'.tr)),
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: CupertinoTheme.of(context).primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
  }

  showAlertDialogTerm(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = CupertinoButton(
      onPressed: () {},
      child: Container(),
    );
    // ignore: deprecated_member_use
    Widget continueButton = CupertinoButton(
      child: Text('Continue'.tr),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        'Info'.tr,
      ),
      content: Text('Info-IdChange'.tr),
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

  Future<void> submitChange(BuildContext context) async {
    final webService = WebService(context);
    String endpointPhone = 'identity/users/change-phone';
    String endpointEmail = 'identity/users/change-email';
    List<String> errors = [];
    webService.setMethod('POST').setEndpoint((isFromEmail) ? endpointPhone : endpointEmail);
    Map<String, String> data = {};
    if (isFromEmail) {
      data.addAll({'phone_no': _newPhoneNoController.text});
      data.addAll({'phone_no_retype': _newPhoneNoRetypeController.text});
    } else {
      data.addAll({'email': _newEmailController.text});
      data.addAll({'email_retype': _newEmailRetypeController.text});
    }

    final GlobalKey progressDialogKey = GlobalKey<State>();
    ProgressDialog.show(context, progressDialogKey);
    var response = await webService.setData(data).send();
    ProgressDialog.hide(progressDialogKey);
    if (response == null) return;
    if (response.status) {
      Navigator.push(context, CupertinoPageRoute(builder: (context) {
        return IDVerifyScreen(
          usernameType: usernameType,
          phoneNo: _newPhoneNoController.text,
          email: _newEmailController.text,
        );
      }));
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
