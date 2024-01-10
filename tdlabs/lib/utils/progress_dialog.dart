import 'package:flutter/cupertino.dart';
import 'package:tdlabs/widgets/progress_bar.dart';
import 'package:video_compress/video_compress.dart';

import '../widgets/custom_progress_indicator copy.dart';

class ProgressDialog {
  late Subscription subscription;
  double? progress;

  static Future<void> show(BuildContext context, GlobalKey key) async {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Container(
            key: key,
            child: const CustomProgressIndicator(),
          );
        });
  }

  Future<void> showProcess(BuildContext context, GlobalKey key) async {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Container(key: key, child: const ProgressBar());
        });
  }

  static Future<void> unshow(BuildContext context, GlobalKey key) async {
    Navigator.pop(context);
  }

  static void hide(GlobalKey? key) {
    Navigator.of(key!.currentContext!, rootNavigator: true).pop();
  }
}
