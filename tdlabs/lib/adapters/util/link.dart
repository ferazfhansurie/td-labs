// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlabs/utils/toast.dart';

import '../../utils/web_service.dart';
import 'package:get/get.dart' as Get;

// ignore: must_be_immutable
class LinkAdapter extends StatefulWidget {
  Color? color;
  String? companyName;
  int? id;
  int? status;
  int? currentTab;
  LinkAdapter(
      {Key? key, this.companyName, this.id, this.status, this.currentTab})
      : super(key: key);
  @override
  _LinkAdapterState createState() => _LinkAdapterState();
}
class _LinkAdapterState extends State<LinkAdapter> {
  @override
  void initState() {
    super.initState();
  }
  showAlertDialogDecline(BuildContext context) {
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
      child: Text('Confirm'.tr),
      onPressed: () {
        _declineInvite();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        'Confirm Decline Invitation?'.tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
      content: Text('Current action cannot be revert.'.tr),
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
  showAlertDialogUnlink(BuildContext context) {
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
      child: Text('Confirm'.tr),
      onPressed: () {
        _unlinkCompany();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        'Unlink from this company?'.tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
      content: Text('Current action cannot be revert.'.tr),
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
  @override
  Widget build(BuildContext context) {
    Color _color =(widget.color != null) ? widget.color! : CupertinoColors.systemGrey6;
    if ((widget.status == 0 && widget.currentTab == 0) ||
        (widget.status == 1 && widget.currentTab == 1)) {
      return _link(_color);
    } else {
      return Container();
    }
  }

  Widget _link(Color _color) {
    return Container(
      color: _color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                width: MediaQuery.of(context).size.width * 60 / 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.companyName!,
                      softWrap: true,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300),
                    ),
                    Visibility(
                        visible: (widget.status == 0),
                        replacement: Text('linked with company'.tr),
                        child: Text('have invited you.'.tr)),
                  ],
                ),
              ),
              Visibility(
                visible: (widget.status == 0),
                replacement: Container(
                  padding:const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: SizedBox(
                    width: 60,
                    height: 30,
                    child: CupertinoButton(
                      color: CupertinoColors.systemRed,
                      padding: const EdgeInsets.all(5),
                      onPressed: () {
                        showAlertDialogUnlink(context);
                      },
                      child: const Text(
                        'Unlink',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                            color: CupertinoColors.white,
                            fontSize: 12),
                      ),
                    ),
                  ),
                ),
                child: Container(
                  padding:const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 30,
                        child: CupertinoButton(
                          color: CupertinoColors.destructiveRed,
                          padding: const EdgeInsets.all(5),
                          onPressed: () {
                            showAlertDialogDecline(context);
                          },
                          child: Text(
                            'Decline'.tr,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w300,
                                color: CupertinoColors.white,
                                fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      SizedBox(
                        width: 60,
                        height: 30,
                        child: CupertinoButton(
                          color: CupertinoTheme.of(context).primaryColor,
                          padding: const EdgeInsets.all(5),
                          onPressed: () {
                            _acceptInvite();
                          },
                          child: Text(
                            'Accept'.tr,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w300,
                                color: CupertinoColors.white,
                                fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: CupertinoColors.separator, height: 1),
        ],
      ),
    );
  }
  Future<Response?> _acceptInvite() async {
    setState(() {
      widget.status = 1;
    });
    final webService = WebService(context);
    webService.setMethod('PUT').setEndpoint('company/invites/' + widget.id.toString());
    Map<String, String> data = {};
    data['status'] = widget.status.toString();
    var response = await webService.setData(data).send();
    if (response == null) return null;
    if (response.status == true) {
      Toast.show(context, 'success', 'Linked Successfully');
      return response;
    }
    return null;
  }

  Future<Response?> _declineInvite() async {
    setState(() {
      widget.status = 2;
    });
    final webService = WebService(context);
    webService.setMethod('PUT').setEndpoint('company/invites/' + widget.id.toString());
    Map<String, String> data = {};
    data['status'] = widget.status.toString();
    var response = await webService.setData(data).send();
    if (response == null) return null;
    if (response.status == true) {
      Toast.show(context, 'danger', 'Rejected');
      Navigator.of(context).pop();
      return response;
    }
    return null;
  }

  Future<Response?> _unlinkCompany() async {
    setState(() {
      widget.status = 10;
    });
    final webService = WebService(context);
    webService.setMethod('PUT').setEndpoint('company/invites/' + widget.id.toString());
    Map<String, String> data = {};
    data['status'] = widget.status.toString();
    var response = await webService.setData(data).send();
    if (response == null) return null;
    if (response.status == true) {
      Toast.show(context, 'success', 'Unlink Successful.');
      Navigator.of(context).pop();
      return response;
    }
    return null;
  }
}
