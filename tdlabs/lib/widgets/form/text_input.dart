import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class TextInput extends StatefulWidget {
  final String? label;
  final TextEditingController? controller;
  final String? type;
  final double? prefixWidth;
  final int? maxLength;
  final String? placeHolder;
  bool? enabled = true;
  bool? required = false;
  bool? boolsuffix;
  bool autoFocus;
  TextInputAction textInputAction;
  Function()? onEditingComplete;
  Function()? send;
  FocusNode? focusNode;
  TextInput(
      {Key? key,
      this.label,
      this.controller,
      this.type,
      this.prefixWidth,
      this.maxLength,
      this.placeHolder,
      this.enabled,
      this.required,
      this.boolsuffix = false,
      this.autoFocus = false,
      this.textInputAction = TextInputAction.send,
      this.onEditingComplete,
      this.focusNode,
      this.send})
      : super(key: key);

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {


  @override
  Widget build(BuildContext context) {
    double? _prefixWidth =
        (widget.prefixWidth != null) ? widget.prefixWidth : 60;
    List<TextInputFormatter> _inputFormatters = [];
    _inputFormatters.add(LengthLimitingTextInputFormatter(
        widget.maxLength)); //Not working for text

    var _keyboardType = TextInputType.text;
    var _obscureText = false;
    var _autocorrect = true;
    var _enableSuggestions = true;

    if (widget.type == 'phoneNo') {
      _keyboardType = TextInputType.number;
      _inputFormatters.add(FilteringTextInputFormatter.digitsOnly);
    } else if (widget.type == 'email') {
      _keyboardType = TextInputType.emailAddress;
    } else if (widget.type == 'password') {
      _obscureText = true;
      _autocorrect = false;
      _enableSuggestions = false;
    }

    return GestureDetector(
        onTap: () {
      
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          border: Border(
            bottom: BorderSide(color: CupertinoColors.systemGrey5),
          ),
        ),
        child: CupertinoTextField(
          focusNode: widget.focusNode,
            placeholder: (widget.placeHolder != null) ? widget.placeHolder : '',
            decoration: null,
            autocorrect: _autocorrect,
            obscureText: _obscureText,
            enableSuggestions: _enableSuggestions,
            keyboardType: _keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: _inputFormatters,
            controller: widget.controller,
            autofocus: widget.autoFocus,
            onEditingComplete: widget.onEditingComplete,
            prefix: Container(
              color: CupertinoColors.white,
              width: _prefixWidth,
              child: Row(
                children: [
                  Text(
                    widget.label.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: Color.fromARGB(255, 104, 104, 104),
                    ),
                  ),
                  Visibility(
                    visible: (widget.required == true &&
                        widget.controller!.text == ''),
                    replacement: Container(),
                    child: Row(
                      children: const [
                        SizedBox(width: 2),
                        Icon(
                          CupertinoIcons.exclamationmark_circle_fill,
                          color: CupertinoColors.systemRed,
                          size: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            suffix: Visibility(
              key: const Key("send"),
              visible: (widget.boolsuffix == true),
              child: GestureDetector(
                onTap: widget.onEditingComplete,
                child: const Icon(Icons.send),
              ),
              replacement: Container(),
            )),
      ),
    );
  }
}
