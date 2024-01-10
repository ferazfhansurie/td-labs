import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../../models/user/password.dart';
import '../../utils/progress_dialog.dart';
import '../../utils/toast.dart';
import '../../widgets/form/text_input.dart';

class ProfilePasswordScreen extends StatefulWidget {
  final int userId;

  const ProfilePasswordScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _ProfilePasswordScreenState createState() => _ProfilePasswordScreenState();
}

class _ProfilePasswordScreenState extends State<ProfilePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmnewPasswordController = TextEditingController();
  late int? _userId;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
  }

  @override
  void dispose() {
    _currPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmnewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Change Password'.tr,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                fontSize: 20,
              )),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).padding.top + 44),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _passwordInput(),
                  _saveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _passwordInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          TextInput(
              prefixWidth: 190,
              label: 'Current Password',
              controller: _currPasswordController,
              type: 'password',
              maxLength: 20,
              required: true),
          TextInput(
              prefixWidth: 190,
              label: 'New Password',
              controller: _newPasswordController,
              type: 'password',
              maxLength: 20,
              required: true),
          TextInput(
              prefixWidth: 190,
              label: 'Confirm New Password',
              controller: _confirmnewPasswordController,
              type: 'password',
              maxLength: 20,
              required: true),
        ],
      ),
    );
  }

  _saveButton() {
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
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            if (_formKey.currentState!.validate()) {
              _submitForm(_formKey.currentContext!);
            }
          },
          child: Text('Save'.tr,
              style: const TextStyle(
                  fontFamily: 'Montserrat', color: CupertinoColors.white)),
        ),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    String currPassword = _currPasswordController.text;
    String newPassword = _newPasswordController.text;

    List<String> errors = [];
    if (newPassword != _confirmnewPasswordController.text) {
      errors.add('New Password and Confirm Password should be the same');
    }
    if (currPassword.isEmpty) {
      errors.add('Current Password field cannot be blank.');
    }

    if (newPassword.isEmpty) {
      errors.add('New Password field cannot be blank.');
    } else if (newPassword.length < 6) {
      errors.add('New Password should contain at least 6 characters.');
    }

    if ((_userId != null) && (errors.isEmpty)) {
      final GlobalKey progressDialogKey = GlobalKey<State>();
      ProgressDialog.show(context, progressDialogKey);
      var response = await Password.changePassword(
          context, _userId!, currPassword, newPassword);
      ProgressDialog.hide(progressDialogKey);

      if (response != null) {
        if (response.status) {
          Navigator.pop(context);
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
