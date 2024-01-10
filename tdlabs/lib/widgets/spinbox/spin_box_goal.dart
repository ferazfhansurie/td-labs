import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef IntCallback = Function(int value);

class SpinBoxGoal extends StatefulWidget {
  final int min;
  final int max;
  final int step;
  final int value;
  final bool validateOnKeyPress;
  final IntCallback? onChanged;
  final VoidCallback? onValueZero;

  const SpinBoxGoal(
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
  _SpinBoxGoalState createState() => _SpinBoxGoalState();
}

class _SpinBoxGoalState extends State<SpinBoxGoal> {
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 50,
          height: 75,
          child: CupertinoButton(
            padding: const EdgeInsets.all(5),
            onPressed: ((_getInput() - 1) < widget.min)
                ? null
                : () async {
                    int input = _getInput();
                    input = _limitInput((input - widget.step));
                    if ((input <= 0) && (widget.onValueZero != null)) {
                      input = _getInput(); // Use previous value
                    } else {
                      _onChanged(input);
                    }
                    setState(() {
                      _inputController.text = input.toString();
                    });
                    FocusManager.instance.primaryFocus?.unfocus();
                    SystemSound.play(SystemSoundType.click);
                  },
            child:  Icon(CupertinoIcons.minus, size: 20,color: CupertinoTheme.of(context).primaryColor,),
          ),
        ),
        SizedBox(
          width: 150,
          child: CupertinoTextField(
            style: TextStyle(color: _inputTextColor,fontSize: 20),
            focusNode: _focusNode,
            controller: _inputController,
            enabled: (widget.max >= widget.min),
            enableSuggestions: false,
            autocorrect: false,
            padding: const EdgeInsets.symmetric(vertical: 4),
            textAlign: TextAlign.center,
                 decoration: const BoxDecoration(
                border: Border.symmetric(
                    vertical:BorderSide(color: CupertinoColors.white))),
            maxLength: 6,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onTap: () {
              _oldValue = _getInput();
            },
            onChanged: (!widget.validateOnKeyPress)
                ? null
                : (value) {
                    if (value.isNotEmpty) {
                      int input = _limitInput(int.parse(value));
                      _onChanged(input);
                      _inputController.text = input.toString();
                      _inputController.selection =
                          TextSelection.fromPosition(TextPosition(
                              offset: _inputController.text.length));
                    } else {
                      _onChanged(widget.min);
                    }
                  },
          ),
        ),
        SizedBox(
          width: 50,
          height: 75,
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
            child:  Icon(CupertinoIcons.add,size: 20,color: CupertinoTheme.of(context).primaryColor,),
          ),
        ),
      ],
    );
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
