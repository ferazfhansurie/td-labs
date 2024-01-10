// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';

typedef StringCallback = Function(String value);

class SearchBarWidget extends StatefulWidget {
  String? value;
  final bool showScanner;
  final StringCallback onSubmitted;

  SearchBarWidget(
      {Key? key,
      this.showScanner = false,
      required this.onSubmitted,
      this.value})
      : super(key: key);

  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
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
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: _searchController,
              placeholder: 'Search',
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
