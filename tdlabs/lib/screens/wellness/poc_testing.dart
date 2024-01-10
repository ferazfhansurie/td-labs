
import 'package:flutter/material.dart';

class PocTesting extends StatefulWidget {
  const PocTesting({
    Key? key,
  }) : super(key: key);

  @override
  State<PocTesting> createState() => _PocTestingState();
}

class _PocTestingState extends State<PocTesting> {
   List<Color> colors = [
                        const Color.fromARGB(255, 153, 224, 255),
                        const Color.fromARGB(255, 128, 134, 242),
                        const Color.fromARGB(255,97, 92, 242),
                        const Color.fromARGB(255,0, 0, 165),
                        const Color.fromARGB(255,211, 219, 35),
                        const Color.fromARGB(255,232, 0, 136),
                      ];
                       List<String> names = [
                        'Viscera',
                        'Qi Blood Essence',
                        'Meridian',
                        'Heartbeat',
                        'Covid Screening',
                          'Blood Preassure',
                          'Blood'
                      ];
                          Color getColorForIndex(int index) {
                          return colors[index % colors.length];
                        }
                            String getName(int index) {
                          return names[index % names.length];
                        }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(
             
            ),
            child: Column(children: [
              Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(45.0),
                      bottomRight: Radius.circular(45.0),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 48, 186, 168),
                        Color.fromARGB(255, 49, 53, 131),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 10 / 100,
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: 75,
                        child: const Text(
                          "Point of Care Testing",
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 7,
                    
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      int num = index + 1;
                     
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: getColorForIndex(index),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              width: 80,
                              height: 80,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/images/poc-icons-0' +
                                      num.toString() +
                                      '.png',height: 60,fit: BoxFit.contain,),
                                ],
                              ),
                            ),
                          ),
                          Text(
                              getName(index),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 104, 104, 104),
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Montserrat',
                                fontSize: 9,
                              ),
                            ),
                        ],
                      );
                    }),
              ),
               const SizedBox(
                height: 25,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8)
                ),
                height: 450,
                width: 300,
                child: Column(

                  children: [
                  Text(
                            getName(0),
                            style: const TextStyle(
                              color: Color.fromARGB(255, 104, 104, 104),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              fontSize:18,
                            ),
                          ),
                ]),
              )
            ])));
  }
}
