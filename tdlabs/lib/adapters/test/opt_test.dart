import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../models/screening/opt_test.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
// ignore: must_be_immutable
class OptTestAdapter extends StatefulWidget {
  final OptTest optTest;
  bool isComingSoon;

  OptTestAdapter({Key? key, required this.optTest, this.isComingSoon = false})
      : super(key: key);
  @override
  _OptTestAdapterState createState() => _OptTestAdapterState();
}
class _OptTestAdapterState extends State<OptTestAdapter> {
  @override
  Widget build(BuildContext context) {
    return _optTest();
  }
  Widget _optTest() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  height: 75,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white,
                    border: Border.all(color: Colors.white),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (widget.optTest.fromNetwork == true)
                            ? (widget.optTest.image != '')
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 18.0),
                                    child:FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,image:
                                      widget.optTest.image.toString(),
                                      width: 60,
                                      height: 60,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(right: 30.0),
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color.fromARGB(255, 49, 42, 130),
                                            Color.fromARGB(255, 52, 169, 176),
                                          ],
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                        ),
                                        borderRadius:BorderRadius.circular(100),
                                        border: Border.all(color: Colors.white),
                                      ),
                                    ),
                                  )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  widget.optTest.image.toString(),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.fill,
                                ),
                              ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.optTest.name.toString().tr,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            Container(
                              padding: const EdgeInsets.only(top: 2),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  // ignore: unnecessary_null_comparison
                                  (widget.optTest.shortDescription.toString() != null)
                                      ? widget.optTest.shortDescription.toString()
                                      : '',
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 10)),
                            ),
                          ],
                        )
                      ])),
            ),
          ],
        ),
      )
    ]);
  }
}
