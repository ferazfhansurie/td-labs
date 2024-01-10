// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/screens/user/password_verify.dart';
import '../../models/user/password.dart';
import '../../utils/progress_dialog.dart';
import '../../utils/toast.dart';
import '../../widgets/form/text_input.dart';

class PasswordRequestEmailScreen extends StatefulWidget {
  const PasswordRequestEmailScreen({Key? key}) : super(key: key);

  @override
  _PasswordRequestEmailScreenState createState() =>
      _PasswordRequestEmailScreenState();
}

class _PasswordRequestEmailScreenState
    extends State<PasswordRequestEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
                      prefixWidth: 50,
                      label: 'Email',
                      controller: _emailController,
                      type: 'email'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    String email = _emailController.text;

    List<String> errors = [];
    if (email.isEmpty) {
      errors.add('Email field cannot be blank.');
    } else if (email.isNotEmpty) if (!EmailValidator.validate(email)) {
      errors.add('Invalid email address.');
    }

    if (errors.isEmpty) {
      final GlobalKey progressDialogKey = GlobalKey<State>();
      ProgressDialog.show(context, progressDialogKey);
      var response = await Password.resetRequest(context, email, 1);
      ProgressDialog.hide(progressDialogKey);

      if (response != null) {
        if (response.status) {
          List<Map<String, dynamic>> list = [];
          list.add({'username': email});
          list.add({'username_type': 1});
          Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (context) {
            return PasswordVerifyScreen(
              list: list,
              username: email,
              type: 1,
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
