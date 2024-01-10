import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// @copyright Copyright (c) 2020
/// @author David Cheang <davidcheang83@gmail.com>
/// @version 2.0.3 (null-safety)

class PickerInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final Map<String, String> options;
  final double? prefixWidth;
  final double? pickerHeight;
  final bool required;
  final bool readOnly;

  const PickerInput(
      {Key? key,
      required this.label,
      required this.controller,
      required this.options,
      this.prefixWidth,
      this.pickerHeight,
      this.required = false,
      this.readOnly = false})
      : super(key: key);

  @override
  _PickerInputState createState() => _PickerInputState();
}

class _PickerInputState extends State<PickerInput> {
  FixedExtentScrollController? _scrollController;
  final Map<String, String> _options = {'': ''}; // Empty option at beginning
  final List<Widget> _pickerOptions = [];
  double _pickerHeight = 300;
  String _selectedText = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _options.addAll(widget.options);
    _options.forEach((key, value) {
      Widget widget = Center(
        child: Text(value, style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w300)),
      );
      _pickerOptions.add(widget);
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _prefixWidth = widget.prefixWidth ?? 60;
    if (widget.pickerHeight != null) _pickerHeight = widget.pickerHeight!;
    Color? _color = (!widget.readOnly)
        ? CupertinoTheme.of(context).textTheme.textStyle.color
        : CupertinoColors.inactiveGray;
    int initialItem = 0;
    if (widget.controller.text.isNotEmpty) {
      if (_options[widget.controller.text] != null) {
        _selectedText = _options[widget.controller.text]!;
        int count = 0;
        for (var key in _options.keys) {
          if (key == widget.controller.text) {
            initialItem = count;
            break;
          }
          count++;
        }
      }
    }
    _scrollController = FixedExtentScrollController(initialItem: initialItem);
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5),
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (widget.readOnly)
            ? null
            : () {
                // Hide opened keyboard
                FocusScope.of(context).requestFocus(FocusNode());
                _showPicker();
              },
        child: Row(
          children: [
            SizedBox(
              width: _prefixWidth,
              child: Row(
                children: [
                  Text(widget.label,
                      style: const TextStyle(fontWeight: FontWeight.w300)),
                  Visibility(
                    visible: widget.required,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text('*',
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: CupertinoTheme.of(context).primaryColor)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Text(_selectedText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _color,fontWeight: FontWeight.w300)),
              ),
            ),
            Visibility(
                visible: !widget.readOnly,
                child: const SizedBox(
                  width: 12,
                  child: Icon(CupertinoIcons.chevron_right),
                )),
          ],
        ),
      ),
    );
  }
  void _showPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: _pickerHeight,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: CupertinoColors.systemGrey5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  color: CupertinoColors.destructiveRed,
                                  fontWeight: FontWeight.w300)),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigator.pop(context);
                          if (_scrollController != null) {
                            int count = 0;
                            for (var key in _options.keys) {
                              if (count == _selectedIndex) {
                                _scrollController = FixedExtentScrollController(initialItem: count);
                                widget.controller.text = key;
                                if (_options[key] != null) {
                                  setState(() {
                                    _selectedText = _options[key]!;
                                  });
                                }
                                break;
                              }
                              count++;
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Text('Done',
                              style: TextStyle(
                                  color:
                                      CupertinoTheme.of(context).primaryColor)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: _scrollController,
                    backgroundColor: Colors.white,
                    itemExtent: 28,
                    onSelectedItemChanged: (value) {
                      _selectedIndex = value;
                    },
                    children: _pickerOptions,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
