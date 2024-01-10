import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toast {
  static void show(BuildContext context, String type, String message, {int? duration, double? offset}) {
    Color _color = Colors.grey[900]!;
    Color _borderColor = Colors.grey[500]!;
    Color _backgroundColor = Colors.grey[400]!;

    if (type == 'success') {
      _color = Colors.green[900]!;
      _borderColor = Colors.green[500]!;
      _backgroundColor = Colors.green[100]!;
    }  else if (type == 'danger') {
      _color = Colors.red[900]!;
      _borderColor = Colors.red[500]!;
      _backgroundColor = Colors.red[100]!;
    }

    Widget toast = SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: EdgeInsets.only(bottom: (offset != null) ? offset : 10),
        decoration: BoxDecoration(
          border: Border.all(color: _borderColor),
          borderRadius: BorderRadius.circular(12),
          color: _backgroundColor,
        ),
        child: Text(message, style: TextStyle(fontSize: 14, color: _color)),
      ),
    );

    FToast fToast = FToast();
    fToast.init(context);
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: (duration != null)?duration:2),
    );
  }
}
