// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../utils/progress_dialog.dart';

class ImageInputPainter extends StatefulWidget {
  final Uint8List? imageData;
  const ImageInputPainter({Key? key, this.imageData}) : super(key: key);

  @override
  _ImageInputPainterState createState() => _ImageInputPainterState();
}

class _ImageInputPainterState extends State<ImageInputPainter> {
  ui.Image? _backgroundImage;
  bool _isLoaded = false;
  DrawingPainter? _painter;
  final List<DrawingPoints> _drawingPoints = [];
  Color _pickerColor = Colors.black;
  final double _opacity = 1;
  final double _strokeWidth = 3;
  final StrokeCap _strokeCap = StrokeCap.round;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: CupertinoColors.systemFill,
            child: Column(
              children: [
                Container(
                  color: CupertinoColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: (_drawingPoints.isNotEmpty)
                                ? () => _clear()
                                : null,
                            child: const Text('Clear All'),
                          ),
                          Row(
                            children: [
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: (_drawingPoints.isNotEmpty)
                                    ? () => _undo()
                                    : null,
                                child: const Text('Undo'),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => _colorPicker(),
                                child: const Icon(
                                  CupertinoIcons.color_filter,
                                    size: 28),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: CupertinoColors.separator),
                _buildCanvas(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(CupertinoIcons.clear_thick_circled,
                        size: 70, color: CupertinoColors.destructiveRed),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    onPressed: () async {
                      Uint8List result = await _captureImage();
                      Navigator.pop(context, result);
                    },
                    child: const Icon(
                      CupertinoIcons.check_mark_circled_solid,
                        size: 70, 
                        color: CupertinoColors.activeGreen),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    if (_isLoaded) {
      _painter = DrawingPainter(
        backgroundImage: _backgroundImage!,
        drawingPoints: _drawingPoints,
      );
      // Ratio 1:1
      double canvasWidth = MediaQuery.of(context).size.width;
      double canvasHeight = canvasWidth;
      return GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox? renderBox = context.findRenderObject()! as RenderBox?;
            _drawingPoints.add(DrawingPoints(
                points: renderBox!.globalToLocal(details.localPosition),
                paint: Paint()
                  ..strokeCap = _strokeCap
                  ..isAntiAlias = true
                  ..color = _pickerColor.withOpacity(_opacity)
                  ..strokeWidth = _strokeWidth));
          });
        },
        onPanStart: (details) {
          setState(() {
            RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            _drawingPoints.add(DrawingPoints(
                points: renderBox!.globalToLocal(details.localPosition),
                paint: Paint()
                  ..strokeCap = _strokeCap
                  ..isAntiAlias = true
                  ..color = _pickerColor.withOpacity(_opacity)
                  ..strokeWidth = _strokeWidth));
          });
        },
        onPanEnd: (details) {
          setState(() {});
        },
        child: CustomPaint(
          size: Size(canvasWidth, canvasHeight),
          painter: _painter,
        ),
      );
    } else {
      return Container();
    }
  }

  Future _init() async {
    _backgroundImage = await _loadBackgroundImage(widget.imageData!);
  }

  Future<ui.Image> _loadBackgroundImage(Uint8List image) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(image, (ui.Image image) {
      setState(() {
        _isLoaded = true;
      });
      return completer.complete(image);
    });
    return completer.future;
  }

  Future<Uint8List> _captureImage() async {
    if (_painter != null) {
      final Size size = Size(_backgroundImage!.width.toDouble(),_backgroundImage!.width.toDouble());
      double scale = _backgroundImage!.width / context.size!.width;
      final GlobalKey progressDialogKey = GlobalKey<State>();
      ProgressDialog.show(context, progressDialogKey);
      final PictureRecorder recorder = PictureRecorder();
      _painter!.paint(Canvas(recorder), size, scale: scale);
      Picture picture = recorder.endRecording();
      ui.Image image = await picture.toImage(size.width.toInt(), size.height.toInt());
      var imageBytes = await image.toByteData(format: ui.ImageByteFormat.png);
       
      return imageBytes!.buffer.asUint8List();
    }
    return widget.imageData!;
  }

  void _clear() {
    setState(() {
      _drawingPoints.clear();
    });
  }

  void _undo() {
    int marker = 0;
    for (int i = _drawingPoints.length - 2; i > 0; i--) {
      if (_drawingPoints[i] == null) {
        marker = i;
        break;
      }
    }

    setState(() {
      if (marker == 0) {
        _drawingPoints.clear();
      } else {
        _drawingPoints.removeRange(marker, _drawingPoints.length - 1);
      }
    });
  }

  void _colorPicker() {
    showDialog(
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _pickerColor,
            onColorChanged: (color) {
              setState(() {
                _pickerColor = color;
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
      context: context,
    );
  }
}

/*----- DRAWING PAINTER -----*/
class DrawingPainter extends CustomPainter {
  List<DrawingPoints>? drawingPoints;
  List<Offset> offsetPoints = [];
  ui.Image? backgroundImage;
  DrawingPainter({this.backgroundImage, this.drawingPoints});
  @override
  void paint(Canvas canvas, Size size, {double scale = 1}) {
    double width = size.width;
    double height =
        (size.width * backgroundImage!.height) / backgroundImage!.width;
    final srcSize = Size(
        backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble());
    final dstSize = Size(width, height);
    final src = Offset.zero & srcSize;
    final dst = Offset.zero & dstSize;
    canvas.drawImageRect(backgroundImage!, src, dst, Paint());
    canvas.scale(scale);
    canvas.clipRect(Offset.zero & dstSize);
    for (int i = 0; i < drawingPoints!.length - 1; i++) {
      if (drawingPoints![i] != null) {
        canvas.drawLine(
        drawingPoints![i].points!,
        drawingPoints![i + 1].points!, 
        drawingPoints![i].paint!);
      } else if (drawingPoints![i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(drawingPoints![i].points!);
        offsetPoints.add(Offset(drawingPoints![i].points!.dx + 0.1,
        drawingPoints![i].points!.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, drawingPoints![i].paint!);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawingPoints {
  Paint? paint;
  Offset? points;
  DrawingPoints({this.points, this.paint});
}
