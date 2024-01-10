import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/screens/user/password_request_email.dart';
import 'package:tdlabs/screens/user/password_verify.dart';
import '../../models/user/password.dart';
import '../../utils/progress_dialog.dart';
import '../../utils/toast.dart';
import '../../widgets/form/text_input.dart';

class PasswordRequestScreen extends StatefulWidget {
  const PasswordRequestScreen({Key? key}) : super(key: key);

  @override
  _PasswordRequestScreenState createState() => _PasswordRequestScreenState();
}

class _PasswordRequestScreenState extends State<PasswordRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNoController = TextEditingController();

  @override
  void dispose() {
    _phoneNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 14),
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
                          "Password Reset Request".tr,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextInput(
                      prefixWidth: 85,
                      label: 'Phone No.'.tr,
                      controller: _phoneNoController,
                      type: 'phoneNo',
                      maxLength: 20),
                ),
                Container(
                  width: 150,
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
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: SizedBox(
                    child: CupertinoButton(
                      disabledColor: CupertinoColors.inactiveGray,
                      padding: EdgeInsets.zero,
                      onPressed: () {
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
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (context) {
                        return const PasswordRequestEmailScreen();
                      }));
                    },
                    child: Text('Request By Email'.tr,
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontFamily: 'Montserrat',
                            color: CupertinoColors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    String phoneNo = _phoneNoController.text;
    List<String> errors = [];
    if (phoneNo.isEmpty) {
      errors.add('Phone No. field cannot be blank.');
    } else if (phoneNo.length < 8) {
      errors.add('Phone No. should contain at least 8 characters.');
    }
    if (errors.isEmpty) {
      final GlobalKey progressDialogKey = GlobalKey<State>();
      ProgressDialog.show(context, progressDialogKey);
      var response = await Password.resetRequest(context, phoneNo, 0);
      ProgressDialog.hide(progressDialogKey);
      if (response != null) {
        if (response.status) {
          List<Map<String, dynamic>> list = [];
          list.add({'username': phoneNo, 'username_type': 0});
          Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (context) {
            return PasswordVerifyScreen(
              list: list,
              username: phoneNo,
              type: 0,
            );
          }));
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
}
