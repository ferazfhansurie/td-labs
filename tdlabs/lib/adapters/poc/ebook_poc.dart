// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/models/poc/poc.dart';
import 'package:transparent_image/transparent_image.dart';

// ignore: must_be_immutable
class EbookPocAdapter extends StatefulWidget {
  final Poc? poc;
  final Color? color;
  final bool? active;
  EbookPocAdapter(
      {Key? key, this.poc, this.color, this.active,})
      : super(key: key);

  @override
  _EbookPocAdapterState createState() => _EbookPocAdapterState();
}

class _EbookPocAdapterState extends State<EbookPocAdapter> {
  Color? reportColor;
  Color? nameColor;
  Widget? reportWidget;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Color? color =(widget.color != null) ? widget.color : CupertinoColors.systemGrey6;
    return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: color,
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 24, 112, 141).withOpacity(0.6),
              spreadRadius: 2,
              blurRadius: 3,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(right: 10, left: 10,top:10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            color: Colors.white,
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 24, 112, 141).withOpacity(0.6),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment:CrossAxisAlignment.center,
                children: [
                   Card(
                    elevation: 5,
                    child: SizedBox(
                      width: 85,
                      height: 85,
                      child:(widget.poc!.image_url == null)
                          ? const Icon(
                              Icons.local_hospital,
                              size: 25,
                            )
                          : FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image:widget.poc!.image_url! ,
                                            ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.poc!.name!,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style:  const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 24, 112, 141)),
                          ),
                        ),
                      SizedBox(
                        width: 205,
                        child: Text(widget.poc!.address!,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 14,
              ),
            ],
          ),
        ));
  }
}
