// ignore_for_file: unused_field, unnecessary_null_comparison

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_place/google_place.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/util/country_state.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:tdlabs/screens/others/lalamove.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/form/text_input.dart';
import 'dart:convert';
import 'package:get/get.dart';

// ignore: must_be_immutable
class AddressForm extends StatefulWidget {
  List<Map<String, dynamic>>? availableAddress;
  String? delivery;
  String? location;

  AddressForm({Key? key, this.availableAddress, this.delivery, this.location})
      : super(key: key);
  @override
  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final postcodeController = TextEditingController();
  final cityController = TextEditingController();
  int? _userId;
  bool _canSubmit = false;
  bool _isLoadingCS = false;
  List<CountryState> _csList = [];
  Map<String, String> stateList = {
    'all': '',
    'my-01': 'Johor',
    'my-02': 'Kedah',
    'my-03': 'Kelantan',
    'my-04': 'Melaka',
    'my-05': 'Negeri Sembilan',
    'my-06': 'Pahang',
    'my-07': 'Pulau Pinang',
    'my-08': 'Perak',
    'my-09': 'Perlis',
    'my-10': 'Selangor',
    'my-11': 'Terengganu',
    'my-12': 'Sabah',
    'my-13': 'Sarawak',
    'my-14': 'Wilayah Persekutuan Kuala Lumpur',
    'my-15': 'Labuan',
    'my-16': 'Putrajaya',
  };
  int state = 0;
  String? stateName;
  int? stateIndex;
  int country = 0;
  final List<String> _listCountry = ['Malaysia'];
  final List<String> _listCountryCode = ['my'];
  String? countryName;
  String? countryCode;
  int _pickerIndex = 0;
  String _stateCode = '';
  List<Map<String, dynamic>> address = [];
  String? street;
  bool isAvailable = false;
  late GooglePlace googlePlace;

  DetailsResult? locationResult;
  final _locationController = TextEditingController();

