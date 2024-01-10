// ignore_for_file: unused_field, avoid_print, must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlabs/models/commerce/catalog.dart';
import 'package:tdlabs/models/country.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:tdlabs/screens/user/profile_form.dart';
import 'package:tdlabs/screens/wellness/wellness_type.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothDiscoveryScreen extends StatefulWidget {
  String? voucher_id;
  int? type;
    List<Map<String, dynamic>>? orderList;
  List<Map<String, dynamic>>? orderNameList;
  Catalog? product;
  List<dynamic>? voucherList;
  BluetoothDiscoveryScreen({Key? key, this.voucher_id,required this.type,
      this.orderList,
      this.orderNameList,
      this.product,
      this.voucherList}) : super(key: key);

  @override
  _BluetoothDiscoveryScreenState createState() => _BluetoothDiscoveryScreenState();
}

class _BluetoothDiscoveryScreenState extends State<BluetoothDiscoveryScreen> {

  StreamSubscription? scanSubscription;
  List<ScanResult> scanResults = [];
  bool isScanning = false;
  bool _isDiscovering = true;
  bool _isOn = true;
  User? user;
  String country_code = '';
  String voucher = '';
  @override
  void initState() {
    super.initState();
      if(widget.voucher_id != null){
    voucher = widget.voucher_id!;

    }
    _fetchUser();
  }

