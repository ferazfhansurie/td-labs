// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/content/banners.dart';

class BannerAdapter extends StatefulWidget {
  BannerAdapter({Key? key, this.index, required this.banner}) : super(key: key);
  final Banners banner;
  int? index;

  @override
  _BannerAdapterState createState() => _BannerAdapterState();
}

class _BannerAdapterState extends State<BannerAdapter> {
  @override
  Widget build(BuildContext context) {
    return (widget.banner.is_disabled == 0)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Text(
                      widget.banner.title.tr,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 104, 104, 104),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(
                        Icons.arrow_circle_right,
                        size: 20,
                      ),
                    )
                  ],
                ),
              ),
              ClipRRect( 
                borderRadius: BorderRadius.circular(20),
                child:Image.network( widget.banner.imageUrl,                          
                  height: MediaQuery.of(context).size.height * 15 / 100,
                  width: MediaQuery.of(context).size.width,),
              ),
            ],
          )
        : Container();
  }
}
