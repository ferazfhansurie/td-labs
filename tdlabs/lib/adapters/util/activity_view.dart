// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ActivityView extends StatefulWidget {
  String? name;
  Icon? image;
  int? index;
  Color? color;
  ActivityView({Key? key, this.name, this.image, this.index,this.color}) : super(key: key);

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 5 / 20,
      width: MediaQuery.of(context).size.width * 5 / 12.5,
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.6),
              offset: const Offset(1.1, 4.0),
              blurRadius: 8.0),
        ],
        color: widget.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              width: 75,
              height: 75,
              child: Icon(
                widget.image!.icon,
                size: 55,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Text(
              widget.name!,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
