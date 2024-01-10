import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WipScreen extends StatefulWidget {
  const WipScreen({Key? key}) : super(key: key);

  @override
  _WipScreenState createState() => _WipScreenState();
}

class _WipScreenState extends State<WipScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/Background-02.png"),
                      fit: BoxFit.fill),
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.only(
                 
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                margin: const EdgeInsets.only(top: 5),
                padding: EdgeInsets.only(
                 
                ),
                child: SingleChildScrollView(
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
                                size: 30,
                              ),
                            ),
                            const Spacer(),
                            const Spacer()
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Icon(
                        Icons.construction,
                        size: 75,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "Coming Soon",
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          fontSize: 25),
                    )
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
