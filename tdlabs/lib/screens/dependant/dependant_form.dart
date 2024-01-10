// ignore_for_file: must_be_immutable, unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/models/user/user-dependant.dart';
import 'package:tdlabs/screens/dependant/dependency.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/form/text_input.dart';
import 'package:get/get.dart';
class DependantFormScreen extends StatefulWidget {
  int? id;
  String? idno;
  String? name;
  String? email;
  String? phone;
  int? relation;
  int? age;
  DependantFormScreen(
      {Key? key,
      this.id,
      this.idno,
      this.name,
      this.email,
      this.phone,
      this.relation,
      this.age})
      : super(key: key);
  @override
  _DependantFormScreenState createState() => _DependantFormScreenState();
}
class _DependantFormScreenState extends State<DependantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _phoneNoController = TextEditingController();
  String email = "";
  String phoneNo = "";
  int? usernameType;
  String? parentId;
  bool add = true;
  int? _pickerIndex;
  int? age;
  String? relationName;
  List<UserDependant> _udList = [];
  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _populateForm();
    } else {
      _fetchUD();
      _pickerIndex = 0;
    }
    if (widget.name != null) {
      add = false;
    }
  }
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _idNumberController.dispose();
    _phoneNoController.dispose();
    _ageController.dispose();
    _udList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 25,
            color: Colors.white,
          ),
        ),
        middle: (widget.name == null)
            ? Text('Add Dependant'.tr,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 20,
                ))
            : Text('Edit Dependant'.tr,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 20,
                )),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: CupertinoColors.systemFill,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Form(
                key: _formKey,
                child: _dependantInput(),
              ),
              (add) ? _addButton() : _updateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _updateButton() {
    return Column(
      children: [
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
                _updateForm(_formKey.currentContext!);
              },
              child: Text('Update'.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                      color: CupertinoColors.white)),
            ),
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
              color: CupertinoColors.destructiveRed,
              disabledColor: CupertinoColors.inactiveGray,
              padding: EdgeInsets.zero,
              onPressed: () {
                showAlertDialog(context);
              },
              child: Text('Delete'.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                      color: CupertinoColors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addButton() {
    return Column(
      children: [
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
                _submitForm(_formKey.currentContext!);
              },
              child: Text('Add'.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                      color: CupertinoColors.white)),
            ),
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
              color: CupertinoColors.destructiveRed,
              disabledColor: CupertinoColors.inactiveGray,
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                      color: CupertinoColors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dependantInput() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              TextInput(
                label: 'Name'.tr,
                prefixWidth: 120,
                controller: _nameController,
                maxLength: 255,
                required: true,
              ),
              TextInput(
                label: 'IC/ Passport'.tr,
                prefixWidth: 120,
                controller: _idNumberController,
                type: 'phoneNo',
                maxLength: 12,
                required: true,
              ),
              TextInput(
                label: 'Age'.tr,
                type: 'phoneNo',
                prefixWidth: 120,
                controller: _ageController,
                maxLength: 2,
                required: true,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _showPickerRelation();
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                          Text(
                            'Relation'.tr,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 62),
                          child: Text(
                              (relationName != null) ? relationName!.tr : '',
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
              TextInput(
                label: 'Email'.tr,
                prefixWidth: 120,
                controller: _emailController,
                type: 'email',
                maxLength: 255,
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextInput(
                      label: 'Contact No'.tr,
                      controller: _phoneNoController,
                      prefixWidth: 120,
                      maxLength: 12,
                      type: 'phoneNo',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  showAlertDialog(BuildContext context) {

    Widget cancelButton = CupertinoButton(
      child: Text('Cancel'.tr),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = CupertinoButton(
      child: Text('Continue'.tr),
      onPressed: () {
        deleteAccount(context);
      },
    );
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
          'By continuing, you cannot undo the action, the dependent will be permanently deleted'.tr),
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

  _showPickerRelation() {
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
                        fontWeight: FontWeight.w300,
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 5.0,),
                  ),
                  CupertinoButton(
                    child: Text('Confirm'.tr),
                    onPressed: () {
                      setState(() {
                        widget.relation = _pickerIndex;
                        relationName = _udList[_pickerIndex!].name;
                      });
                      Navigator.of(context).pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 5.0,),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController:FixedExtentScrollController(initialItem: _pickerIndex!),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  if (mounted) {
                    setState(() {
                      _pickerIndex = value;
                    });
                  }
                },
                itemExtent: 32.0,
                children: [
                  for (var relation in _udList)
                    Text(relation.name!.tr,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                          color: Color.fromARGB(255, 104, 104, 104),
                        )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<UserDependant>?> _fetchUD() async {
    final webService = WebService(context);

    webService.setEndpoint('option/list/relation');

    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      final parseList2 =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<UserDependant> relation = parseList2.map<UserDependant>((json) => UserDependant.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _udList.addAll(relation);
          relationName = _udList[0].name;
        });
      }
    }
    return _udList;
  }

  Future<void> _populateForm() async {
    if (widget.idno != null) {
      if (mounted) {
        setState(() {
          _idNumberController.text = widget.idno!;
          _nameController.text = (widget.name != null) ? widget.name! : '';
          _emailController.text = (widget.email != null) ? widget.email! : '';
          email = (widget.email != null) ? widget.email! : '';
          _phoneNoController.text = (widget.phone != null) ? widget.phone! : '';
          phoneNo = (widget.phone != null) ? widget.phone! : '';
          _ageController.text =(widget.age.toString() != null) ? widget.age.toString() : '';
        });
      }
      _udList = (await _fetchUD())!;
      _pickerIndex = (widget.relation != null) ? widget.relation : 0;
      relationName = _udList[_pickerIndex!].name;
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    UserDependant userDependant = UserDependant();
    userDependant.name = _nameController.text;
    userDependant.email = _emailController.text;
    userDependant.idno = _idNumberController.text;
    userDependant.phone = _phoneNoController.text;
    userDependant.age =(_ageController.text != "") ? int.parse(_ageController.text) : 0;
    userDependant.relation = _pickerIndex;
    List<String> errors = UserDependant.validate(userDependant);
    if ((userDependant.name != null) && (errors.isEmpty)) {
      final GlobalKey progressDialogKey = GlobalKey<State>();
      ProgressDialog.show(context, progressDialogKey);
      var response = await UserDependant.create(context, userDependant);
      ProgressDialog.hide(progressDialogKey);
      if (response != null) {
        if (response.status) {
          Toast.show(context, 'default', 'Record created.'.tr);
          Navigator.pop(context);
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return const Dependency();
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

  Future<void> _updateForm(BuildContext context) async {
    int uid = widget.id!;
    UserDependant userDependant = UserDependant();
    userDependant.name = _nameController.text;
    userDependant.email = _emailController.text;
    userDependant.idno = _idNumberController.text;
    userDependant.phone = _phoneNoController.text;
    userDependant.age = (_ageController.text != "") ? int.parse(_ageController.text) : 0;
    userDependant.relation =(_pickerIndex != null) ? _pickerIndex : widget.relation;
    List<String> errors = UserDependant.validate(userDependant);
    final GlobalKey progressDialogKey = GlobalKey<State>();
    ProgressDialog.show(context, progressDialogKey);
    var response = await UserDependant.update(context, uid, userDependant);
    ProgressDialog.hide(progressDialogKey);
    if (response != null) {
      if (response.status) {
        Toast.show(context, 'default', 'Record created.');
        Navigator.pop(context);
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return const Dependency();
        }));
      } else if (response.error.isNotEmpty) {
        errors.add(response.error.values.toList()[0]);
      }
    } else {
      errors.add('Server connection timeout.');
    }

    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    String uid = widget.id.toString();
    final webService = WebService(context);
    List<String> errors = [];
    webService.setMethod('POST').setEndpoint('identity/user-dependants/delete/$uid');
    final GlobalKey progressDialogKey = GlobalKey<State>();
    ProgressDialog.show(context, progressDialogKey);
    var response = await webService.send();
    ProgressDialog.hide(progressDialogKey);
    if (response == null) return;
    if (response.status) {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return const Dependency();
      }));
      Toast.show(context, 'default', 'Dependant Deleted');
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
