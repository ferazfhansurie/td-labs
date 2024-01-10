// ignore_for_file: prefer_final_fields, must_be_immutable
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class CarouselSlide extends StatefulWidget {
  List images;
  CarouselSlide({Key? key, required this.images}) : super(key: key);
  @override
  _CarouselSlideState createState() => _CarouselSlideState();
}

class _CarouselSlideState extends State<CarouselSlide> {
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
                              placeholder: kTransparentImage,image:
                      item,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CarouselSlider(
                carouselController: _controller,
                options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * 40 / 100,
                    aspectRatio: 16 / 9,
                    viewportFraction: 1.1,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                    autoPlay: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    }),
                items: imageSliders)),
        SizedBox(
          height: 30,
          child: Card(
            elevation: 0,
            color: const Color.fromARGB(0, 255, 255, 255),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
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
                                ? const Color.fromARGB(255, 233, 233, 233)
                                : const Color.fromARGB(255, 80, 80, 80)))),
                  );
                }),
          ),
        )
      ],
    );
  }
}
