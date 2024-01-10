import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/content/content.dart';

class ContentAdapter extends StatefulWidget {
  final Content content;
  const ContentAdapter({Key? key, required this.content}) : super(key: key);
  @override
  _ContentAdapterState createState() => _ContentAdapterState();
}
class _ContentAdapterState extends State<ContentAdapter> {
  static double scale = 1;
  @override
  Widget build(BuildContext context) {
    return _content();
  }
  Widget _content() {
    return Container(
      width: MediaQuery.of(context).size.width * 90 / 100,
      padding: const EdgeInsets.only(right: 13, left: 13, top: 20),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: const Icon(CupertinoIcons.person_alt_circle_fill),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TDLABS',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              fontSize: scale * 14,
                            ),
                          ),
                          Text(
                            widget.content.createdAtText!,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              fontSize: scale * 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
                  child: Text(
                    widget.content.title!,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                      fontSize: scale * 14,
                    ),
                  ),
                ),
                Visibility(
                  visible: (widget.content.description == ''),
                  replacement: Container(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, bottom: 10, top: 5),
                    child: Text(
                      widget.content.description!,
                    ),
                  ),
                  child: Container(),
                ),
                Visibility(
                  // ignore: unnecessary_null_comparison
                  visible: (widget.content.url == null),
                  replacement: Container(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, bottom: 10, top: 5),
                    child: GestureDetector(
                      onTap: () {
                        _launchURL(widget.content.url.toString());
                      },
                      child: Text(
                        widget.content.url.toString(),
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                            color: CupertinoColors.systemBlue),
                      ),
                    ),
                  ),
                  child: Container(),
                ),
                Visibility(
                  visible: (widget.content.image == ''),
                  replacement: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10, top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FadeInImage.memoryNetwork(
                              fit: BoxFit.fill,
                              height: 330,
                              placeholder: kTransparentImage,
                              image: widget.content.imageUrl!),
                        ],
                      ),
                    ),
                  ),
                  child: Container(),
                ),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  _launchURL(var url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url),mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
