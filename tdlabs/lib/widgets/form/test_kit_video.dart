// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:video_compress/video_compress.dart';

class TestKitVideo extends StatefulWidget {
  const TestKitVideo({Key? key}) : super(key: key);

  @override
  _TestKitVideoState createState() => _TestKitVideoState();
}

class _TestKitVideoState extends State<TestKitVideo>
    with SingleTickerProviderStateMixin {
  List<CameraDescription>? _cameras;
  late int selectedCameraIdx;
  CameraController? _controller;
  bool? torchLight = false;
  bool? recordButtonPressed = false;
  bool? isRearCamera = true;
  String image = '';
  String? videoPath;
  bool timerDone = false;
  Timer? timer;
  int startTimer = 0;
  bool showTimer = false;
  String timerDuration = '00 m 00';
  Map<String, dynamic> videoInformation = {};
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController!.repeat(reverse: true);
    _initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController!.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      setState(() {
        selectedCameraIdx = 0;
      });

      _onCameraSwitched(_cameras![selectedCameraIdx]).then((void v) {});
    }
  }

  void startTimerCountdown() {
    showTimer = true;
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (timer) {
      if (mounted) {
        setState(() {
          startTimer++;
          timerDuration = formatDuration(startTimer);
        });
        if (startTimer >= 10) {
          if (mounted) {
            setState(() {
              timerDone = true;
            });
          }
        }
      }
    });
  }

  String formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = totalSeconds % 60;
    final minutesString = '$minutes'.padLeft(2, '0');
    final secondsString = '$seconds'.padLeft(2, '0');
    return '$minutesString m $secondsString';
  }

  @override
  Widget build(BuildContext context) {
    if ((_controller == null) || (!_controller!.value.isInitialized)) {
      return Container();
    }

    return WillPopScope(
      onWillPop: () {
        _onStopButtonPressed();
        return Future.value(true);
      },
      child: CupertinoPageScaffold(
        child: Container(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 90 / 100,
                child: Stack(
                  children: [
                    CameraPreview(_controller!),
                    (recordButtonPressed!)
                        ? Container(
                            margin: const EdgeInsets.only(top: 50, left: 280),
                            child: FadeTransition(
                              opacity: _animationController!,
                              child: Column(
                                children: [
                                  const Text(
                                    'Rec',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    timerDuration,
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16),
                                  ),
                                  Container(
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    /**Positioned.fill(
                      child: Opacity(
                        opacity: 0.3,
                        child: Center(
                          child: Text(
                            startTimer.toString(),
                            style: TextStyle(
                                fontSize: 100,
                                fontWeight: FontWeight.w300,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),**/
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      (!recordButtonPressed!)
                          ? Center(
                              child: GestureDetector(
                                onTap: () {
                                  _onSwitchCamera();
                                  setState(() {
                                    isRearCamera = !isRearCamera!;
                                  });
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(top: 5, right: 250),
                                  child: Icon(
                                      (isRearCamera!)
                                          ? Icons.camera_rear
                                          : Icons.camera_front,
                                      color: Colors.white,
                                      size: 28),
                                ),
                              ),
                            )
                          : Container(),
                      (!recordButtonPressed!)
                          ? Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(top: 5, right: 150),
                                  child: const Icon(CupertinoIcons.clear,
                                      color: Colors.white, size: 28),
                                ),
                              ),
                            )
                          : Container(),
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            if (!recordButtonPressed!) {
                              _onRecordButtonPressed();
                              setState(() {
                                recordButtonPressed = !recordButtonPressed!;
                              });
                            } else {
                              if (timerDone) {
                                _onStopButtonPressed();
                                setState(() {
                                  recordButtonPressed = !recordButtonPressed!;
                                });
                              } else {
                                showAlertTimer(context);
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey, width: 5),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: (!recordButtonPressed!)
                                    ? Colors.white
                                    : Colors.red,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 3),
                              ),
                              child: SizedBox(
                                height: 100,
                                child: Icon(
                                  (!recordButtonPressed!)
                                      ? Icons.not_started
                                      : Icons.stop,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      (isRearCamera!)
                          ? Center(
                              child: GestureDetector(
                                onTap: () {
                                  if (mounted) {
                                    setState(() {
                                      torchLight = !torchLight!;
                                    });
                                  }
                                  if (torchLight!) {
                                    _controller!.setFlashMode(FlashMode.torch);
                                  } else {
                                    _controller!.setFlashMode(FlashMode.off);
                                  }
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(top: 5, left: 150),
                                  child: Icon(
                                      (torchLight!)
                                          ? CupertinoIcons.lightbulb
                                          : CupertinoIcons.lightbulb_fill,
                                      color: Colors.white,
                                      size: 28),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(cameraDescription, ResolutionPreset.medium,
        enableAudio: false);

    // If the controller is updated then update the UI.
    _controller!.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (_controller!.value.hasError) {
        Fluttertoast.showToast(
            msg: 'Camera error ${_controller!.value.errorDescription}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    });

    try {
      await _controller!.initialize();
    // ignore: empty_catches
    } on CameraException {}

    if (mounted) {
      setState(() {});
    }
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx < _cameras!.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = _cameras![selectedCameraIdx];

    _onCameraSwitched(selectedCamera);

    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
  }

  void _onRecordButtonPressed() {
    _startVideoRecording().then((bool? isRecorded) {
      if (isRecorded!) {
        Fluttertoast.showToast(
            msg: 'Recording video started',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.grey,
            textColor: Colors.white);
      }
    });
    startTimerCountdown();
  }

  Future<bool?> _startVideoRecording() async {
    if (!_controller!.value.isInitialized) {
      Fluttertoast.showToast(
          msg: 'Please wait',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white);

      return false;
    }

    // Do nothing if a recording is on progress
    if (_controller!.value.isRecordingVideo) {
      return null;
    }
    try {
      await _controller!.startVideoRecording();
    } on CameraException {
      return null;
    }

    return true;
  }

  // ignore: missing_return
  Future<void> _onStopButtonPressed() async {
    _stopVideoRecording();
  }

  showAlertTimer(BuildContext context) {
    // set up the AlertDialog
    Widget alert = Container(
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        children: [
          AlertDialog(
            title: Column(
              children: [
                Text(
                  'Please Record For 1 Minute to Proceed',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Please ensure that all steps are taken',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Montserrat',
                    color: Color.fromARGB(255, 104, 104, 104),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _stopVideoRecording() async {
    timer!.cancel();
    if (!_controller!.value.isRecordingVideo) {
      return;
    }

    XFile file = await _controller!.stopVideoRecording();
    setState(() {
      videoPath = file.path;
    });
    await VideoCompress.setLogLevel(0);
    final GlobalKey progressDialogKey = GlobalKey<State>();
    ProgressDialog().showProcess(context, progressDialogKey);
    final MediaInfo? info = await VideoCompress.compressVideo(
      videoPath!,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false,
      includeAudio: false,
    );
    setState(() {
      videoPath = info!.path!;
    });

    File videoFile = File(videoPath!);
    Uint8List videoData = await videoFile.readAsBytes();
    videoInformation.addAll({
      'videoData': videoData,
      'videoPath': videoPath,
    });
    ProgressDialog.hide(progressDialogKey);
    Navigator.pop(context, videoInformation);
  }
}
