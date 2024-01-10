// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/time_session.dart';

typedef StringCallback = Function(String value);

class SearchBarEbook extends StatefulWidget {
  String? value;
  final bool showScanner;
  final StringCallback onSubmitted;
  Function()? onClear;
  final StringCallback ? onChanged;
  List<TimeSession>? list;
  SearchBarEbook({
    Key? key,
    this.showScanner = false,
    required this.onSubmitted,
    this.list,
    this.value,
    this.onClear,
    this.onChanged,
  }) : super(key: key);

  @override
  _SearchBarEbookState createState() => _SearchBarEbookState();
}

class _SearchBarEbookState extends State<SearchBarEbook> {
  final _searchController = TextEditingController();
  bool _isClearButton = false;
  bool searching = false;
  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      _searchController.text = widget.value!;
    }

    _searchController.addListener(() {
      setState(() {
        _isClearButton = (_searchController.text.isNotEmpty);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
             padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
          child: CupertinoTextField(
            onChanged: (value) {
              if(widget.onChanged != null){
                 widget.onChanged!(value);
              if (value != "") {
                setState(() {
                  searching = true;
                });
              } else {
                setState(() {
                  searching = false;
                });
              }
              }
             
            },
            controller: _searchController,
            placeholder: 'Search'.tr,
            onSubmitted: widget.onSubmitted,
            prefix: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(CupertinoIcons.search),
            ),
            suffix: _getClearButton(),
          ),
        ),
      );
  }

  Widget? _getClearButton() {
    if (!_isClearButton) return null;

    return Container(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          if(widget.onClear != null) {
            widget.onClear!();
          }
          _searchController.clear();
          widget.onSubmitted(_searchController.text);
        },
        child: const Icon(CupertinoIcons.clear_thick_circled,
            size: 18, color: CupertinoColors.systemGrey3),
      ),
    );
  }
}
