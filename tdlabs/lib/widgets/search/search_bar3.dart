// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/time_session.dart';

typedef StringCallback = Function(String value);

class SearchBar3 extends StatefulWidget {
  String? value;
  final bool showScanner;
  final StringCallback onSubmitted;
  List<TimeSession>? list;
  SearchBar3({
    Key? key,
    this.showScanner = false,
    required this.onSubmitted,
    this.list,
    this.value,
  }) : super(key: key);

  @override
  _SearchBar3State createState() => _SearchBar3State();
}

class _SearchBar3State extends State<SearchBar3> {
  final _searchController = TextEditingController();
  bool _isClearButton = false;

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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            width: 250,
            child: CupertinoTextField(
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
          Visibility(
            visible: widget.showScanner,
            child: GestureDetector(
              onTap: () async {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Container(
                height: 36,
                width: 36,
                padding: const EdgeInsets.only(left: 5),
                child: const Icon(CupertinoIcons.qrcode_viewfinder, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }

 

  Widget? _getClearButton() {
    if (!_isClearButton) return null;

    return Container(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          _searchController.clear();
        },
        child: const Icon(CupertinoIcons.clear_thick_circled,
            size: 18, color: CupertinoColors.systemGrey3),
      ),
    );
  }
}
