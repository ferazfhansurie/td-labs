// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart' as map;
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:tdlabs/models/poc/poc.dart';
import 'package:tdlabs/models/poc/poc_directory.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'dart:ui' as ui;
import 'package:tdlabs/screens/catalog/vm_screen.dart';
import 'package:tdlabs/screens/medical/ebook/ebook_form.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class GoogleMapsWidget extends StatefulWidget {
  final String? name;
  final String? latitude;
  final String? longitude;
  List<VendingMachine>? vm;
  List<PocDirectory>? clinic;
  String? categoryName;
  Function(PocDirectory directory, String stateName, String category)?
      showAdditional;
  GoogleMapsWidget(
      {Key? key,
      this.name,
      this.latitude,
      this.longitude,
      this.vm,
      this.clinic,
      this.showAdditional,
      this.categoryName})
      : super(key: key);
  @override
  _GoogleMapsWidgetState createState() => _GoogleMapsWidgetState();
}

class _GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  final Set<Marker> _markers = <Marker>{};
  double? latitudeCaptured;
  double? longitudeCaptured;
  double? latitudeStored;
  double? longitudeStored;
  final List<Poc> _list = [];
  final Completer<GoogleMapController> _controller = Completer();
  Future? future;
  final List<String> _urlList = [];
  List<LatLng> polylineCoordinates = [];
  List<map.AvailableMap> availableMaps = [];
  bool isLoading = false;
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
    'my-14': 'Kuala Lumpur',
    'my-15': 'Labuan',
    'my-16': 'Putrajaya',
  };
  @override
  void initState() {
    super.initState();
    _getPermission();
    future = _getLocation();
    _showMap();
  }

  @override
  void dispose() {
    super.dispose();
    _urlList.clear();
  }

  _getPermission() {
    Permission.locationWhenInUse.request();
  }

  Future<void> _showMap() async {
    availableMaps = await map.MapLauncher.installedMaps;
    // [AvailableMap { mapName: Google Maps, mapType: google }, ...]
  }

  Future<Uint8List> loadNetworkImage(path) async {
    final completed = Completer<ImageInfo>();
    var image = NetworkImage(path);
    image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completed.complete(info)));
    final imageInfo = await completed.future;
    final byteData =
        await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _getLocation() async {
    Future.delayed(const Duration(seconds: 0), () {
      if (mounted) {
        setState(() {
          latitudeStored = double.parse(widget.latitude!);
          longitudeStored = double.parse(widget.longitude!);
        });
      }
      if (mounted) {
        setState(() {
          latitudeCaptured = (widget.latitude!.isNotEmpty)
              ? double.parse(widget.latitude!)
              : null;
          longitudeCaptured = (widget.longitude!.isNotEmpty)
              ? double.parse(widget.longitude!)
              : null;
          isLoading = true;
        });
      }
    });
    if (widget.vm != null) {
      for (int i = 0; i < widget.vm!.length; i++) {
        _urlList.add(widget.vm![i].vm_image_url!);
        Uint8List image = await loadNetworkImage(_urlList[i]);
        final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
            image.buffer.asUint8List(),
            targetHeight: 100,
            targetWidth: 100);
        final ui.FrameInfo frameInfo = await markerImageCodec.getNextFrame();
        final ByteData? byteData =
            await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
        final Uint8List resizedImageMarker = byteData!.buffer.asUint8List();
        _markers.add(
          Marker(
            flat: false,
            markerId: MarkerId("$i"),
            position: LatLng(double.parse(widget.vm![i].latitude!),
                double.parse(widget.vm![i].longitude!)),
            infoWindow: InfoWindow(
                title: widget.vm![i].vm_name!,
                snippet: widget.vm![i].vm_code,
                onTap: () {
                  Navigator.of(context)
                      .push(CupertinoPageRoute(builder: (context) {
                    return VmScreen(
                      vm: widget.vm![i],
                    );
                  }));
                }),
            icon: BitmapDescriptor.fromBytes(resizedImageMarker),
          ),
        );
        if (_markers.isNotEmpty) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      }
    } else if (widget.clinic != null) {
      for (int i = 0; i < widget.clinic!.length; i++) {
        _urlList.add(widget.clinic![i].image_url!);
        Uint8List image = await loadNetworkImage(_urlList[i]);
        final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
            image.buffer.asUint8List(),
            targetHeight: 100,
            targetWidth: 100);
        final ui.FrameInfo frameInfo = await markerImageCodec.getNextFrame();
        final ByteData? byteData =
            await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
        final Uint8List resizedImageMarker = byteData!.buffer.asUint8List();
        _markers.add(
          Marker(
            flat: false,
            markerId: MarkerId("$i"),
            position: LatLng(double.parse(widget.clinic![i].latitude),
                double.parse(widget.clinic![i].longitude)),
            infoWindow: InfoWindow(
                title: widget.clinic![i].name,
                onTap: () {
                  String stateName =
                      (stateList[widget.clinic![i].state_code] != null)
                          ? stateList[widget.clinic![i].state_code]!
                          : "";
                  _showAdditional(widget.clinic![i], stateName, widget.categoryName!);
                }),
            icon: BitmapDescriptor.fromBytes(resizedImageMarker),
          ),
        );
        if (_markers.isNotEmpty) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 60 / 100,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: (isLoading == false)
                ? FutureBuilder(
                    future: future,
                    builder: (context, snapshot) {
                      if (latitudeStored != null && longitudeStored != null ||
                          latitudeCaptured != null &&
                              longitudeCaptured != null) {
                        return GoogleMap(
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          mapType: MapType.normal,
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                              target: LatLng(
                                  (latitudeCaptured == null)
                                      ? latitudeStored!
                                      : latitudeCaptured!,
                                  (longitudeCaptured == null)
                                      ? longitudeStored!
                                      : longitudeCaptured!),
                              zoom: (widget.vm == null) ? 10 : 12),
                          markers: _markers,
                        );
                      }
                      return const LinearProgressIndicator();
                    })
                : Column(
                    children: const [
                      Text("Fetching"),
                      LinearProgressIndicator(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  _showAdditional(PocDirectory directory, String stateName, String category) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        List<String> numbers = [];
        if (directory.other_phone_no != null) {
          var number = directory.other_phone_no!.replaceAll(
            '[',
            '',
          );
          number = number.replaceAll(
            '"',
            "",
          );
          number = number.replaceAll(
            ']',
            "",
          );
          numbers = number.split(',');
        }
        return Container(
          color: const Color.fromARGB(255, 245, 245, 245),
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 175,
                        child: (directory.image_url == null)
                            ? const Icon(
                                Icons.local_hospital,
                                size: 100,
                              )
                            : FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: directory.image_url!,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 5),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(4),
                            alignment: Alignment.topLeft,
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 25,
                              color: CupertinoTheme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10),
                                    width: MediaQuery.of(context).size.width *90 /100,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      directory.name,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB( 255, 24, 112, 141)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          
                          ],
                        ),
                        const Divider(
                          height: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Container(
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *30 /100,
                                  child: Text(
                                    'Address: '.tr,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 24, 112, 141)),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 15),
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width *60 /100,
                                    child: SelectableText(
                                        (directory.address != null)
                                            ? directory.unit_no! +
                                                ", " +
                                                directory.street_1 +
                                                ", " +
                                                directory.street_2! +
                                                ", " +
                                                directory.city +
                                                ", " +
                                                directory.postcode +
                                                ", " +
                                                stateName
                                            : "",
                                        maxLines: 5,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(255, 104, 104, 104),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(
                          height: 1,
                        ),
                        if (directory.description != "")
                          Container(
                            padding: const EdgeInsets.only(left: 15),
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *30 /100,
                                  child: Text(
                                    "Description: ".tr,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 24, 112, 141)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *40 /100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      directory.description!,
                                      maxLines: 5,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (directory.packages != null)
                    if (directory.packages != null)
                      Container(
                        height: 270,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                "Packages:",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  color:CupertinoTheme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Flexible(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: directory.packages!.length,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Container(
                                        color: Colors.white,
                                        width:MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        child: Column(
                                          mainAxisAlignment:MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment:CrossAxisAlignment.center,
                                              children: [
                                                Card(
                                                  child: SizedBox(
                                                    width: 65,
                                                    height: 65,
                                                    child: (directory.packages![index]['url'] == null)
                                                        ? const Icon(
                                                            Icons.local_hospital,
                                                            size: 25,
                                                          )
                                                        : FadeInImage.memoryNetwork(
                                                            placeholder:kTransparentImage,
                                                            image: directory.packages![index]['url'],
                                                          ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                                  child: Column(
                                                    mainAxisAlignment:MainAxisAlignment.start,
                                                    crossAxisAlignment:CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        width: 200,
                                                        alignment: Alignment.bottomLeft,
                                                        child: Text(
                                                          directory.packages![index]['name'],
                                                          maxLines: 4,
                                                          overflow: TextOverflow.ellipsis,
                                                          style:const TextStyle(
                                                            fontFamily:'Montserrat',
                                                            fontSize: 13,
                                                            fontWeight:FontWeight.w300,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    var list = await _fetchPackages(directory, index);
                                                    if (list!.isNotEmpty) {
                                                      Navigator.of(context).push(
                                                          CupertinoPageRoute(
                                                              builder:(context) {
                                                        return EbookFormScreen(
                                                          poc: list[0],
                                                          type: directory.packages![index]['name'].toString(),
                                                        );
                                                      }));
                                                    } else {}
                                                  },
                                                  child: const Card(
                                                    color: Color.fromARGB(255, 24, 112, 141),
                                                    child: Padding(
                                                      padding:EdgeInsets.all(8.0),
                                                      child: Text(
                                                        "Book",
                                                        style: TextStyle(
                                                            color:Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            const Divider(),
                                          ],
                                        ),
                                      ));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  if (directory.packages == null)
                    const SizedBox(
                      height: 185,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Directions".tr,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).padding.bottom),
                                  physics:const AlwaysScrollableScrollPhysics(),
                                  itemCount: availableMaps.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () async {
                                        await availableMaps[index].showMarker(
                                          coords: map.Coords(
                                              double.parse(directory.latitude),
                                              double.parse(directory.longitude)),
                                          title: directory.name,
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          Card(
                                            elevation: 5,
                                            child: SvgPicture.asset(
                                              availableMaps[index].icon,
                                              height: 40.0,
                                              width: 40.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: [
                              Text(
                                "Contact".tr,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      var tel = directory.phone_no;
                                      _launchURL("tel:$tel");
                                    },
                                    child: const Card(
                                      elevation: 5,
                                      child: Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Icon(
                                          Icons.phone,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (directory.other_phone_no!.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _showWhatsApp(context, numbers);
                                      },
                                      child: Card(
                                        elevation: 5,
                                        child: Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: SizedBox(
                                                height: 30,
                                                width: 30,
                                                child: Image.asset(
                                                  "assets/images/whatsapp.jpg",
                                                  fit: BoxFit.cover,
                                                ))),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
Future<List<Poc>?> _fetchPackages(PocDirectory directory, int index) async {
    final webService = WebService(context);
    _list.clear();
    isLoading = true;
    var id = directory.poc_id;
     final GlobalKey progressDialogKey = GlobalKey<State>();
    webService.setEndpoint('screening/pocs/$id');
    Map<String, String> filter = {};
    filter.addAll({'test_type': directory.packages![index]['value'].toString()});
    filter.addAll({'mode': '0'});
    ProgressDialog.show(context, progressDialogKey);
    var response = await webService.setFilter(filter).send();
    ProgressDialog.hide(progressDialogKey);
    if (response == null) return null;
    if (response.status) {
      Poc poc = Poc.fromJson(jsonDecode(response.body.toString()));
      setState(() {
        _list.add(poc);
      });
    }
    isLoading = false;
    return _list;
  }


  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchWhatsapp(String number) async {
    String url = 'https://wa.me/$number?text=Helpdesk,New%20Message';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _showWhatsApp(BuildContext context, List<String> numbers) {
    Widget cancelButton = CupertinoButton(
      child: const Text(
        'Back',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Whatsapp",
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
      content: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: numbers.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: SelectableText(
                          numbers[index],
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            _launchWhatsapp(numbers[index]);
                          },
                          child: Image.asset("assets/images/whatsapp.jpg",
                              height: 30))
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        cancelButton,
      ],
    );
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(false), child: alert);
      },
    );
  }
}
