// ignore_for_file: must_be_immutable
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/models/commerce/catalog.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'package:tdlabs/screens/catalog/catalog_screen.dart';
import 'package:tdlabs/screens/catalog/vm_screen.dart';
import 'package:tdlabs/widgets/search/search_bar.dart';

class CatalogCategory extends StatefulWidget {
  int? method;
  VendingMachine? vm;
  CatalogCategory({
    Key? key,
    this.method,
    this.vm,
  }) : super(key: key);

  @override
  State<CatalogCategory> createState() => _CatalogCategoryState();
}

class _CatalogCategoryState extends State<CatalogCategory> {
  final List<Catalog> _subcategoryList = [];
  int totalSub = 0;
  @override
  void initState() {
    // implement initState
    super.initState();
  }

  void _performSearch({String? keyword}) {
    // Reset list

    if (keyword != null) {
      setState(() {
        _search = keyword;
      });
      if (widget.method == 0) {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return CatalogScreen(
            categoryId: null,
            search: _search,
          );
        }));
      } else {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return VmScreen(
            vm: widget.vm,
            search: _search,
          );
        }));
      }
    }
  }

  final List<Catalog> _listCategory = [];
  String _search = '';
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/Background-02.png"),
                  fit: BoxFit.fill),
            ),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(15),
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
                      const Spacer(),
                      const Text(
                        "Category",
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer()
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchBarWidget(
                  onSubmitted: (value) => _performSearch(
                    keyword: value,
                  ),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height - 160,
              width: 75,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.all(5),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("hello"),
                  );
                },
              ),
                  ),
                  const SizedBox(
              width: 16,
                  ),
                  Container(
              width: 250,
              height: MediaQuery.of(context).size.height - 160,
              color: Colors.white,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  Catalog category = _listCategory[index];
                  // ignore: unused_local_variable
                  String description = category.name!;
                  return Padding(
                    padding: const EdgeInsets.all(3),
                    child: GestureDetector(
                      key: Key("category_tap " + index.toString()),
                      onTap: () async {
                      },
                      child: Card(
                          child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("image"),
                          ],
                        ),
                      )),
                    ),
                  );
                },
              ),
                  ),
                ]),
            ]),
          )),
    );
  }

  showSubCategory(BuildContext context) {
    // set up the AlertDialog
    Widget alert = Container(
      height: 200,
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        children: [
          AlertDialog(
            title: Text(
              'Choose Sub-Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
            content: SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(5),
                    itemCount: _subcategoryList.length,
                    itemBuilder: (context, index) {
                      Catalog category = _subcategoryList[index];
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: GestureDetector(
                          onTap: () {
                            if (widget.method == 0) {
                              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                return CatalogScreen(
                                  categoryId: (category.name != "All")
                                      ? category.id
                                      : null,
                                );
                              }));
                            } else {
                              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                return VmScreen(
                                  vm: widget.vm,
                                  categoryId: (category.name != "All")
                                      ? category.id
                                      : null,
                                );
                              }));
                            }
                          },
                          child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(category.name!),
                              )),
                        ),
                      );
                    })),
            actions: const [
              //cancelButton,
              //continueButton,
            ],
          ),
        ],
      ),
    );
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
