import 'package:flutter/material.dart';
import 'package:tdlabs/widgets/search/search_bar2.dart';
import 'package:tdlabs/widgets/search/search_bar4.dart';

typedef StringCallback = Function(String value);

class CustomSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  String category;
  final StringCallback search;
  Function() showPicker;
  Function()? map;
  String? latitude;
  String? longitude;
  bool? isCatalog;
  bool? mapShown;
  CustomSliverAppBarDelegate(
      {required this.expandedHeight,
      required this.category,
      required this.search,
      required this.showPicker,
      this.isCatalog,
      this.latitude,
      this.longitude,
      this.mapShown,
      this.map});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    const size = 60;
    final top = expandedHeight - shrinkOffset - size / 2;

    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        if (shrinkOffset == 75) buildAppBar(shrinkOffset, context),
        if (shrinkOffset == 0) buildBackground(shrinkOffset, context),
        Positioned(
          top: top,
          left: 20,
          right: 20,
          child: buildFloating(shrinkOffset),
        ),
      ],
    );
  }

  double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

  double disappear(double shrinkOffset) => 1 - shrinkOffset / expandedHeight;

  Widget buildAppBar(double shrinkOffset, BuildContext context) => Opacity(
        opacity: appear(shrinkOffset),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 52, 169, 176),
                Color.fromARGB(255, 49, 42, 130),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding:  EdgeInsets.only(top:MediaQuery.of(context).padding.top, left: 5),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    showPicker();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    width: 175,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 130,
                              child: Text(
                                category,
                                maxLines: 1,
                              )),
                          const Icon(Icons.arrow_drop_down)
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                SizedBox(
                  width: 100,
                  child: SearchBar2(
                    onSubmitted: (value) => search,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildBackground(double shrinkOffset, BuildContext context) => Opacity(
      opacity: disappear(shrinkOffset),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 52, 169, 176),
              Color.fromARGB(255, 49, 42, 130),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(),
      ));

  Widget buildFloating(double shrinkOffset) => Opacity(
        opacity: disappear(shrinkOffset),
        child: SearchBar4(
          latitude: latitude,
          longitude: longitude,
          onSubmitted: (value) => search(value),
          map: mapShown,
          showMap: map,
          isCatalog: isCatalog,
        ),
      );

  Widget buildButton({
    required String text,
    required IconData icon,
  }) =>
      TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 20)),
          ],
        ),
        onPressed: () {},
      );

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 18;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
