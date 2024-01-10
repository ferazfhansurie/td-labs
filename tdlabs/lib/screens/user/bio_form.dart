// ignore_for_file: unused_field, unnecessary_null_comparison, non_constant_identifier_names, unrelated_type_equality_checks

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_place/google_place.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/util/country_state.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/form/text_input.dart';
import 'dart:convert';
import 'package:get/get.dart';
import '../../models/health/biodata.dart';
import '../../utils/toast.dart';

// ignore: must_be_immutable
class BioForm extends StatefulWidget {
  List<Map<String, dynamic>>? availableAddress;
  String? delivery;
  String? location;

  BioForm({Key? key, this.availableAddress, this.delivery, this.location})
      : super(key: key);
  @override
  _BioFormState createState() => _BioFormState();
}

class _BioFormState extends State<BioForm> {
  final _formKey = GlobalKey<FormState>();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final bmiController = TextEditingController();
  final caloriesburnedController = TextEditingController();
  final stepsController = TextEditingController();
  final heartrateController = TextEditingController();
  final Controller = TextEditingController();
  int? _userId;
  final bool _canSubmit = false;
  bool _isLoadingCS = false;
  List<CountryState> _csList = [];

  int state = 0;
  String? stateName;
  int? stateIndex;
  int country = 0;
  final List<String> _listCountry = ['Malaysia'];
  final List<String> _listCountryCode = ['my'];
  String? countryName;
  String? countryCode;
  final int _pickerIndex = 0;
  final String _stateCode = '';
  List<Map<String, dynamic>> address = [];
  String? street;
  bool isAvailable = false;
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;
  DetailsResult? locationResult;
  final _locationController = TextEditingController();
  String bioHeightName = '';

  LatLon? latlong;
  String latitude = "";
  String longitude = "";
  String bmiCategory = "";
  double bmi = 0;
  @override
  void initState() {
    super.initState();
    countryName = _listCountry[country];
    String apiKey = MainConfig.googleMapApi;
    googlePlace = GooglePlace(apiKey);
    if (widget.location != null) {
      _locationController.text = widget.location!;
    }
    fetchBio(context);
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete
        .get(value, region: "my", location: latlong);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  void calculateBMI() {
    double? height = double.tryParse(heightController.text);
    double? weight = double.tryParse(weightController.text);

    if (height != null && weight != null) {
      bmi = weight / ((height / 100) * (height / 100));
      setState(() {
        bmiController.text = bmi.toString();
        bmiCategory = getBMICategory(bmi);
      });
    }
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return 'Normal weight';
    } else if (bmi >= 24.9 && bmi < 29.9) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: Colors.white,
              leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop([]);
                },
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 25,
                  color: Colors.black,
                ),
              ),
              middle: Text('Bio Data'.tr,
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
    );
  }

  Widget _addressForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  TextInput(
                    label: 'Height (cm)'.tr,
                    controller: heightController,
                    prefixWidth: 150,
                    maxLength: 3,
                      type: 'phoneNo',
                    required: true,
                  ),
                  TextInput(
                    label: 'Weight (kg)'.tr,
                    controller: weightController,
                    prefixWidth: 150,
                    maxLength: 3,
                    type: 'phoneNo',
                    required: true,
                  ),

                ],
              ),
              const Divider(),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          const Text(
                            "BMI",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              color: Color.fromARGB(255, 104, 104, 104),
                            ),
                          ),
                          Text(bmi.toStringAsFixed(1))
                        ],
                      ),
                      const SizedBox(height: 16.0),
                    
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Underweight'),
                          Text('Normal weight'),
                          Text('Overweight'),
                          Text('Obese'),
                        ],
                      ),
                         const SizedBox(height: 16.0),
                      Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Container(
                                  height: 35,
                                  width: MediaQuery.of(context).size.width * 10/ 100,
                                  color: Colors.red,
                                ),
                                Container(
                                  height: 35,
                                   width: MediaQuery.of(context).size.width * 12/ 100,
                                  color: Colors.orange,
                                ),
                                Container(
                                  height: 35,
                                  width: MediaQuery.of(context).size.width * 30/ 100,
                                  color: Colors.green,
                                ),
                                Container(
                                  height: 35,
                                  width: MediaQuery.of(context).size.width * 24/ 100,
                                  color: Colors.orange,
                                ),
                                Container(
                                  height: 35,
                                  width: MediaQuery.of(context).size.width * 11/ 100,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                            Positioned(
                              left: (bmi <16)? 0:(bmi >=16 && bmi < 18.5)?40:(bmi >=18.5 && bmi < 25)?120:(bmi >=25 && bmi < 30)?220:285,
                              top:8,
                              child: const Icon(
                                Icons.arrow_downward,
                                color: Colors.black,
                                size: 25,
                              ),
                            ),
                        
                        ],
                      ),
                     
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(10),
      
                child: SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: Visibility(
                    visible: (heightController.text != '' &&
                        weightController.text != '' &&
                        bmiController.text != '' &&
                        stepsController != null &&
                        caloriesburnedController != ''),
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
                        BioData.create(
                            context,
                            BioData(
                              height: heightController.text,
                              weight: weightController.text,
                              bmi: bmiController.text,
                              steps: int.parse(stepsController.text),
                              calories: caloriesburnedController.text,
                              heartrate: int.parse(heartrateController.text),
                            ));
                          calculateBMI();
                        Toast.show(context, "success", "Bio Data Saved");
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

  // ignore: unused_element
  _assignCS() async {
    _csList = (await _fetchCS())!;
  }

  Future<BioData?> fetchBio(BuildContext context) async {
    final webService = WebService(context);
    BioData? bioData;
    var response =
        await webService.setEndpoint('identity/user-biodatas/get').send();
    if (response == null) return null;
    if (response.status) {
      BioData bioData = BioData.fromJson(jsonDecode(response.body.toString()));
      if (bioData != null) {
        if(bioData.height != "0.00" ||bioData.weight != "0.00")
        {
                    heightController.text = bioData.height!;
        weightController.text = bioData.weight!;
        }else{
                  heightController.text = "";
        weightController.text = "";
        }

        bmiController.text = bioData.bmi!;
        stepsController.text = bioData.steps.toString();
        caloriesburnedController.text = bioData.calories!;
        heartrateController.text = bioData.heartrate.toString();
        calculateBMI();
      }
    }

    return bioData;
  }
}
