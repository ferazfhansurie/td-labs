import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user/user.dart';

// ignore: must_be_immutable
class DateInputBirthday extends StatefulWidget {
  final String? label;
  final TextEditingController? controller;
  final double? prefixWidth;
  bool? required = false;
  DateInputBirthday({Key? key, this.label, this.controller, this.prefixWidth, this.required})
      : super(key: key);
  @override
  _DateInputBirthdayState createState() => _DateInputBirthdayState();
}

class _DateInputBirthdayState extends State<DateInputBirthday> {
  DateTime? _selectedDate;
  String? _selectedText;
  @override
  void initState() {
    super.initState();
    _populate();
    _populate();
  }
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
              child: Row(
                children: [
                  Text(widget.label!,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Visibility(
                    visible: (widget.required == true &&
                        widget.controller!.text == ''),
                    replacement: Container(
                      width: 10,
                    ),
                    child: Row(
                      children: const [
                        SizedBox(width: 2),
                        Icon(
                          CupertinoIcons.exclamationmark_circle_fill,
                          size: 6,
                          color: CupertinoColors.systemRed,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Text((_selectedText != null) ? _selectedText! : '',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(
              width: 12,
              child: Icon(
                CupertinoIcons.chevron_right,
                color: Colors.black,
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
    DateTime addStart = start.add(const Duration());
    DateTime addEnd = end.add(const Duration(milliseconds: 1));
    DateTime startDate = DateTime(-100, addStart.month, addStart.day, 0, 0, 0);
    DateTime endDate =DateTime(addEnd.year, addEnd.month, addEnd.day, 23, 59, 59);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (_selectedDate != null) ? _selectedDate! : start,
      firstDate: startDate,
      currentDate: DateTime.now(),
      lastDate: endDate,
      builder: (BuildContext? context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: CupertinoColors.activeBlue,
            colorScheme:const ColorScheme.light(primary: CupertinoColors.activeBlue),
            buttonTheme:const ButtonThemeData(textTheme: ButtonTextTheme.primary),
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

  Future<void> _populate() async {
    User? user = await User.fetchOne(context);
    setState(() {
      if (user!.dob != null) {
        _selectedDate = DateTime.parse(user.dob!);
        _selectedText =DateFormat('dd/MM/yyyy').format(_selectedDate!.toLocal());
      }
    });
  }
}
