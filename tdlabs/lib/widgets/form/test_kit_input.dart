// ignore_for_file: unused_field, unused_element

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tdlabs/widgets/form/test_kit_camera.dart';
import 'package:image/image.dart' as img;

// ignore: must_be_immutable
class TestKitInput extends StatefulWidget {
  final String? label;
  final TextEditingController? controller;
  final double? prefixWidth;
  final bool? readOnly;
  int? optTestId;

  TestKitInput(
      {Key? key,
      this.label,
      this.controller,
      this.prefixWidth,
      this.readOnly,
      this.optTestId})
      : super(key: key);

  @override
  _TestKitInputState createState() => _TestKitInputState();
}

class _TestKitInputState extends State<TestKitInput> {
  Uint8List? _imageData;
  double _horizontalPadding = 0.0;
  double _verticalPadding = 0.0;
  PickedFile? _imageFile;
  Size? _previewSize;
  final GlobalKey progressDialogKey = GlobalKey<State>();
  @override
  Widget build(BuildContext context) {
    double? _prefixWidth = widget.prefixWidth;
    if ((_imageData == null) && widget.controller!.text.isNotEmpty) {
      _imageData = base64.decode(widget.controller!.text);
    }

    Widget _previewWidget;
    if ((_imageData != null)) {
      _previewWidget = Container(
        color: const Color.fromARGB(255, 0, 57, 104),
        child: Image.memory(_imageData!, fit: BoxFit.contain),
      );
    } else {
      _previewWidget = Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: CupertinoColors.white,
        child: const Icon(CupertinoIcons.photo,
            color: Color.fromARGB(255, 0, 0, 0), size: 100),
      );
    }

    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width * 90 / 100,
      padding: const EdgeInsets.only(left: 10),
      child: GestureDetector(
      onTap: () async {
          var imageData = await Navigator.push(context,
              CupertinoPageRoute(builder: (context) {
            return TestKitCamera(
              optTestId: widget.optTestId,
            );
          }));
          if (imageData != null) {
            _updatePreview(imageData);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: _prefixWidth,
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                widget.label!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(
                child: _previewWidget,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePreview(Uint8List imageData) {
    widget.controller!.text = base64.encode(imageData);
    setState(() {
      _imageData = imageData;
    });
  }

  Future<img.Image> _captureImage() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.camera);

    Uint8List imageData = await File(xFile!.path).readAsBytes();

    final decodedImage = img.bakeOrientation(img.decodeImage(imageData)!);
    //final decodedImage = img.decodeImage(imageData);
    _previewSize = Size(double.parse(decodedImage.width.toString()),
        double.parse(decodedImage.height.toString()));
    _horizontalPadding *= (decodedImage.width / _previewSize!.width);
    _verticalPadding *= (decodedImage.height / _previewSize!.height);

    final croppedImage = decodedImage;
    return croppedImage;
  }
}
