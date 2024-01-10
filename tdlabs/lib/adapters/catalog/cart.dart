// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

// ignore: must_be_immutable
class CartAdapter extends StatefulWidget {
  List<Map<String, dynamic>> item;
  int index;
  Function()? delete;
  Function()? add;
  Function()? minus;
  CartAdapter(
      {Key? key,
      required this.item,
      required this.index,
      this.delete,
      this.add,
      this.minus})
      : super(key: key);
  @override
  _CartAdapterState createState() => _CartAdapterState();
}

class _CartAdapterState extends State<CartAdapter> {
  List<Map<String, dynamic>> tempList = [];
  bool drag = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
          height: 176,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(color: Colors.blueGrey),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Center(
                        child: Card(
                            color: CupertinoColors.secondarySystemBackground,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                            child: (widget.item[widget.index]['image_url'] != null)
                                ? SizedBox(
                                    width: 100,
                                    height: 100,
                                    child:FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                                      image:widget.item[widget.index]['image_url'].toString()),
                                  )
                                : const SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Icon(CupertinoIcons.cart),
                                  )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 200,
                              padding: const EdgeInsets.all(15),
                              alignment: Alignment.center,
                              child: Text(widget.item[widget.index]['name'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ),
                            if (widget.item[widget.index]['vm_name'] != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      widget.item[widget.index]['vm_name'].toString(),
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300)),
                                ],
                              ),
                            Container(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                  "RM " + widget.item[widget.index]['price'].toString(),
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 13,
                                      color: Color.fromARGB(255, 24, 112, 141),
                                      fontWeight: FontWeight.w300)),
                            ),
                            Container(
                              alignment: Alignment.bottomCenter,
                              child: Card(
                                color: CupertinoColors.secondarySystemBackground,
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        key: Key("minus " +widget.index.toString()),
                                        splashColor:CupertinoTheme.of(context).primaryColor,
                                        onTap: () {
                                          widget.minus!();
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: 30,
                                          width: 30,
                                          child: const Text(
                                            '-',
                                            style: TextStyle(
                                              fontSize: 25,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () async {},
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(left: 5, right: 5),
                                          decoration: BoxDecoration(
                                                  border: Border.all(
                                                  color: CupertinoTheme.of(context).primaryColor)),
                                          child: Text(
                                            widget.item[widget.index]['quantity'].toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        key: Key("plus " +widget.index.toString()),
                                        splashColor:CupertinoTheme.of(context).primaryColor,
                                        onTap: () {
                                          widget.add!();
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                        height: 30,
                                          width: 30,
                                          child: const Text(
                                            '+',
                                            style: TextStyle(
                                               fontSize: 20,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      GestureDetector(
                        onTap: () {
                          widget.delete!();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                              color: const Color.fromARGB(255, 205, 77, 70),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              child: const SizedBox(
                                width: 100,
                                height: 100,
                                child: Center(
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
