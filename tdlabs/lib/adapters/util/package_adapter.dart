import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../models/commerce/package.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class PackageAdapter extends StatefulWidget {
  final Package package;
  const PackageAdapter({Key? key, required this.package}) : super(key: key);
  @override
  _PackageAdapterState createState() => _PackageAdapterState();
}

class _PackageAdapterState extends State<PackageAdapter> {
  String desc = '';
  @override
  void initState() {
    if (widget.package.name == "Smart Rewards Programme (SRP)") {
      desc = "Smart Rewards Programme (SRP)\nSimply by making purchases at our TD Mall or Farmasi Keluarga vending machines and collecting Teda Coins, you can gain fantastic bonuses.\nFor every RM1 spent, you can earn 100 Teda Coins 10,000 points = RM1 worth of Teda Coins \n*T&C Apply";
    } else if (widget.package.name == "Smart Consuming Programme (SCP)") {
      desc = "Smart Consumer Programme (SCP)\nGrab product with SCP Program in TD Mall or Vending Machine\nGet 100% Rebate * \nTerms & Conditions Apply*";
    }else if (widget.package.name == "Proof-Of-Test (POT) Reward") {
      desc = "1.Perform Covid-19 Self-Test\n2.Upload  Covid-19 RTK Self-Test Result\n3.Get Reward of 2000 TDC \n4.Spend with your TDC on TDMALL & Farmasi Keluarga !";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _content();
  }
  Widget _content() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 52, 169, 176),
                  Color.fromARGB(255, 49, 42, 130),
                ],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
              ),
            ),
            padding: const EdgeInsets.all(15),
            child: Text(
              widget.package.name!.tr,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 15),
            ),
          ),
          Container(
            width: double.infinity,
            height: 110,
            padding: const EdgeInsets.all(15),
            child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: widget.package.imageUrl!,
                fit: BoxFit.cover),
          ),
          Container(
            width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Text(
                desc.tr,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.grey,
                    fontWeight: FontWeight.w300,
                    fontSize: 12),
              )),
        ],
      ),
    );
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    var text = htmlText.replaceAll(exp, ' ');
    RegExp exp2 = RegExp(r"amp;", multiLine: true, caseSensitive: true);
    var text2 = text.replaceAll(exp2, ' ');
    RegExp exp3 = RegExp(r"nbsp;", multiLine: true, caseSensitive: true);
    var text3 = text2.replaceAll(exp3, ' ');
    RegExp exp4 = RegExp(r"  ", multiLine: true, caseSensitive: true);
    return text3.replaceAll(exp4, ' ');
  }
}
