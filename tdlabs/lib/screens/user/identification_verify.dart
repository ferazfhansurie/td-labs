import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/utils/toast.dart';
import '../../widgets/form/image_input.dart';
import '../../utils/progress_dialog.dart';
import '../../models/util/id_verify.dart';
import 'package:get/get.dart';

// ignore: use_key_in_widget_constructors
class IDVerify extends StatefulWidget {
  @override
  _IDVerifyState createState() => _IDVerifyState();
}

class _IDVerifyState extends State<IDVerify> {
  final imageController = TextEditingController();
  bool terms = false;
  int termsNum = 0;
  int? verificationStatus;

  @override
  void initState() {
    super.initState();
    //implement initState
    fetchStatus(context);
  }

  @override
  void dispose() {
    // implement dispose
    super.dispose();
    imageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Verify Identification'.tr),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).padding.top + 44),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                CupertinoColors.secondarySystemBackground,
                CupertinoTheme.of(context).primaryColor,
              ])),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: _idVerify(),
          ),
        ),
      ),
    );
  }

  Widget _idVerify() {
    return Column(
      children: [
        Container(
          color: CupertinoTheme.of(context).primaryColor,
          padding: const EdgeInsets.all(10),
          child: Text(
            'Please upload your IC/Passport photo for verification purposes, your IC/Passport must be shown clearly in the photo'.tr,
            style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: CupertinoColors.white),
          ),
        ),
        Visibility(
          visible: (verificationStatus == 2),
          replacement: Container(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.red.shade700,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(
                'Uploaded IC/Passport is rejected. Please try again.'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    color: CupertinoColors.white)),
          ),
        ),
        const Divider(height: 10),
        Container(
          color: CupertinoColors.white,
          child: ImageInput(
            label: '',
            controller: imageController,
            imageQuality: 20,
            canEdit: false,
            canPaint: false,
            cameraOnly: false,
          ),
        ),
        const Divider(height: 10),
        Container(
          width: MediaQuery.of(context).size.width,
          color: CupertinoColors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                decoration: const BoxDecoration(
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
                      submitVerification();
                    },
                    child: Text('Submit'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
        'Term & Condition'.tr,
        style: const TextStyle(
            fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
      ),
      content: const Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin venenatis magna magna, vitae condimentum sem tristique sed. Duis tristique volutpat risus, vel auctor justo aliquam posuere. Phasellus suscipit et est eu fermentum. Nulla eu maximus sem. Nullam rutrum mauris vel accumsan congue.'),
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

  Future<void> submitVerification() async {
    final GlobalKey progressDialogKey = GlobalKey<State>();
    IdVerify idVerify = IdVerify();
    if (imageController.text.isNotEmpty) {
      idVerify.image = imageController.text;
      idVerify.declaration = termsNum;
      List<String> errors = IdVerify.validate(idVerify);
      ProgressDialog.show(context, progressDialogKey);
      var response = await IdVerify.submit(context, idVerify);
      ProgressDialog.hide(progressDialogKey);
      if (response != null) {
        if (response.status) {
          Toast.show(context, 'default', 'Upload succeed, verification in process');
          Navigator.pop(context, true);
        } else if (response.error.isNotEmpty) {
          errors.add(response.error.values.toList()[0]);
        } else {
          errors.add('Server connection timeout.');
        }
      }
      if (errors.isNotEmpty) {
        Toast.show(context, 'danger', errors[0]);
      }
    } else {
      Toast.show(context, 'danger', 'Upload your IC/Passport photo');
    }
  }
  Future<void> fetchStatus(BuildContext context) async {
    var response = await IdVerify.fetch(context);
    if (response != null) {
      setState(() {
        verificationStatus = response['status'];
      });
    }
  }
}
