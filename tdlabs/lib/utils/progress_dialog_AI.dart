// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ProgressDialogAI {
  static Future<void> show(BuildContext context, GlobalKey key) async {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return CupertinoAlertDialog(
            key: key,
            content: Container(
              padding: const EdgeInsets.all(0.0),
              child: Center(
                child: Column(children: [
                  DefaultTextStyle(
                    style: TextStyle(
                        fontSize: 20.0,
                        color: CupertinoTheme.of(context).primaryColor),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText('AI is verifying...'),
                        WavyAnimatedText('Loading...'),
                      ],
                      isRepeatingAnimation: true,
                    ),
                  ),
                ]),
              ),
            ),
          );
        });
  }

  static void hide(GlobalKey key) {
    Navigator.of(key.currentContext!, rootNavigator: true).pop();
  }
}
