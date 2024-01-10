// ignore_for_file: unused_local_variable, deprecated_member_use

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';

// ignore: must_be_immutable
class PDFView extends StatefulWidget {
  String pdfUrl;
  String? testId;
  bool isTest;
  String? receiptId;
  PDFView(
      {Key? key,
      required this.pdfUrl,
      this.testId,
      this.isTest = true,
      this.receiptId})
      : super(key: key);
  @override
  _PDFViewState createState() => _PDFViewState();
}

class _PDFViewState extends State<PDFView> {
  final GlobalKey<SfPdfViewerState> sfPDFViewerKey = GlobalKey();
  var dio = Dio();
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    permissionStorage();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: android,);
  }
  @override
  void dispose() {
    super.dispose();
  }
  permissionStorage() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    var status = await Permission.storage.status;
    if (status.isGranted) {
    } else {}
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Result'.tr),
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.only(right: 10),
                onPressed: () async {
                  String savePath = '';
                  var path =Theme.of(context).platform == TargetPlatform.android
                          ? await _findLocalPathAndroid()
                          : await _findLocalPathIOS();
                  if (widget.isTest) {
                    savePath = path + '/tdlabsresult' + widget.testId! + '.pdf';
                  } else {
                    savePath = path + '/tdlabsreceipt' + widget.receiptId! + '.pdf';
                  }
                  shareFile(dio, widget.pdfUrl, savePath);
                },
                child: const Text(
                  'Share',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  String savePath = '';
                  var path =Theme.of(context).platform == TargetPlatform.android
                          ? await _findLocalPathAndroid()
                          : await _findLocalPathIOS();
                  if (widget.isTest) {
                    savePath = path + '/tdlabsresult' + widget.testId! + '.pdf';
                  } else {
                    savePath = path + '/tdlabsreceipt' + widget.receiptId! + '.pdf';
                  }
                  download2(dio, widget.pdfUrl, savePath);
                },
                child: Text(
                  'Open'.tr,
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                      color: CupertinoTheme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 44),
          color: CupertinoColors.systemFill,
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: SfPdfViewer.network(
                widget.pdfUrl,
                key: sfPDFViewerKey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _findLocalPathAndroid() async {
    var directory = await getExternalStorageDirectories(type: StorageDirectory.downloads);
    var directoryPath = directory![0].path;
    return directoryPath;
  }

  Future<String> _findLocalPathIOS() async {
    var directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future download2(Dio dio, String pdfUrl, String savePath) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };
    try {
      Response response = await dio.get(
        pdfUrl,
        onReceiveProgress: showDownloadProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      File file = File(savePath);
      var a = file.openSync(mode: FileMode.write);
      a.writeFromSync(response.data);
      await a.close();
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (e) {
      result['error'] = e.toString();
    } finally {
      (Theme.of(context).platform == TargetPlatform.android)
          ? await _showNotification(result)
          : share(savePath);
    }
  }

  Future shareFile(Dio dio, String pdfUrl, String savePath) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };
    try {
      Response response = await dio.get(
        pdfUrl,
        onReceiveProgress: showDownloadProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );

      File file = File(savePath);
      var a = file.openSync(mode: FileMode.write);
      a.writeFromSync(response.data);
      await a.close();
      //Toast.show(context, 'success', 'Download Success');
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (e) {
      result['error'] = e.toString();
    } finally {
      share(savePath);
    }
  }

  void share(String savePath) async {
    File testFile = File(savePath);
    if (!await testFile.exists()) {
      await testFile.create(recursive: true);
      testFile.writeAsStringSync("test for share documents file");
    }
    Share.shareFiles([testFile.path]);
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {}
  }

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
    // ignore: prefer_const_constructors
    final android = AndroidNotificationDetails('channel id', 'channel name',priority: Priority.high, importance: Importance.max);

    final platform =NotificationDetails(android: android, );
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];
    await flutterLocalNotificationsPlugin!.show(
       0,
       isSuccess ? 'Success'  : 'Failure',
       isSuccess? 'File has been downloaded successfully.' : 'There was an error while downloading the file.',
        platform,
        payload: json);
  }
}
