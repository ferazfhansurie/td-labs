// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:tdlabs/screens/health/activity_summary.dart';

class ActivityView extends StatefulWidget {
  String? name;
  Icon? image;
  ActivityView({Key? key,this.name,this.image}) : super(key: key);

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width*5/12.5,
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              // Handle tap event here
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  ActivitySummary(
                    name: widget.name!,
                  ),
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              child: Container(
                height: MediaQuery.of(context).size.height*5/20,
                width: MediaQuery.of(context).size.width*5/12.5,
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey
                            .withOpacity(0.6),
                        offset: const Offset(1.1, 4.0),
                        blurRadius: 8.0),
                  ],
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 52, 169, 176),
                      Color.fromARGB(255, 49, 42, 130),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:   BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 130, left: 16, right: 16, bottom: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Handle onTap event here
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  ActivitySummary(
                    name: widget.name!,
                  ),
                  ));
            },
            child: Padding(
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
          )
        ],
      ),
    );
  }
}
