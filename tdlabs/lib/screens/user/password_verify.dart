// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tdlabs/screens/user/password_reset.dart';
import '../../models/user/password.dart';
import '../../utils/progress_dialog.dart';
import '../../utils/toast.dart';
import '../../widgets/form/pin_input.dart';

class PasswordVerifyScreen extends StatefulWidget {
  List<Map<String, dynamic>>? list;
  String? username;
  int? type;
  PasswordVerifyScreen({Key? key, this.list, this.username, this.type}): super(key: key);
  @override
  _PasswordVerifyScreenState createState() => _PasswordVerifyScreenState();
}

class _PasswordVerifyScreenState extends State<PasswordVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Verify PIN')),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 44),
        color: CupertinoColors.systemFill,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Please verify your PIN.
                Container(
                  alignment: Alignment.centerLeft,
                  padding:const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  color: CupertinoColors.white,
                  child: Center(
                    child: Column(
                      children: [
                        const Text('Please key in the 6 digit PIN sent to your'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('registered '),
                            Text('mobile phone no/email.'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 40),
                  color: CupertinoColors.white,
                  child: PinInput(
                      controller: _pinController,
                      onCompleted: (value) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (_formKey.currentState!.validate()) {
                          _submitForm(_formKey.currentContext!, widget.list!);
                        }
                      }),
                ),
                Container(
                  color: Colors.white,
                  child: Lottie.network(
                      'https://assets3.lottiefiles.com/packages/lf20_iZXXuz.json',
                      frameRate: FrameRate(60)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context, List<Map<String, dynamic>> list) async {
    String pin = _pinController.text;
    List<String> errors = [];
    if (pin.isEmpty) errors.add('PIN field cannot be blank.');
    if (errors.isEmpty) {
      final GlobalKey progressDialogKey = GlobalKey<State>();
      ProgressDialog.show(context, progressDialogKey);
      var response = await Password.resetVerify(context, widget.username!, pin, widget.type!);
      ProgressDialog.hide(progressDialogKey);
      if (response != null) {
        if (response.status) {
          var json = jsonDecode(response.body!);
          if ((json != null) && json.containsKey('password_reset_token')) {
            Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (context) {
              return PasswordResetScreen(
                  passwordResetToken: json['password_reset_token']);
            }));
          }
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
}
