// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'image_input_painter.dart';

/// @copyright Copyright (c) 2021
/// @author David Cheang <davidcheang83@gmail.com>
/// @version 1.0.1

// ignore: must_be_immutable
class ImageInput extends StatefulWidget {
  final String? label;
  final TextEditingController? controller;
  final double? prefixWidth;
  final bool? canEdit;
  final bool? canPaint;
  final bool? readOnly;
  bool? cameraOnly = false;
  int? imageQuality = 100;

  ImageInput(
      {Key? key,
      this.label,
      this.controller,
      this.prefixWidth,
      this.canEdit,
      this.canPaint,
      this.readOnly,
      this.imageQuality,
      this.cameraOnly})
      : super(key: key);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  final _imagePicker = ImagePicker();
  Uint8List? _imageData;

  @override
  Widget build(BuildContext context) {
    bool readOnly = widget.readOnly ?? false;
    double prefixWidth = widget.prefixWidth ?? 60;
    if ((_imageData == null) && widget.controller!.text.isNotEmpty) {
      _imageData = base64.decode(widget.controller!.text);
    }

    Widget previewWidget;
    if ((_imageData != null)) {
      previewWidget = Image.memory(_imageData!, fit: BoxFit.fitHeight);
    } else {
      previewWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        color: CupertinoColors.systemGrey6,
        child: const Icon(CupertinoIcons.photo,
            color: CupertinoColors.systemGrey, size: 120),
      );
    }

    Color buttonColor = (!readOnly)
        ? CupertinoTheme.of(context).primaryColor
        : CupertinoColors.systemGrey3;

    return Container(
      height: 140,
      padding: const EdgeInsets.only(left: 10),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: prefixWidth,
            padding: const EdgeInsets.only(top: 10),
            child: Text(widget.label!,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: (readOnly)
                    ? null
                    : () {
                        bool canPaint = widget.canPaint ?? true;
                        if (canPaint) _launchPainter();
                      },
                child: previewWidget,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: (readOnly)
                      ? null
                      : () => _imageFromSource(ImageSource.camera),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: buttonColor, width: 1.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(CupertinoIcons.camera),
                  ),
                ),
                (!widget.cameraOnly!)
                    ? CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: (readOnly)
                            ? null
                            : () => _imageFromSource(ImageSource.gallery),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: buttonColor, width: 1.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(CupertinoIcons.photo_on_rectangle),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _imageFromSource(ImageSource source) async {
    // ignore: deprecated_member_use
    final pickedFile = await _imagePicker.getImage(source: source, imageQuality: widget.imageQuality);
    if (pickedFile != null) {
      Uint8List imageData = await pickedFile.readAsBytes();
      bool canEdit = widget.canEdit ?? true;
      if (canEdit) {
    
        if (imageData != null) {
          _updatePreview(imageData);
        }
      } else {
        _updatePreview(imageData);
      }
    }
  }

  Future<void> _launchPainter() async {
    if (_imageData != null) {
      var imageData =
          await Navigator.push(context, CupertinoPageRoute(builder: (context) {
        return ImageInputPainter(imageData: _imageData);
      }));

      if (imageData != null) {
        _updatePreview(imageData);
      }
    }
  }

  void _updatePreview(Uint8List imageData) {
    widget.controller!.text = base64.encode(imageData);
    setState(() {
      _imageData = imageData;
    });
  }
}
