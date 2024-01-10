import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/screens/dependant/dependant_form.dart';

// ignore: must_be_immutable
class DependantAdapter extends StatefulWidget {
  String? name;
  String? idno;
  String? phone;
  String? email;
  int? relation;

  DependantAdapter(
      {Key? key, this.name, this.idno, this.phone, this.email, this.relation})
      : super(key: key);
  @override
  _DependantAdapterState createState() => _DependantAdapterState();
}

class _DependantAdapterState extends State<DependantAdapter> {
  String rate = '';
  String endDate = '';

  @override
  void initState() {
    // implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _dependantAdapter();
  }

  Widget _dependantAdapter() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border.all(
          color: CupertinoColors.separator,
        ),
      ),
      child: Container(
          padding: const EdgeInsets.all(15),
          child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                  return DependantFormScreen(idno: widget.idno!);
                }));
              },
              child: Column(
                children: [
                  Text(widget.name!),
                  Text(widget.relation.toString().tr)
                ],
              ))),
    );
  }
}
