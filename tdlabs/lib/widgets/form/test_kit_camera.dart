import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

// ignore: must_be_immutable
class TestKitCamera extends StatefulWidget {
  int? optTestId;
  TestKitCamera({Key? key, this.optTestId}) : super(key: key);
  @override
  _TestKitCameraState createState() => _TestKitCameraState();
}

class _TestKitCameraState extends State<TestKitCamera> {
  List<CameraDescription>? _cameras;
  CameraController? _controller;

  Size? _previewSize;
  late double _horizontalPadding;
  late double _verticalPadding;

  bool torchLight = false;

  String? image = '';

  @override
  void initState() {
    super.initState();
    changeSampleImage();
    _initCamera();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras![0], ResolutionPreset.high,
        enableAudio: false);
    _controller!.initialize().then((_) {
      //_controller.setFlashMode(FlashMode.torch);
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if ((_controller == null) || (!_controller!.value.isInitialized)) {
      return Container();
    }

    return CupertinoPageScaffold(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 90 / 100,
              child: Stack(
                children: [
                  CameraPreview(_controller!),
                  Positioned.fill(
                    child: _cameraOverlay(
                        padding: 80,
                        aspectRatio: 0.4,
                        color: const Color(0x88000000)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 5, right: 150),
                          child: const Icon(CupertinoIcons.clear,
                              color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          _captureImage();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 3),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 4),
                            ),
                            child: Container(
                              height: 100,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              torchLight = !torchLight;
                            });
                          }
                          if (torchLight) {
                            _controller!.setFlashMode(FlashMode.torch);
                          } else {
                            _controller!.setFlashMode(FlashMode.off);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 5, left: 150),
                          child: Icon(
                              (torchLight)
                                  ? CupertinoIcons.lightbulb
                                  : CupertinoIcons.lightbulb_fill,
                              color: Colors.white,
                              size: 28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  changeSampleImage() {
    if (widget.optTestId == 6) {
      image = 'images/raycus_testkit.jpeg';
    } else {
      image = 'images/self-test-kit-sample.png';
    }
  }

//might need fix
  Future<void> _captureImage() async {
    if (_controller!.value.isInitialized) {
      final xFile = await _controller!.takePicture();
      Uint8List imageData = await File(xFile.path).readAsBytes();
      final decodedImage = img.bakeOrientation(img.decodeImage(imageData)!);
      //final decodedImage = img.decodeImage(imageData);

      _horizontalPadding *= (decodedImage.width / _previewSize!.width);
      _verticalPadding *= (decodedImage.height / _previewSize!.height);


      Navigator.pop(context, Uint8List.fromList(imageData));
    }
  }

  Widget _cameraOverlay({double? padding, double? aspectRatio, Color? color}) {
    return LayoutBuilder(builder: (context, constraints) {
      double parentAspectRatio = constraints.maxWidth / constraints.maxHeight;
      double horizontalPadding;
      double verticalPadding;

      if (parentAspectRatio < aspectRatio!) {
        horizontalPadding = padding!.ceilToDouble();
        verticalPadding = (constraints.maxHeight -
                ((constraints.maxWidth - (2 * padding)) / aspectRatio)) /
            2;
      } else {
        verticalPadding = padding!.ceilToDouble();
        horizontalPadding = (constraints.maxWidth -
                ((constraints.maxHeight - (2 * padding)) * aspectRatio)) /
            2;
      }

      _previewSize = Size(constraints.maxWidth, constraints.maxHeight);
      _horizontalPadding = horizontalPadding;
      _verticalPadding = verticalPadding;

      return Stack(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Container(width: horizontalPadding, color: color)),
          Align(
              alignment: Alignment.centerRight,
              child: Container(width: horizontalPadding, color: color)),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(
                  left: horizontalPadding, right: horizontalPadding),
              height: verticalPadding,
              color: color,
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(
                    left: horizontalPadding, right: horizontalPadding),
                height: verticalPadding,
                color: color,
              )),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: verticalPadding),
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00FF00), width: 2)),
          ),
        ],
      );
    });
  }
}
