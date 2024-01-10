import 'package:country_pickers/countries.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// @copyright Copyright (c) 2020
/// @author David Cheang <davidcheang83@gmail.com>
/// @version 2.0.1 (null-safety)

class PhoneNoInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final double? prefixWidth;
  final int? maxLength;
  final List<String>? filterCountryList;
  final List<String>? priorityCountryList;
  final bool required;
  final bool readOnly;

  const PhoneNoInput(
      {Key? key,
      required this.label,
      required this.controller,
      this.prefixWidth,
      required this.maxLength,
      this.filterCountryList,
      this.priorityCountryList,
      this.required = false,
      this.readOnly = false})
      : super(key: key);

  @override
  _PhoneNoInputState createState() => _PhoneNoInputState();
}

class _PhoneNoInputState extends State<PhoneNoInput> {
  final _inputController = TextEditingController();
  final double _pickerHeight = 300;
  final List<Country> _pickerPriorityList = [];
  late Country _selectedCountry;

  @override
  void initState() {
    super.initState();

    if ((widget.priorityCountryList != null) &&
        widget.priorityCountryList!.isNotEmpty) {
      for (String countryCode in widget.priorityCountryList!) {
        _pickerPriorityList.add(
            CountryPickerUtils.getCountryByIsoCode(countryCode.toUpperCase()));
      }
    }

    List<Country> countries = countryList.toList();
    if ((widget.priorityCountryList != null) &&
        (widget.priorityCountryList!.isNotEmpty)) {
      _selectedCountry = CountryPickerUtils.getCountryByIsoCode(widget.priorityCountryList!.first);
    } else if ((widget.filterCountryList != null) &&
        (widget.filterCountryList!.isNotEmpty)) {
      _selectedCountry = CountryPickerUtils.getCountryByIsoCode(widget.filterCountryList!.first);
    } else {
      _selectedCountry = countries.first;
    }

    // Split phone no to components
    if (widget.controller.text.isNotEmpty) {
      String initialPhoneNo =widget.controller.text.replaceAll(RegExp(r'[^0-9]'), '');
      for (Country country in countries) {
        if (initialPhoneNo.startsWith(country.phoneCode)) {
          _selectedCountry = country;
          _inputController.text =initialPhoneNo.substring(country.phoneCode.length);
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _prefixWidth = widget.prefixWidth ?? 60;
    Color? _color = (!widget.readOnly)
        ? CupertinoTheme.of(context).textTheme.textStyle.color
        : CupertinoColors.inactiveGray;
    double _selectedPhoneCodeFontSize =CupertinoTheme.of(context).textTheme.textStyle.fontSize!;
    String _selectedPhoneCode = '+' + _selectedCountry.phoneCode;
    if (_selectedPhoneCode.length > 4) _selectedPhoneCodeFontSize = 11;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: CupertinoTextField(
              decoration: null,
              maxLength: widget.maxLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: _inputController,
              style: TextStyle(color: _color),
              prefix: Container(
                margin: const EdgeInsets.only(right: 90),
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
                                color:CupertinoTheme.of(context).primaryColor)),
                      ),
                    ),
                  ],
                ),
              ),
              readOnly: widget.readOnly,
              onChanged: (value) {
                _validatePhoneNo(value);
                _setPhoneNo();
              },
            ),
          ),
          Positioned(
            left: _prefixWidth,
            child: GestureDetector(
              onTap: () {
                _showPicker();
              },
              child: Container(
                height: 40,
                width: 90,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: CupertinoColors.systemGrey5),
                    right: BorderSide(color: CupertinoColors.systemGrey5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: CupertinoTheme.of(context).textTheme.textStyle.color!,
                              width: 1)),
                      child: CountryPickerUtils.getDefaultFlagImage( _selectedCountry),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(_selectedPhoneCode,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              fontSize: _selectedPhoneCodeFontSize,
                              fontWeight: FontWeight.w300)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.all(10),
                      child: Text('Done',
                          style: TextStyle(
                              color: CupertinoTheme.of(context).primaryColor,
                              fontWeight: FontWeight.w300)),
                    ),
                  ),
                ),
                Expanded(
                  child: CountryPickerCupertino(
                    initialCountry: _selectedCountry,
                    pickerSheetHeight: 300,
                    onValuePicked: (Country country) {
                      setState(() {
                        _selectedCountry = country;
                      });

                      _inputController.text = '';
                      _setPhoneNo();
                    },
                    priorityList: _pickerPriorityList,
                    itemFilter: (country) {
                      if (widget.filterCountryList == null) {
                        return true;
                      } else if (widget.filterCountryList!.contains(country.isoCode)) {
                        return true;
                      }

                      return false;
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _validatePhoneNo(phoneNo) {
    if (_selectedCountry.isoCode == 'MY') {
      if (phoneNo.isNotEmpty && (phoneNo.substring(0, 1) == '0')) {
        _inputController.text = phoneNo.replaceAll(RegExp(r'^0+'), '');
        _inputController.selection = TextSelection.fromPosition(
            TextPosition(offset: _inputController.text.length));
      }
    }
  }

  void _setPhoneNo() {
    if (_inputController.text.isNotEmpty) {
      String phoneCode = _selectedCountry.phoneCode.replaceAll(RegExp(r'[^0-9]'), '');
      widget.controller.text = phoneCode + _inputController.text;
    } else {
      widget.controller.text = '';
    }
  }
}
