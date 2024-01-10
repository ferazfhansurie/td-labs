import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../global.dart' as global;

class PriceRange extends StatefulWidget {
  final List<dynamic> prices;

  const PriceRange({Key? key, required this.prices}) : super(key: key);

  @override
  _PriceRangeState createState() => _PriceRangeState();
}

class _PriceRangeState extends State<PriceRange> {
  @override
  Widget build(BuildContext context) {
    Color? _textColor = CupertinoTheme.of(context).textTheme.textStyle.color;
    NumberFormat formatter = NumberFormat(',##0.00');

    if (widget.prices.length == 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(global.settings.currency, style: TextStyle(fontSize: 10, color: _textColor,fontWeight: FontWeight.w300)),
          Text(formatter.format(double.parse(widget.prices[0])), style: TextStyle(fontSize: 14, color: _textColor,fontWeight: FontWeight.w300)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('~', style: TextStyle(fontSize: 14, color: _textColor,fontWeight: FontWeight.w300)),
          ),
          Text(global.settings.currency, style: TextStyle(fontSize: 10, color: _textColor,fontWeight: FontWeight.w300)),
          Text(formatter.format(double.parse(widget.prices[1])), style: TextStyle(fontSize: 14, color: _textColor,fontWeight: FontWeight.w300)),
        ],
      );
    } else if (widget.prices.length == 1) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(global.settings.currency, style: TextStyle(fontSize: 10, color: _textColor,fontWeight: FontWeight.w300)),
          Text(formatter.format(double.parse(widget.prices[0])), style: TextStyle(fontSize: 14, color: _textColor,fontWeight: FontWeight.w300)),
        ],
      );
    } else {
      return Container();
    }
  }
}
