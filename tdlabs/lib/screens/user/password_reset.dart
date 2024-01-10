// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import '../../models/user/password.dart';
import '../../utils/progress_dialog.dart';
import '../../utils/toast.dart';
import '../../widgets/form/text_input.dart';

class PasswordResetScreen extends StatefulWidget {
  String? passwordResetToken;
  PasswordResetScreen({Key? key, this.passwordResetToken}) : super(key: key);
  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  String? _passwordResetToken;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _passwordResetToken = widget.passwordResetToken;

    return CupertinoPageScaffold(
      navigationBar:
          const CupertinoNavigationBar(middle: Text('Password Reset Request')),
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
                TextInput(
                    prefixWidth: 200,
                    label: 'New Password',
                    controller: _passwordController,
                    type: 'password',
                    maxLength: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: CupertinoColors.white,
                    border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey5),),
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
                      child: const Text('Submit',
                          style: TextStyle(
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
    String password = _passwordController.text;
    List<String> errors = [];
    if (password.isEmpty) {
      errors.add('New Password field cannot be blank.');
    } else if (password.length < 6) {
      errors.add('New Password should contain at least 6 characters.');
    }
    if (errors.isEmpty) {
      final GlobalKey progressDialogKey = GlobalKey<State>();
      ProgressDialog.show(context, progressDialogKey);
      var response = await Password.resetUpdate(context, _passwordResetToken!, password, 0);
      ProgressDialog.hide(progressDialogKey);
      if (response != null) {
        if (response.status) {
          Navigator.of(context).pushReplacementNamed('/login');
          Toast.show(context, 'default', 'Password updated.');
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