  String latitude = "";
  String longitude = "";
  @override
  void initState() {
    super.initState();
    countryName = _listCountry[country];
    String apiKey = MainConfig.googleMapApi;
    googlePlace = GooglePlace(apiKey);
    if (widget.location != null) {
      _locationController.text = widget.location!;
    }
    if (widget.availableAddress!.isNotEmpty) {
      latitude = widget.availableAddress![0]['latitude'];
      longitude = widget.availableAddress![0]['longitude'];
    }
    _populateForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                backgroundColor: Colors.white,
                leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop([]);
                  },
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 25,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                ),
                middle: Text('Current Address'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                    )),
              ),
              child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/Background-01.png"),
                        fit: BoxFit.fill),
                  ),
                  child: _addressForm())),
        ),
      ),
    );
  }

  Widget _addressForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.delivery == "Lalamove")
                Column(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Location'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 55,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        Map<String, dynamic> lalamove;
                        var temp = await Navigator.of(context)
                            .push(CupertinoPageRoute(builder: (context) {
                          return Lalamove(
                            locationController: _locationController,
                            address1Controller: address1Controller,
                            address2Controller: address2Controller,
                            cityController: cityController,
                            postcodeController: postcodeController,
                            googlePlace: googlePlace,
                          );
                        }));
                        if (temp != null) {
                          lalamove = temp;
                          if (lalamove != null) {
                            setState(() {
                              widget.location = lalamove['name'];
                            });
                            try {
                              // Use geocoding to get the address components
                              List<Placemark> placemarks =
                                  await placemarkFromCoordinates(
                                      lalamove['latitude'],
                                      lalamove['longitude'],
                                      localeIdentifier: lalamove['name']);

                              if (placemarks.isNotEmpty) {
                                Placemark placemark = placemarks[0];

                                setState(() {
                                  stateName =
                                      placemark.administrativeArea ?? '';
                                  if (stateName ==
                                      "Wilayah Persekutuan Kuala Lumpur") {
                                    stateName = "Kuala Lumpur";
                                  }
                                  for (int i = 0; i < _csList.length; i++) {
                                    if (stateName == _csList[i].name) {
                                      _stateCode = _csList[i].code;
                                    }
                                  }
                                });
                              }
                            } catch (e) {
                              // ignore: avoid_print
                              print('Error getting address components: $e');
                            }
                            latitude = lalamove['latitude'].toString();
                            longitude = lalamove['longitude'].toString();
                          }
                        } else {
                          setState(() {});
                        }
                      },
                      child: Card(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Visibility(
                                    visible: (locationResult == null ||widget.location == null),
                                    replacement: Container(
                                      width: 10,
                                    ),
                                    child: Row(
                                      children: const [
                                        SizedBox(width: 2),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Expanded(
                                child: Text(
                                  (widget.location == null)
                                      ? (locationResult != null)
                                          ? widget.location!
                                          : 'Drop-Off Location'
                                      : widget.location!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 104, 104, 104),
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'Montserrat',
                                  ),
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
                    ),
                  ),
                ]),
              if (widget.delivery == "Lalamove")
                Container(
                  padding:const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Address'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                  ),
                ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 40 / 100,
                child: Column(
                  children: [
                    Flexible(
                      child: TextInput(
                        label: 'Street 1'.tr,
                        controller: address1Controller,
                        prefixWidth: 80,
                        maxLength: 255,
                        required: true,
                      ),
                    ),
                    Flexible(
                      child: TextInput(
                        label: 'Street 2'.tr,
                        controller: address2Controller,
                        prefixWidth: 80,
                        maxLength: 255,
                        required: false,
                      ),
                    ),
                    Flexible(
                      child: TextInput(
                        label: 'Postcode'.tr,
                        controller: postcodeController,
                        prefixWidth: 80,
                        maxLength: 255,
                        type: 'phoneNo',
                        required: true,
                      ),
                    ),
                    Flexible(
                      child: TextInput(
                        label: 'City'.tr,
                        controller: cityController,
                        prefixWidth: 80,
                        maxLength: 255,
                        required: true,
                      ),
                    ),
                    Flexible(
                      child: GestureDetector(
                        key: const Key("state"),
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _showStatePicker();
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: const BoxDecoration(
                            color: CupertinoColors.white,
                            border: Border(
                              bottom: BorderSide(
                                  color: CupertinoColors.systemGrey5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'State'.tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      color: Color.fromARGB(255, 104, 104, 104),
                                    ),
                                  ),
                                  Visibility(
                                    visible: (stateName == null),
                                    replacement: Container(
                                      width: 10,
                                    ),
                                    child: Row(
                                      children: const [
                                        SizedBox(width: 2),
                                        Icon(
                                          CupertinoIcons
                                              .exclamationmark_circle_fill,
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
                                  padding: const EdgeInsets.only(left: 42),
                                  child: Text(
                                    (stateName != null) ? stateName! : '',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 104, 104, 104),
                                      fontWeight: FontWeight.w300,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
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
                    ),
                    Flexible(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _showPickerCountry();
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: const BoxDecoration(
                            color: CupertinoColors.white,
                            border: Border(
                              bottom: BorderSide(
                                  color: CupertinoColors.systemGrey5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Country'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                  color: Color.fromARGB(255, 104, 104, 104),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 26),
                                  child: Text(
                                    countryName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        color:
                                            Color.fromARGB(255, 104, 104, 104),
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                                child: Icon(CupertinoIcons.chevron_right),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (widget.delivery != "Lalamove")
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: CupertinoColors.systemGrey5),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: Visibility(
                        visible: (address1Controller.text != '' &&
                            postcodeController.text != '' &&
                            cityController.text != '' &&
                            stateName != null &&
                            stateName != ''),
                        replacement: CupertinoButton(
                          color: CupertinoTheme.of(context).primaryColor,
                          disabledColor: CupertinoColors.inactiveGray,
                          padding: EdgeInsets.zero,
                          onPressed: null,
                          child: Text('Submit'.tr,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white)),
                        ),
                        child: CupertinoButton(
                          key: const Key("address_submit"),
                          color: CupertinoTheme.of(context).primaryColor,
                          disabledColor: CupertinoColors.inactiveGray,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _submitForm(context);
                          },
                          child: Text('Submit'.tr,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.delivery == "Lalamove")
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: CupertinoColors.systemGrey5),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: Visibility(
                        visible: (address1Controller.text != '' &&
                                postcodeController.text != '' &&
                                cityController.text != '' &&
                                stateName != null &&
                                stateName != '' &&
                                locationResult != null ||
                            widget.location != null),
                        replacement: CupertinoButton(
                          color: CupertinoTheme.of(context).primaryColor,
                          disabledColor: CupertinoColors.inactiveGray,
                          padding: EdgeInsets.zero,
                          onPressed: null,
                          child: Text('Submit'.tr,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white)),
                        ),
                        child: CupertinoButton(
                          key: const Key("address_submit"),
                          color: CupertinoTheme.of(context).primaryColor,
                          disabledColor: CupertinoColors.inactiveGray,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _submitForm(context);
                          },
                          child: Text('Submit'.tr,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  _showStatePicker() {
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
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(""); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  ),
                  CupertinoButton(
                    key: const Key("state_confirm"),
                    child: const Text('Confirm'),
                    onPressed: () {
                      setState(() {
                        _stateCode = _csList[_pickerIndex].code;
                        stateName = _csList[_pickerIndex].name;
                        stateIndex = _csList[_pickerIndex].index;
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
                    FixedExtentScrollController(initialItem: _pickerIndex),
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
                  for (var state in _csList)
                    Text(
                      state.name,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 104, 104, 104),
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _showPickerCountry() {
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
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
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
                    child: const Text('Confirm'),
                    onPressed: () {
                      setState(() {
                        countryName = _listCountry[country];
                        countryCode = _listCountryCode[country];
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
                    FixedExtentScrollController(initialItem: country),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  setState(() {
                    country = value;
                  });
                },
                itemExtent: 32.0,
                children: const [
                  Text(
                    'Malaysia',
                    style: TextStyle(
                      color: Color.fromARGB(255, 104, 104, 104),
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<CountryState>?> _fetchCS() async {
    final webService = WebService(context);
    if (!_isLoadingCS) {
      _isLoadingCS = true;
      webService.setEndpoint('option/list/address-state');
      var response = await webService.send();
      if (response == null) return null;
      if (response.status) {
        final parseList2 =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<CountryState> states = parseList2
            .map<CountryState>((json) => CountryState.fromJson(json))
            .toList();
        setState(() {
          _csList.addAll(states);
        });
      }
    }
    _isLoadingCS = false;
    return _csList;
  }

  Future<void> _populateForm() async {
    if (widget.availableAddress!.isNotEmpty) {
      setState(() {
        isAvailable = true;
      });
    }
    if (!isAvailable) {
      User? user = await User.fetchOne(context);
      if (mounted) {
        setState(() {
          _userId = user!.id;
        });
      }
      if (user!.state != null) {
        _stateCode = user.state!;
      }
      _csList = (await _fetchCS())!;
      for (var variable in _csList) {
        if (variable.code == _stateCode) {
          stateIndex = variable.index;
          stateName = variable.name;
          break;
        }
        _pickerIndex = (stateIndex != null) ? stateIndex! : 0;
        if (user.address1 != null) {
          address1Controller.text = user.address1!;
          address2Controller.text = user.address2!;
          postcodeController.text = user.postcode!;
          cityController.text = user.city!;
        }
        setState(() {
          _canSubmit = true;
        });
      }
    } else {
      setState(() {
        _stateCode = widget.availableAddress![0]['state'];
      });
      _csList = (await _fetchCS())!;
      for (var variable in _csList) {
        if (variable.code == _stateCode) {
          stateIndex = variable.index;
          stateName = variable.name;
        }
      }
      address1Controller.text = widget.availableAddress![0]['address1'];
      address2Controller.text = widget.availableAddress![0]['address2'];
      postcodeController.text = widget.availableAddress![0]['postcode'];
      cityController.text = widget.availableAddress![0]['city'];
      setState(() {
        _canSubmit = true;
      });
    }
  }

  // ignore: unused_element
  _assignCS() async {
    _csList = (await _fetchCS())!;
  }

  Future<void> _submitForm(BuildContext context) async {
    address.add({
      'location':
          (locationResult != null) ? locationResult!.name! : widget.location,
      'address1': address1Controller.text,
      'address2': address2Controller.text,
      'postcode': postcodeController.text,
      'city': cityController.text,
      'state': stateName,
      'state_code': _stateCode,
      'country': 'my',
      'latitude': latitude,
      'longitude': longitude,
    });
    if (address.isNotEmpty) {
      Navigator.of(context).pop(address);
    } else {
      Navigator.pop(context);
    }
  }
}
