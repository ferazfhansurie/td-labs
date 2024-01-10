import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// @copyright Copyright (c) 2021
/// @author David Cheang <davidcheang83@gmail.com>
/// @version 2.0.0 (null-safety)

class DateTimeInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final double? prefixWidth;
  final String? mode;
  final String? initialDatePickerMode;
  final DateTime? initialDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool required;
  final bool readOnly;

  const DateTimeInput(
      {Key? key,
      required this.label,
      required this.controller,
      this.prefixWidth,
      this.mode,
      this.initialDatePickerMode,
      this.initialDate,
      this.startDate,
      this.endDate,
      this.required = false,
      this.readOnly = false})
      : super(key: key);

  @override
  _DateTimeInputState createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInput> {
  static const modeDate = 'date';
  static const modeDateTime = 'datetime';
  DateTime? _selectedDateTime;
  String _selectedText = '';

  @override
  Widget build(BuildContext context) {
    double _prefixWidth = widget.prefixWidth ?? 60;
    String _mode = widget.mode ?? modeDateTime;
    if (widget.controller.text.isNotEmpty) {
      _selectedDateTime = _convertToDateTime(widget.controller.text, _mode);
      if (_selectedDateTime != null) {
        _selectedText = _convertToString(_selectedDateTime!, _mode);
      }
    }

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
            : () async {
                DateTime? dateResult = await _showDatePicker(context);
                if (dateResult != null) {
                  if (_mode == modeDateTime) {
                    TimeOfDay? timeResult = await _showTimePicker(context);
                    if (timeResult != null) {
                      DateTime dateTimeResult = DateTime(
                          dateResult.year,
                          dateResult.month,
                          dateResult.day,
                          timeResult.hour,
                          timeResult.minute);
                      setState(() {
                        _selectedDateTime = dateTimeResult;
                        _selectedText =_convertToString(_selectedDateTime!, _mode);
                        widget.controller.text = _selectedDateTime.toString();
                      });
                    }
                  } else {
                    setState(() {
                      _selectedDateTime = dateResult;
                      _selectedText =_convertToString(_selectedDateTime!, _mode);
                      widget.controller.text =_selectedDateTime.toString().split(' ')[0];
                    });
                  }
                }
              },
        child: Row(
          children: [
            SizedBox(
              width: _prefixWidth,
              child: Row(
                children: [
                  Text(widget.label,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
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
                child: Text(_selectedText, maxLines: 1),
              ),
            ),
            Visibility(
              visible: !widget.readOnly,
              child: SizedBox(
                width: 12,
                child: Icon(
                  CupertinoIcons.chevron_right,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _showDatePicker(BuildContext context) async {
    DatePickerMode datePickerMode = DatePickerMode.day;
    if (widget.initialDatePickerMode != null) {
      if (widget.initialDatePickerMode == 'year') {
        datePickerMode = DatePickerMode.year;
      }
    }

    DateTime now = DateTime.now();
    DateTime initialDate = widget.initialDate ?? DateTime.now();
    DateTime firstDate =widget.startDate ?? DateTime(now.year - 10, now.month, now.day);
    DateTime lastDate =widget.endDate ?? DateTime(now.year + 10, now.month, now.day);

    if (_selectedDateTime != null) {
      initialDate = _selectedDateTime!;
    }
    // Ensure initialDate is within date range
    if (firstDate.isAfter(initialDate)) {
      firstDate = initialDate;
    }
    if (lastDate.isBefore(initialDate)) {
      lastDate = initialDate;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDatePickerMode: datePickerMode,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          child: child!,
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
                primary: CupertinoTheme.of(context).primaryColor),
          ),
        );
      },
    );

    if (pickedDate != null) {
      return pickedDate;
    }
    return null;
  }

  Future<TimeOfDay?> _showTimePicker(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (_selectedDateTime != null) {
      initialTime = TimeOfDay.fromDateTime(_selectedDateTime!);
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          child: child!,
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
                primary: CupertinoTheme.of(context).primaryColor),
          ),
        );
      },
    );

    if (pickedTime != null) {
      return pickedTime;
    }
    return null;
  }

  String _convertToString(DateTime dateTime, String mode) {
    String pattern = 'dd/MM/yyyy hh:mm aaa';
    if (mode == modeDate) pattern = 'dd/MM/yyyy';

    return DateFormat(pattern).format(dateTime);
  }

  DateTime _convertToDateTime(String dateTime, String mode) {
    String pattern = 'yyyy-MM-dd HH:mm:ss';
    if (mode == modeDate) pattern = 'yyyy-MM-dd';

    return DateFormat(pattern).parse(dateTime);
  }
}
