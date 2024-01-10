// ignore_for_file: must_be_immutable, unnecessary_null_comparison

import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:tdlabs/utils/toast.dart';

class Lalamove extends StatefulWidget {
  TextEditingController locationController;
  TextEditingController address1Controller;
  TextEditingController address2Controller;
  TextEditingController postcodeController;
  TextEditingController cityController;

  GooglePlace googlePlace;
  Lalamove({
    Key? key,
    required this.locationController,
    required this.address1Controller,
    required this.address2Controller,
    required this.postcodeController,
    required this.cityController,
    required this.googlePlace,
  }) : super(key: key);

  @override
  State<Lalamove> createState() => _LalamoveState();
}

class _LalamoveState extends State<Lalamove> {
  Timer? _debounce;
  LatLon? latlong;
  List<AutocompletePrediction> predictions = [];
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo? androidInfo;
  DetailsResult? locationResult;
  bool loading = false;
  double lat = 0;
  double lng = 0;
  final Set<Marker> _markers = <Marker>{};
  final Completer<GoogleMapController> _controller = Completer();
  String stateName = "";
  String countryName = "";
  Map<String, dynamic> result = {
    "name": "",
    "address1": "",
    "address2": "",
    "city": "",
    "postcode": "",
    "state": "",
    "longitude": "",
    "latitide": "",
  };
  bool current = false;
  @override
  void initState() {
    _getLocation();

    super.initState();
  }

