// ignore_for_file: must_be_immutable, non_constant_identifier_names, prefer_const_constructors_in_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/models/util/notification.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationAdapter extends StatefulWidget {
  final Color? color;
  Notifications notification;
  NotificationAdapter({
    Key? key,
    this.color,
    required this.notification
  }) : super(key: key);

  @override
  _NotificationAdapterState createState() => _NotificationAdapterState();
}

class _NotificationAdapterState extends State<NotificationAdapter> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color color = widget.color!;
    return GestureDetector(
      onTap: (){
        if (widget.notification.screenId == '4') {
      
    } else if (widget.notification.screenId == '3') {
   
    }
      },
      child: Container(
          width: double.infinity,
        color: color,
        child:  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  color: Colors.blue,
                  height: 15,width: 5,),
                  SizedBox(width: 5,),
                Text(
                  widget.notification.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
    
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 65/100,
                  child: Text(
                    widget.notification.message,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Column(
                  children: [
                    Text(
                        widget.notification.createdAtText,
                                                    style: TextStyle(fontSize: 12, color: Colors.grey[750], fontWeight: FontWeight.w500),
                      ),
                      if(widget.notification.url != null && widget.notification.url!.contains("zoom"))
                       GestureDetector(
                        onTap: (){
                          _launchURL(widget.notification.url!);
                        },
                         child: Container(
                            decoration:  BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 48, 186, 168),
                                Color.fromARGB(255, 49, 53, 131),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                           child: Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Text(
                              "Join Call",
                                                          style: TextStyle(fontSize: 12, color:  Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w500),
                                                   ),
                           ),
                         ),
                       ),
                  ],
                ),
              ],
            ),
           
          ],
        ),
      ),
      ),
    );
  }
    _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
