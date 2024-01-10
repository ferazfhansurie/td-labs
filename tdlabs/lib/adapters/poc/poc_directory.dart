import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:map_launcher/map_launcher.dart';
import '../../models/poc/poc_directory.dart';

// ignore: must_be_immutable
class PocDirectoryAdapter extends StatefulWidget {
  final PocDirectory? poc;
  final Color? color;
  final bool? active;
  List<AvailableMap>? availableMaps;
  PocDirectoryAdapter(
      {Key? key, this.poc, this.color, this.active, this.availableMaps})
      : super(key: key);
  @override
  _PocDirectoryAdapterState createState() => _PocDirectoryAdapterState();
}

class _PocDirectoryAdapterState extends State<PocDirectoryAdapter> {
  Color? reportColor;
  Color? nameColor;
  Widget? reportWidget;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
      padding: const EdgeInsets.all(10.0),
      child: Column(
         mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
           mainAxisAlignment: MainAxisAlignment.start,
            children: [
             
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        widget.poc!.name,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style:  TextStyle(
                           fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: CupertinoTheme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: Text(widget.poc!.street_1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 104, 104, 104),
                          )),
                    ),
                    Text(widget.poc!.city,
                        style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:Color.fromARGB(255, 104, 104, 104),)),
                  ],
                ),
              ),
              const SizedBox(width: 30,),
               ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                  color: CupertinoColors.secondarySystemBackground,
                child: SizedBox(
                  width: 65,
                  height: 65,
                  child: (widget.poc!.image_url == null)
                      ? const Icon(
                          Icons.local_hospital,
                          size: 25,
                        )
                      : FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image:widget.poc!.image_url! ,
                                        ),
                ),
              )),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
