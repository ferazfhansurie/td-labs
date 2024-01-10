import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateInput extends StatefulWidget {
  final String? label;
  final TextEditingController? controller;
  final double? prefixWidth;

  const DateInput({Key? key, this.label, this.controller, this.prefixWidth})
      : super(key: key);

  @override
  _DateInputState createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  DateTime? _selectedDate;
  String _selectedText = '';

  @override
  Widget build(BuildContext context) {
    double _prefixWidth =(widget.prefixWidth != null) ? widget.prefixWidth! : 60;

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
        onTap: () {
          _showPicker(context);
        },
        child: Row(
          children: [
            SizedBox(
              width: _prefixWidth,
              child: Text(widget.label!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Text(_selectedText,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            SizedBox(
              width: 12,
              child: Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) async {
    DateTime start = DateTime.now();
    DateTime end = DateTime.now();
    DateTime addStart = start.add(const Duration(days: 0));
    DateTime addEnd = end.add(const Duration(days: 7));
    DateTime startDate =DateTime(addStart.year, addStart.month, addStart.day, 0, 0, 0);
    DateTime endDate =DateTime(addEnd.year, addEnd.month, addEnd.day, 23, 59, 59);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (_selectedDate != null) ? _selectedDate! : startDate,
      firstDate: startDate,
      lastDate: endDate,
      builder: (BuildContext? context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: CupertinoColors.activeBlue,
            colorScheme:
                const ColorScheme.light(primary: CupertinoColors.activeBlue),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if ((picked != null) && (picked != _selectedDate)) {
      setState(() {
        _selectedDate = picked;
        _selectedText =DateFormat('dd/MM/yyyy').format(_selectedDate!.toLocal());
      });
    }

    widget.controller!.text = _selectedDate!.toLocal().toString().split(' ')[0];
  }
}
