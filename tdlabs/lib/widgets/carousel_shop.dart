// ignore_for_file: prefer_final_fields, must_be_immutable
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class CarouselShop extends StatefulWidget {
  List images;
  double? height;
  CarouselShop({Key? key, required this.images,this.height}) : super(key: key);
  @override
  _CarouselShopState createState() => _CarouselShopState();
}

class _CarouselShopState extends State<CarouselShop> {
  CarouselController _controller = CarouselController();
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> imageSliders = widget.images
        .map((item) => GestureDetector(
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child: FadeInImage.memoryNetwork(
                      height: 300,
                      placeholder: kTransparentImage,
                      image: item,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
    print(MediaQuery.of(context).size.height * 20 / 100);
    return Stack(
      children: [
        ClipRRect(
            child: CarouselSlider(
                carouselController: _controller,
                options: CarouselOptions(
                    height: widget.height!,
                    aspectRatio: 16 / 9,
                    viewportFraction: 1,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                    autoPlay: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    }),
                items: imageSliders)),
        Positioned(
          bottom: 0,
          left: 130,
          right: 0,
          top: 110,
          child: SizedBox(
            height: 30,
            child: Card(
              elevation: 0,
              color: const Color.fromARGB(0, 255, 255, 255),
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    // ignore: unused_local_variable

                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                          width: 10.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (_current == index
                                  ? CupertinoTheme.of(context).primaryColor
                                  : const Color.fromARGB(255, 255, 255, 255)))),
                    );
                  }),
            ),
          ),
        )
      ],
    );
  }
}
