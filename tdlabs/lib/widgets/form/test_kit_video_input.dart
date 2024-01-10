// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/widgets/form/test_kit_video.dart';


// ignore: must_be_immutable
class TestKitVideoInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final double? prefixWidth;
  final bool readOnly;
  bool initPreview;
  TextEditingController locationController;
  TestKitVideoInput(
      {Key? key,
      required this.label,
      required this.controller,
      this.prefixWidth,
      required this.readOnly,
      this.initPreview = false,
      required this.locationController})
      : super(key: key);

  @override
  _TestKitVideoInputState createState() => _TestKitVideoInputState();
}

class _TestKitVideoInputState extends State<TestKitVideoInput> {
  Uint8List? _videoData;
  //String _videoLocation;

  Map<String, dynamic> videoInformation = {};

  // ignore: unused_field
  

  bool playPressed = false;
  bool showReplay = false;



  @override
  void initState() {
    //implement initState
    super.initState();
    if (widget.initPreview) _initPreview();
  }

  @override
  Widget build(BuildContext context) {
    bool _readOnly = widget.readOnly;
    double _prefixWidth = widget.prefixWidth ?? 60;
    if ((_videoData == null) && widget.controller.text.isNotEmpty) {
      _videoData = base64.decode(widget.controller.text);
    }

    Widget _previewWidget;
    if (showReplay) {
      _previewWidget = InkWell(
        onTap: () {
          playPressed = !playPressed;
          setState(() {
        
          });
        },
        child: Stack(
          children: [
         
            Positioned.fill(
                child: Opacity(
                    opacity: 0.5,
                    child: Center(
                        child: (!playPressed)
                            ? const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              )
                            : Container())))
          ],
        ),
      );
    } else {
      _previewWidget = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: CupertinoColors.systemGrey6,
          border: Border.all(color: Colors.white),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: const Icon(CupertinoIcons.video_camera_solid,
            color: CupertinoColors.systemGrey, size: 100),
      );
    }

    Color _buttonColor = (!_readOnly)
        ? CupertinoTheme.of(context).primaryColor
        : CupertinoColors.systemGrey3;

    return Container(
      height: 200,
      padding: const EdgeInsets.only(left: 10),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5),
        ),
      ),
      child: GestureDetector(
        onTap: (_readOnly)
            ? null
            : () async {
                videoInformation = await Navigator.push(context,
                    CupertinoPageRoute(builder: (context) {
                  return const TestKitVideo();
                }));

                if (videoInformation != null) {
                  _updatePreview(videoInformation['videoData'],
                      videoInformation['videoPath']);
                }
              },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: _prefixWidth,
              padding: const EdgeInsets.only(top: 10),
              child: Text(widget.label,
                  style: const TextStyle(fontWeight: FontWeight.w300)),
            ),
            Expanded(
              child: Center(
                child: Material(child: _previewWidget),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: (_readOnly)
                      ? null
                      : () async {
                          videoInformation = await Navigator.push(context,
                              CupertinoPageRoute(builder: (context) {
                            return const TestKitVideo();
                          }));

                          if (videoInformation != null) {
                            _updatePreview(videoInformation['videoData'],
                                videoInformation['videoPath']);
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: _buttonColor, width: 1.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(CupertinoIcons.video_camera),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePreview(Uint8List videoData, String videoLocation) async {
    widget.controller.text = base64.encode(videoData);
    widget.locationController.text = videoLocation;
    _videoData = videoData;
 

    showReplay = true;

    setState(() {});
  }

  _initPreview() async {

    showReplay = true;
    setState(() {});
  }
}
