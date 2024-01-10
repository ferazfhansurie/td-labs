import 'package:flutter/cupertino.dart';

/// @copyright Copyright (c) 2020
/// @author David Cheang <davidcheang83@gmail.com>
/// @version 1.0.0

typedef IntCallback = Function(int value);

class HorizontalMenu extends StatefulWidget {
  final Map<int, Widget> children;
  final int? initialGroup;
  final IntCallback onChanged;

  const HorizontalMenu({Key? key, required this.children, this.initialGroup, required this.onChanged}) : super(key: key);

  @override
  _HorizontalMenuState createState() => _HorizontalMenuState();
}

class _HorizontalMenuState extends State<HorizontalMenu> {
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialGroup != null) _selected = widget.initialGroup!;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      scrollDirection: Axis.horizontal,
      child: CupertinoSegmentedControl(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: widget.children,
        groupValue: _selected,
        onValueChanged: (value) {
          setState(() {
            _selected = int.parse(value.toString());
          });

          widget.onChanged(int.parse(value.toString()));
        },
      ),
    );
  }
}