  Future<void> _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    lat = position.latitude;
    lng = position.longitude;
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    loading = false;
    if (!_controller.isCompleted) _controller.complete(controller);
  }

  Future<void> _autoFill(double lat, double lng) async {
    try {
      // Use geocoding to get the address components
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng,
          localeIdentifier:
              (locationResult != null) ? locationResult!.name : "");

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        widget.address1Controller.text = (current == false)
            ? (placemark.subThoroughfare != '')
                ? placemark.subThoroughfare!
                : (placemark.street != "")
                    ? placemark.street!
                    : (placemark.name != "")
                        ? placemark.name!
                        : ''
            : '';
        widget.address2Controller.text = (placemark.thoroughfare!.isNotEmpty)
            ? placemark.thoroughfare!
            : (placemark.subLocality!.isNotEmpty)
                ? placemark.subLocality!
                : "";
        widget.cityController.text = placemark.locality ?? '';
        stateName = placemark.administrativeArea ?? '';
        widget.postcodeController.text = placemark.postalCode ?? '';
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error getting address components: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/Background-01.png"),
              fit: BoxFit.fill),
        ),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(
         
        ),
        child: Stack(
          children: [
            if (loading == true)
              Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            if (_markers.isEmpty && predictions.isEmpty)
              Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.only(top: 65),
                child: Material(
                    child: ListView.builder(
                        padding: const EdgeInsets.only(top: 10),
                        shrinkWrap: true,
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.my_location,
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                ),
                                title: const Text(
                                  "Current Location",
                                ),
                                onTap: () async {
                                  setState(() {
                                    current = true;
                                     _autoFill(lat, lng);
                                    widget.locationController.text =widget.address1Controller.text;
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    _markers.add(
                                      Marker(
                                        flat: false,
                                        markerId: const MarkerId("Location"),
                                        position: LatLng(
                                            double.parse(lat.toString()),
                                            double.parse(lng.toString())),
                                        infoWindow: InfoWindow(
                                            title: "Current Location",
                                            onTap: () {}),
                                        icon: BitmapDescriptor.defaultMarker,
                                      ),
                                    );
                                   
                                  });
                                },
                              ),
                              const Divider(),
                            ],
                          );
                        })),
              ),
            if (predictions.isNotEmpty)
              Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.only(top: 65),
                child: Material(
                    child: ListView.builder(
                        padding: const EdgeInsets.only(top: 10),
                        shrinkWrap: true,
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          if (predictions.isEmpty) {
                            return Container();
                          } else {
                            return ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text(
                                predictions[index].description.toString(),
                              ),
                              onTap: () async {
                                final placeId = predictions[index].placeId!;
                                final details = await widget.googlePlace.details
                                    .get(placeId);
                                if (details != null &&
                                    details.result != null &&
                                    mounted) {
                                  setState(() {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    loading = true;
                                    locationResult = details.result;
                                    widget.locationController.text =
                                        details.result!.name!;
                                    _markers.add(
                                      Marker(
                                        flat: false,
                                        markerId: const MarkerId("Location"),
                                        position: LatLng(
                                            double.parse(locationResult!
                                                .geometry!.location!.lat
                                                .toString()),
                                            double.parse(locationResult!
                                                .geometry!.location!.lng
                                                .toString())),
                                        infoWindow: InfoWindow(
                                            title: "Location", onTap: () {}),
                                        icon: BitmapDescriptor.defaultMarker,
                                      ),
                                    );
                                    predictions.clear();
                                    _autoFill(
                                        locationResult!
                                            .geometry!.location!.lat!,
                                        locationResult!
                                            .geometry!.location!.lng!);
                                  });
                                }
                              },
                            );
                          }
                        })),
              ),
            if (_markers.isNotEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Flexible(
                      child: (current == false)
                          ? GoogleMap(
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              mapType: MapType.normal,
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                      double.parse(locationResult!
                                          .geometry!.location!.lat
                                          .toString()),
                                      double.parse(locationResult!
                                          .geometry!.location!.lng
                                          .toString())),
                                  zoom: 16),
                              markers: _markers,
                            )
                          : GoogleMap(
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              mapType: MapType.normal,
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(double.parse(lat.toString()),
                                      double.parse(lng.toString())),
                                  zoom: 16),
                              markers: _markers,
                            ),
                    ),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Address Details'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 35 / 100,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 45,
                                    child: CupertinoTextField(
                                      placeholder: 'Street 1'.tr,
                                      controller: widget.address1Controller,
                                      placeholderStyle: const TextStyle(
                                          fontWeight: FontWeight.w400),
                                      maxLength: 255,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 45,
                                    child: CupertinoTextField(
                                      placeholder: 'Street 2'.tr,
                                      controller: widget.address2Controller,
                                      placeholderStyle: const TextStyle(
                                          fontWeight: FontWeight.w400),
                                      maxLength: 255,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 45,
                                    child: CupertinoTextField(
                                      placeholder: 'Postcode'.tr,
                                      controller: widget.postcodeController,
                                      placeholderStyle: const TextStyle(
                                          fontWeight: FontWeight.w400),
                                      maxLength: 255,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 45,
                                    child: CupertinoTextField(
                                      placeholder: 'City'.tr,
                                      controller: widget.cityController,
                                      placeholderStyle: const TextStyle(
                                          fontWeight: FontWeight.w400),
                                      maxLength: 255,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: CupertinoButton(
                              color: CupertinoTheme.of(context).primaryColor,
                              disabledColor: CupertinoColors.inactiveGray,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (widget.address1Controller.text != "" || widget.address2Controller.text != "") {
                                  setState(() {
                                    result['name'] = (locationResult != null)
                                        ? locationResult!.name
                                        : widget.address1Controller.text;
                                    result['address1'] =
                                        widget.address1Controller.text;
                                    result['address2'] =
                                        widget.address1Controller.text;
                                    result['city'] = widget.cityController.text;
                                    result['postcode'] =
                                        widget.postcodeController.text;
                                    result['state'] = stateName;
                                    result['longitude'] =
                                        (locationResult != null)
                                            ? locationResult!
                                                .geometry!.location!.lng
                                            : lng;
                                    result['latitude'] =
                                        (locationResult != null)
                                            ? locationResult!
                                                .geometry!.location!.lat
                                            : lat;
                                  });
                                  Navigator.pop(context, result);
                                  setState(() {
                                    widget.locationController.clear();
                                  });
                                } else {
                                  Toast.show(context, "danger", 'Please fill in address details');
                                }
                              },
                              child: Text('Confirm'.tr,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                height: 60,
                width: 350,
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.chevron_left,
                              size: 30,
                            )),
                        Flexible(
                          child: TextField(
                            controller: widget.locationController,
                            autofocus: false,
                            style: const TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
                            decoration: InputDecoration(
                                suffixIcon: (widget.locationController.text !=null)
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            widget.locationController.clear();
                                            predictions.clear();
                                            locationResult = null;
                                            _markers.clear();
                                            loading = true;
                                            Future.delayed(const Duration(seconds: 3))
                                                .then((value) =>
                                                    {loading = false});
                                          });
                                        },
                                        child: Icon(
                                          CupertinoIcons.clear_circled_solid,
                                          color: CupertinoTheme.of(context)
                                              .primaryColor,
                                        ))
                                    : Container(),
                                icon: const Icon(Icons.location_pin),
                                filled: false,
                                hintText: 'Where to...',
                                alignLabelWithHint: true,
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 16),
                                border: InputBorder.none),
                            onChanged: (value) {
                              if (_debounce?.isActive ?? false) {
                                _debounce!.cancel();
                              }
                              _debounce =
                                  Timer(const Duration(microseconds: 100), () {
                                if (value.isNotEmpty) {
                                  //places api
                                  autoCompleteSearch(value);
                                } else {
                                  //clear out the results
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void autoCompleteSearch(String value) async {
    var loc = LatLon(lat, lng);
    var result = await widget.googlePlace.autocomplete
        .get(value, region: "my", location: loc);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }
}
