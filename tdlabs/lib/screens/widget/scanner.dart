// ignore_for_file: prefer_final_fields, unnecessary_this, body_might_complete_normally_nullable, unnecessary_new

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/screening/self-test.dart';
import 'package:tdlabs/utils/toast.dart';
import 'dart:io';
import '../../utils/web_service.dart';
import 'dart:convert';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:async';

// ignore: must_be_immutable
class ScannerScreen extends StatefulWidget {
  int? optTestId;

  ScannerScreen({Key? key, this.optTestId}) : super(key: key);
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _scannerKey = GlobalKey<State>();
  QRViewController? _scannerController;
  SelfTest selfTest = SelfTest();
  bool isLoading = false;
  Map<String, dynamic> _qrCapture = {};

  void _onQRViewCreated(QRViewController controller) {
    _scannerController = controller;
    if (mounted) _scannerController?.resumeCamera();
    controller.scannedDataStream.listen((value) async {
      if (!isLoading) {
        isLoading = true;
        await _findQRCode(value.code);
        isLoading = false;
      }
      sleep(const Duration(microseconds: 500));
    });
  }

  Future<void> _findQRCode(var value) async {
    setState(() {
      _qrCapture.addAll({'qrcode': value});
    });
    _scannerController?.pauseCamera();
    bool? status = await findQRCode(context, value);
    if (status == true) {
      if (this.mounted) {
        Toast.show(context, 'Default', 'QR validation success');
        Navigator.pop(context, _qrCapture);
        _scannerController?.dispose();
        return;
      }
    } else {
      Toast.show(context, 'danger', 'QR invalid');
      Navigator.pop(context);
      _scannerController?.dispose();
      return;
    }
    if (mounted) _scannerController?.resumeCamera();
  }

  // ignore: missing_return
  Future<bool?> findQRCode(BuildContext context, var qrcode) async {
    final webService = new WebService(context);
    webService.setMethod('POST').setEndpoint('screening/self-tests/check-qr');
    Map<String, String> data = {};
    data.addAll({'code': qrcode});
    data.addAll({'brand': widget.optTestId.toString()});
    var response = await webService.setData(data).send();
    if (response == null) return null;
    if (response.status) {
      var qrCode = jsonDecode(response.body.toString());
      if (mounted) {
        setState(() {
          String? type = qrCode[0]['type'];
          _qrCapture.addAll({'type': type});
        });
      }
      return qrCode[0]['status'];
    }
  }

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text('Scan QR / Barcode'.tr,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
              fontSize: 20,
            )),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel'.tr,
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: CupertinoTheme.of(context).primaryColor,
                fontWeight: FontWeight.w300),
          ),
        ),
      ),
      child: _scanView(),
    );
  }

  Widget _scanView() {
    return Column(
      children: [
        Expanded(
          child: QRView(
            key: _scannerKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
                borderColor: Colors.green,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 280),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: CupertinoColors.systemGrey5),
              ),
              color: Colors.black),
          child: SizedBox(
            width: double.infinity,
            height: 36,
            child: CupertinoButton(
              color: CupertinoTheme.of(context).primaryColor,
              disabledColor: CupertinoColors.inactiveGray,
              padding: EdgeInsets.zero,
              onPressed: () {
                _scannerController?.toggleFlash();
              },
              child: Text('Flashlight'.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat', color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}
