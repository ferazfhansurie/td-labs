import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef IntCallback = Function(int value);

class SpinBox2 extends StatefulWidget {
  final int min;
  final int max;
  final int step;
  final int value;
  final bool validateOnKeyPress;
  final IntCallback? onChanged;
  final VoidCallback? onValueZero;

  const SpinBox2(
      {Key? key,
      required this.min,
      required this.max,
      this.step = 1,
      required this.value,
      this.validateOnKeyPress = false,
      this.onChanged,
      this.onValueZero})
      : super(key: key);

  @override
  _SpinBox2State createState() => _SpinBox2State();
}

class _SpinBox2State extends State<SpinBox2> {
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();
  late IntCallback _onChanged;
  Color? _inputTextColor;
  late int _oldValue;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _inputController.text = widget.value.toString();

    _onChanged = widget.onChanged ?? (value) {};
    if (!widget.validateOnKeyPress) {
      _focusNode.addListener(() {
        if (!_focusNode.hasFocus) {
          int input = _getInput();
          input = _limitInput(input);

          if ((input <= 0) && (widget.onValueZero != null)) {
            input = _oldValue; // Use previous value
            _onValueZero();
          } else {
            // Skip if no changes
            if (input != _oldValue) {
              _onChanged(input);
            }
          }

          setState(() {
            _inputController.text = input.toString();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_inputTextColor == null) _validateInput(widget.value);

    return Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          border: Border.all(color: CupertinoColors.systemGrey5),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 24,
              child: CupertinoButton(
                padding: const EdgeInsets.all(5),
                onPressed: ((_getInput() - 1) < widget.min)
                    ? null
                    : () async {
                        int input = _getInput();
                        input = _limitInput((input - widget.step));

                        if ((input <= 0) && (widget.onValueZero != null)) {
                          input = _getInput(); // Use previous value
                          _onValueZero();
                        } else {
                          _onChanged(input);
                        }

                        setState(() {
                          _inputController.text = input.toString();
                        });

                        FocusManager.instance.primaryFocus?.unfocus();
                        SystemSound.play(SystemSoundType.click);
                      },
                child: const Icon(CupertinoIcons.minus, size: 14),
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                _inputController.text,
                textAlign: TextAlign.center,
                style:  const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 52, 169, 176),
                                      fontSize: 24),
              
             
              ),
            ),
            SizedBox(
              width: 32,
              height: 24,
              child: CupertinoButton(
                padding: const EdgeInsets.all(5),
                onPressed: ((_getInput() + 1) > widget.max)
                    ? null
                    : () {
                        int input = _getInput();
                        input = _limitInput((input + widget.step));

                        _onChanged(input);

                        setState(() {
                          _inputController.text = input.toString();
                        });

                        FocusManager.instance.primaryFocus?.unfocus();
                        SystemSound.play(SystemSoundType.click);
                      },
                child: const Icon(CupertinoIcons.add, size: 14),
              ),
            ),
          ],
        ));
  }

  int _getInput() {
    return (_inputController.text != '') ? int.parse(_inputController.text) : 0;
  }

  int _limitInput(int value) {
    // Bypass if onValueZero method is set
    if ((value <= 0) && (widget.onValueZero != null)) {
      return 0;
    }

    if (value < widget.min) {
      value = widget.min;
    } else if (value > widget.max) {
      value = widget.max;
    }

    _validateInput(value);
    return value;
  }

  void _validateInput(int value) {
    _inputTextColor = CupertinoTheme.of(context).textTheme.textStyle.color;
    if ((value > widget.max) || (value < widget.min)) {
      _inputTextColor = Colors.red[700];
    }
  }

  void _onValueZero() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: const Text('Are you sure you want to delete this item?'),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Yes',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w300)),
                onPressed: () {
                  if (widget.onValueZero != null) {
                    widget.onValueZero!();
                  }
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                  child: const Text('No',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w300)),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }
}