  Future<void> checkBluetoothPermissions() async {
    if (await Permission.bluetooth.isGranted) {
     
    } else {
      await Permission.bluetooth.request();
      if (await Permission.bluetooth.isGranted) {
        startScanning();
      } else {
        print('Bluetooth permission denied');
      }
    }
  }
  void listenToBluetoothState() {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        _isOn = true;
        // The Bluetooth adapter is on, safe to start scanning
        if (!isScanning) {
          startScanning();
        }
      } else {
        _isOn = false;
        // Handle other states accordingly (off, unauthorized, etc.)
      }
    });
  }
   void startScanning() async {
    // Listen to scan results
    scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isNotEmpty) {
        ScanResult r = results.last; // the most recently found device    
         if(widget.type == 0){
            if(r.advertisementData.advName.startsWith('BM-E') || r.advertisementData.advName.startsWith('BM-M')) {
              setState(() {
          scanResults.add(r);
                _isDiscovering = false; // Stop the loading indicator when done
          
        });
            }
          }else{
             if(r.advertisementData.advName.startsWith('BMS')) {
              setState(() {
                         scanResults.add(r);
                      _isDiscovering = false; // Stop the loading indicator when done
              });
       
            }
          }      
      }
    }, onError: (e) => print(e));
  Future.delayed(Duration(seconds: 10)).then((value){
    if(scanResults.isEmpty){
      setState(() {
      _isDiscovering = false; // Stop the loading indicator when done
    });
    }
  });
   scanSubscription!.onDone(() {
    setState(() {
      _isDiscovering = false; // Stop the loading indicator when done
    });
  });
    // Start scanning
    try {
      await FlutterBluePlus.startScan();
      
    } catch (e) {
      print('Error starting scan: $e');
    }
   
  }
  void stopScan() {
    scanSubscription?.cancel();
    isScanning = false;
  }

  @override
  void dispose() {
    stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            // Top container with gradient and back button
            Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(45.0),
                    bottomRight: Radius.circular(45.0),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 48, 186, 168),
                      Color.fromARGB(255, 49, 53, 131),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 8 / 100,
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: 75,
                        child: const Text(
                          "Wellness Chain Connect",
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ],
                  ),
                )),
                   if (_isOn == false)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth_disabled, size: 80),
                  SizedBox(height: 20),
                  Text('Bluetooth is TURNED OFF',
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text('Go to BLUETOOTH SETTINGS to enable Bluetooth',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
                ],
              ),
     if (!_isDiscovering && scanResults.isEmpty)
            Expanded(
              child: Center(
                child: Text('No devices found. Please try scanning again.'),
              ),
            ),
             if (_isDiscovering)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                     Text('Scanning Devices'),
                  ],
                ),
              ),
            ),
            if (_isOn == true && scanResults.isNotEmpty)
              // List of discovered devices
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemCount: scanResults.length,
                  itemBuilder: (context, index) {
                      final device = scanResults[index].device;
                      final deviceName = device.advName.isNotEmpty ? device.advName : '(unknown device)';
              
                      return  Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (device.advName != null) {
                      
                              var reportUrl =
                                  await _connectDevice2(device,scanResults[index]);
                              if (reportUrl != null) {}
                            } else {
                              Toast.show(
                                  context, "danger", "Device Not Compatible");
                            }
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: CupertinoColors.white,
                              border: Border(
                                bottom: BorderSide(
                                    color: CupertinoColors.systemGrey5,
                                    width: 1),
                              ),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(deviceName),
                                      Row(
                                        children: [
                                          device.isConnected
                                              ? const Icon(Icons.link, size: 16)
                                              : Container(),
                                          device.isConnected
                                              ? const Icon(Icons.bluetooth,
                                                  size: 16)
                                              : Container(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(device.remoteId.str),
                                      Text('${scanResults[index].rssi} dBm'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
   Future<String?> _connectDevice2(BluetoothDevice device,ScanResult scanResult) async {
     var no = (user!.phoneNo!.length > 11)
        ? user!.phoneNo!.substring(1)
        : user!.phoneNo!;
print("voucher"+voucher);
  var url = 'https://sg-openapi.qiaolz.com/server/user/sync';
    var appId = 'qlzc8f447a9ff9f96e1';
    var appSecret = 'ImKP8a7kRPlwRlMFZow09O26hfnph7Na';

    var nounce = DateTime.now().millisecondsSinceEpoch;
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var payload = appId + nounce.toString() + timestamp.toString() + appSecret;
    var signature = sha1.convert(utf8.encode(payload)).toString().toLowerCase();
   const platform = MethodChannel('com.tedainternational.tdlabs/scan');
  var deviceId = await platform.invokeMethod('getDeviceId');
  print('Device ID $deviceId');
    Map<String, String> headers = {
      'QLZ-App-Key': appId,
      'QLZ-Nonce': nounce.toString(),
      'QLZ-Timestamp': timestamp.toString(),
      'QLZ-Signature': signature,
      'Content-Type': 'application/json',
    };
    print( device.remoteId.str);
  Map<String, String> request = {
      'sdkId': deviceId,
      'deviceName': device.advName,
      'outUserid': user!.id.toString() + ",voucher_id=$voucher",
      'realname': user!.name!,
      'phone': no,
      'areaCode': getDialCode(user!.country!),
      'gender': (user!.gender == 0) ? "true" : "false",
    };

   
      var response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(request));
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('errcode') && (jsonResponse['errcode'] == 0)) {
          var sdkToken = jsonResponse['data']['token'];
        
          // Prepare the data to send with the 'connectDevice' method
          Map<String, dynamic> connectData = {
             'sdkKey': appId,
          'sdkToken': sdkToken,
          'deviceName': device.advName, // 'BM-M100663'
          'deviceMacAddress': scanResult.device.remoteId.toString(), // change to device
          };
Future.delayed(Duration(seconds: 1));
         Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return WellnessTypeScreen(
          orderList: widget.orderList,
          orderNameList: widget.orderNameList,
          product: widget.product,
          voucherList: widget.voucherList,
        );
      }));
          var result = await platform.invokeMethod('connectDevice', connectData);
           
          if (result != null) {
              Navigator.popUntil(context, (route) => route.isFirst);
            Map<String, dynamic> jsonResult = jsonDecode(result);
             
            print('RESULT DATA');
            print(jsonResult['recordid']);
            print(jsonResult['url']);

            // TODO: Temporary copy URL to clipboard
            await Clipboard.setData(ClipboardData(text: jsonResult['url']));

            return jsonResult['url'];
          }
        }
      }
  

    return null;
  }
   Future<void> _fetchUser() async {
 
    user = await User.fetchOne(context); // get current user
  if (user!.gender != null &&
          user!.phoneNo!.length >= 9 &&
          user!.country != null) {
       listenToBluetoothState();
      } else {
        showAlertDialog(context);
      }
  }
    String getDialCode(String code) {
    for (var country in Countries.allCountries) {
      String dialCode = country["code"]!.toLowerCase();
      if (code.contains(dialCode)) {
        country_code = country['dial_code']!;
        if (country_code.startsWith("+")) {
          country_code =
              country_code.substring(1); // Remove the '+' at the beginning
        }
      }
    }
    return country_code;
  }
   showAlertDialog(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = CupertinoButton(
      onPressed: () {},
      child: Container(),
    );
    // ignore: deprecated_member_use
    Widget continueButton = CupertinoButton(
      child: Text(
        'Continue'.tr,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return const ProfileFormScreen();
        }));
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        'Profile Update Needed'.tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
      content: Text(
        'Please complete your profile to proceed'.tr,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
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
