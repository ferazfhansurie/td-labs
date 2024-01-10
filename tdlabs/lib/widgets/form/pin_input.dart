import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// @copyright Copyright (c) 2020
/// @author David Cheang <davidcheang83@gmail.com>
/// @version 2.0.1 (null-safety)

typedef StringCallback = Function(String value);

class PinInput extends StatefulWidget {
  final StringCallback onCompleted;
  final TextEditingController controller;

  const PinInput({Key? key, required this.controller, required this.onCompleted}) : super(key: key);

  @override
  _PinInputState createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> {
  final int _length = 6;
  final FocusScopeNode _node = FocusScopeNode();
  List<String> _pin = [];
  final Map<int, TextEditingController> _inputControllers = {};

  @override
  void initState() {
    super.initState();
    _pin = List.filled(_length, '');
    for (int i=0; i<_length; i++) {
      TextEditingController inputController = TextEditingController();
      _inputControllers[i] = inputController;
    }
  }

  @override
  void dispose() {
    _inputControllers.forEach((key, inputController) {
      inputController.dispose();
    });
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: CupertinoColors.white,
      child: FocusScope(
        node: _node,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _renderInputs(widget),
        ),
      ),
    );
  }

  List<Widget> _renderInputs(widget) {
    List<Widget> inputs = [];
    _inputControllers.forEach((key, inputController) {
      Widget inputWidget = SizedBox(
        width: 40,
        child: CupertinoTextField(
          maxLength: 1,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          padding: const EdgeInsets.symmetric(vertical: 10),
          style: const TextStyle(fontSize: 30),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: inputController,
          textInputAction: TextInputAction.next,
          onTap: () {
            inputController.text = '';
          },
          onChanged: (value) {
            _pin[key] = value;
            if (key < (_length - 1)) {
              _node.nextFocus();
              _inputControllers[key+1]!.text = '';
            } else {
              widget.controller.text = _pin.join();
              widget.onCompleted(widget.controller.text);
            }
          },
        ),
      );

      inputs.add(inputWidget);
    });

    return inputs;
  }
}
