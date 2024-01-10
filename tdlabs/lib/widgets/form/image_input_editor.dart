// ignore_for_file: library_prefixes
/*
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as IMG;
import 'package:image_editor/image_editor.dart' hide ImageSource;
import 'package:extended_image/extended_image.dart';
import '../../utils/progress_dialog.dart';

class ImageInputEditor extends StatefulWidget {
  final Uint8List? imageData;
  const ImageInputEditor({Key? key, this.imageData}) : super(key: key);

  @override
  _ImageInputEditorState createState() => _ImageInputEditorState();
}

class _ImageInputEditorState extends State<ImageInputEditor> {
  final GlobalKey<ExtendedImageEditorState> _editorKey =
      GlobalKey<ExtendedImageEditorState>();

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
                            onPressed: () => _reset(),
                            child: const Text('Reset'),
                          ),
                          Row(
                            children: [
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => _flip(),
                                child: const Icon(Icons.flip, size: 28),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => _rotate(true),
                                child: const Icon(Icons.rotate_right, size: 28),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: CupertinoColors.separator),
                Expanded(
                  child: ExtendedImage.memory(
                    widget.imageData!,
                    extendedImageEditorKey: _editorKey,
                    mode: ExtendedImageMode.editor,
                    fit: BoxFit.contain,
                    initEditorConfigHandler: (ExtendedImageState? state) {
                      return EditorConfig(
                        maxScale: 3,
                        cropRectPadding: const EdgeInsets.all(30),
                        cropAspectRatio: 1,
                        editorMaskColorHandler: (context, pointerDown) {
                          return CupertinoColors.white.withOpacity(pointerDown ? 0.2 : 0.6);
                        },
                      );
                    },
                  ),
                ),
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
                    child: const Icon(
                      CupertinoIcons.clear_thick_circled,
                        size: 70, 
                        color: CupertinoColors.destructiveRed),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    onPressed: () async {
                      Uint8List? result = await _saveImage();
                      Navigator.pop(context, result);
                    },
                    child: const Icon(CupertinoIcons.check_mark_circled_solid,
                        size: 70, color: CupertinoColors.activeGreen),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _rotate(bool directionRight) {
    _editorKey.currentState!.rotate(right: directionRight);
  }

  void _flip() {
    _editorKey.currentState!.flip();
  }

  void _reset() {
    _editorKey.currentState!.reset();
  }

  Future<Uint8List?> _saveImage() async {
    final GlobalKey progressDialogKey = GlobalKey<State>();
    ProgressDialog.show(context, progressDialogKey);
    Uint8List? result = await _crop();
    if (result != null) result = _resize(result, width: 800) as Uint8List?;
    ProgressDialog.hide(progressDialogKey);
    return result;
  }

  Future<Uint8List?> _crop() async {
    final ExtendedImageEditorState state = _editorKey.currentState!;
    final Rect rect = state.getCropRect()!;
    final EditActionDetails action = state.editAction!;
    final double radian = action.rotateAngle;
    final bool flipHorizontal = action.flipY;
    final bool flipVertical = action.flipX;
    final Uint8List image = state.rawImageData;
    final ImageEditorOption option = ImageEditorOption();
    option.addOption(ClipOption.fromRect(rect));
    option.addOption(FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
    if (action.hasRotateAngle) option.addOption(RotateOption(radian.toInt()));
    option.outputFormat = const OutputFormat.png(80);

    return await ImageEditor.editImage(
      image: image,
      imageEditorOption: option,
    );
  }

  List<int> _resize(Uint8List imageData, {int? width, int? height}) {
    IMG.Image image = IMG.decodeImage(imageData)!;
    IMG.Image resized = IMG.copyResize(image, width: width, height: height);

    return IMG.encodePng(resized);
  }
}*/
