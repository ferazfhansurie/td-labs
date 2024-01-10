import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/user/user-dependant.dart';
import 'package:tdlabs/screens/dependant/dependant_form.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';

class Dependency extends StatefulWidget {
  const Dependency({Key? key}) : super(key: key);
  @override
  _DependencyState createState() => _DependencyState();
}

class _DependencyState extends State<Dependency> {
  List<dynamic>? _dependantList;
  Future<List<dynamic>?>? _future;
  final ScrollController _scrollController = ScrollController();
  String filterByUser = 'true';
  String? imageurl;
  String relationName = "";
  int relationIndex = 0;
  int? age;
  final List<UserDependant> _udList = [];
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    refreshList();
  }

  @override
  void dispose() {
    _udList.clear();
    super.dispose();
  }
  Future<void> refreshList() async {
    if (_dependantList != null) {
      setState(() {
        _dependantList!.clear();
      });
    }
    setState(() {
      _udList.clear();
    });
    _performSearch();
  }

  void _performSearch() {
    // Reset list
    _future = _fetchDependant(context);
  }
  Future<List<UserDependant>?> _fetchUD() async {
    final webService = WebService(context);
    webService.setEndpoint('option/list/relation');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      final parseList2 =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<UserDependant> relation = parseList2.map<UserDependant>((json) => UserDependant.fromJson(json)).toList();
      setState(() {
        _udList.addAll(relation);
      });
    }
    return _udList;
  }
  Future<List<dynamic>?> _fetchDependant(BuildContext context) async {
    _fetchUD();
    final webService = WebService(context);
    var response =await webService.setEndpoint('identity/user-dependants').send();
    if (response == null) return null;
    if (response.status) {
      _dependantList =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
    }
    return _dependantList;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/Background-01.png"),
              fit: BoxFit.fill),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(
         
        ),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Text(
                      "My Dependants".tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer()
                  ],
                ),
              ),
            ),
            _addDependantButton(),
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: RefreshIndicator(
                  onRefresh: refreshList, child: _dependantListView()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addDependantButton() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        height: 36,
        child: CupertinoButton(
          color: CupertinoTheme.of(context).primaryColor,
          disabledColor: CupertinoColors.inactiveGray,
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
              return DependantFormScreen();
            }));
          },
          child: Text('Add'.tr,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                  color: CupertinoColors.white)),
        ),
      ),
    );
  }

  Widget _dependantListView() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 70 / 100,
      child: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if ((snapshot.data != null) && (_dependantList!.isNotEmpty)) {
            return Scrollbar(
              controller: _scrollController,
              child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount:(snapshot.data != null) ? _dependantList!.length : 0,
                  itemBuilder: (context, index) {
                    return Container(
                        padding: const EdgeInsets.all(5),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                              return DependantFormScreen(
                                id: _dependantList![index]['id'],
                                idno: _dependantList![index]['id_no'],
                                name: _dependantList![index]['name'],
                                email: _dependantList![index]['email'],
                                phone: _dependantList![index]['phone_no'],
                                age: _dependantList![index]['age'],
                                relation: _dependantList![index]['relation'],
                              );
                            }));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.white,
                              border: Border.all(color:CupertinoTheme.of(context).primaryColor),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 24, 112, 141).withOpacity(0.6),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: const Offset(0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Name : ".tr,
                                        ),
                                        Text(
                                          _dependantList![index]['name'],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Relation : ".tr,
                                        ),
                                        Text(
                                          (_udList.isNotEmpty)
                                              ? _udList[_dependantList![index]['relation']].name!.tr
                                              : '',
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                const Icon(Icons.edit)
                              ],
                            ),
                          ),
                        ));
                  }),
            );
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height -MediaQuery.of(context).padding.bottom -100,
                  child: Center(
                    child: Visibility(
                      visible: (snapshot.data != null),
                      replacement: IntrinsicHeight(
                          child: ConnectionError(onRefresh: refreshList)),
                      child: Text(
                          'No dependants found,\nPlease add or refresh list'
                              .tr),
                    ),
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }
        },
      ),
    );
  }
}
