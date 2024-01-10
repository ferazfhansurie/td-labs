import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdlabs/models/commerce/catalog.dart';
import 'package:tdlabs/widgets/form/text_input.dart';

// ignore: must_be_immutable
class OrderCounter extends StatefulWidget {
  Catalog? product;
  int? index;
  List<int>? orderQuantityList;
  List<Map<String, dynamic>>? orderList = [];
  List<Map<String, dynamic>>? orderNameList = [];
  List<double>? orderTotalList = [];

  OrderCounter(
      {Key? key,
      this.product,
      this.index,
      this.orderQuantityList,
      this.orderList,
      this.orderNameList,
      this.orderTotalList})
      : super(key: key);

  @override
  _OrderCounterState createState() => _OrderCounterState();
}

class _OrderCounterState extends State<OrderCounter> {
  SubTotalController subTotalController = Get.put(SubTotalController());
  double? totalAdd;
  int index = 0;
  final inputController = TextEditingController();
  List<int> orderQuantityList = [];
  List<Map<String, dynamic>> orderList = [];
  List<Map<String, dynamic>> orderNameList = [];
  List<double> orderTotalList = [];

  @override
  void initState() {
    super.initState();
    index = (widget.index == null) ? 0 : index;
    orderQuantityList =(widget.orderQuantityList != null) ? widget.orderQuantityList! : [];
    orderList = (widget.orderList != null) ? widget.orderList! : [];
    orderNameList = (widget.orderNameList != null) ? widget.orderNameList! : [];
    orderTotalList =(widget.orderTotalList != null) ? widget.orderTotalList! : [];
  }

  @override
  void dispose() {
    //implement dispose
    index = 0;
    orderNameList.clear();
    orderList.clear();
    orderTotalList.clear();
    orderQuantityList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color counterColor;
    counterColor = Colors.black;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Card(
          color: CupertinoColors.secondarySystemBackground,
          elevation: 2,
          shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: InkWell(
            splashColor: CupertinoTheme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10.0),
            onTap: () {
              counterMinus(widget.product!, index);
            },
            child: Container(
              alignment: Alignment.center,
              height: 30,
              width: 30,
              child: const Text(
                '-',
                style:TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            _showPickerInput(widget.product!, index);
          },
          child: Container(
            alignment: Alignment.center,
            // width: 20,
            padding: const EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
                border: Border.all(color: CupertinoTheme.of(context).primaryColor)),
            child: Text(
              orderQuantityList[index].toString(),
              style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: counterColor,
                  fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Card(
          color: CupertinoColors.secondarySystemBackground,
          elevation: 2,
          shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: InkWell(
            splashColor: CupertinoTheme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10.0),
            onTap: () {
              counterAdd(widget.product!, index);
            },
            child: Container(
              alignment: Alignment.center,
              height: 30,
              width: 30,
              child: const Text(
                '+',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void counterAdd(Catalog product, int index) async {
    double price = double.parse(product.price!);
    if (orderQuantityList[index] < 99) {
      if (mounted) {
        setState(() {
          orderQuantityList[index]++;
          subTotalController.getSubTotal =subTotalController.getSubTotal! + price as RxDouble;
          int quantity = orderQuantityList[index];
          //need fix
          if (orderList.isNotEmpty) {
            orderList[index]['total'] = price * quantity;
            orderList[index]['product_id'] = product.id;
            orderList[index]['quantity'] = quantity;
          }
          orderNameList[index]['product_name'] = product.name;
          orderNameList[index]['quantity'] = orderQuantityList[index];
          orderTotalList[index] = price * quantity;
        });
      }
    }
  }

  void counterMinus(Catalog product, int index) async {
    double price = double.parse(product.price!);
    int quantity = orderQuantityList[index];
    if (orderQuantityList[index] > 0 && quantity != 0) {
      if (mounted) {
        setState(() {
          orderQuantityList[index]--;
          subTotalController.getSubTotal =subTotalController.getSubTotal! - price as RxDouble;
          orderList[index]['total'] = price * quantity;
          orderList[index]['product_id'] = product.id;
          orderList[index]['quantity'] = orderQuantityList[index];
          orderNameList[index]['product_name'] = product.name;
          orderNameList[index]['quantity'] = orderQuantityList[index];
          orderTotalList[index] = price * quantity;
        });
      }
    }
  }

  _showPickerInput(
    Catalog product,
    int index,
  ) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 30 / 100,
                width: MediaQuery.of(context).size.height * 250 / 100,
                alignment: Alignment.topCenter,
                child: TextInput(
                  label: 'Quantity'.tr,
                  placeHolder: 'Please input quantity',
                  type: 'phoneNo',
                  prefixWidth: 80,
                  controller: inputController,
                  maxLength: 2,
                  autoFocus: true,
                  boolsuffix: true,
                  textInputAction: TextInputAction.unspecified,
                  onEditingComplete: () {
                    if (inputController.text != '') {
                      double price = double.parse(product.price!);
                      double quantity = double.parse(inputController.text);
                      int quantityStore = int.parse(inputController.text);
                      totalAdd = 0.00;
                      double sum = 0.0;
                      if (mounted) {
                        setState(() {
                          orderQuantityList[index] = quantityStore;
                          orderList[index]['total'] = price *quantity; // assign total to product called
                          orderList[index]['product_id'] = product.id;
                          orderList[index]['quantity'] =orderQuantityList[index];
                          orderNameList[index]['product_name'] = product.name;
                          orderNameList[index]['quantity'] =orderQuantityList[index];
                          orderTotalList[index] = price * quantity;
                          for (double productSum in orderTotalList) {
                            sum += productSum;
                          }
                          subTotalController.getSubTotal = RxDouble(sum);
                        });
                      }
                      orderNameList.removeWhere((element) => element['product_name'] == '');
                      orderList.removeWhere((element) => element['product_id'] == '');
                      inputController.clear();
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SubTotalController extends GetxController {
  RxDouble? getSubTotal;
  void updateSubTotal(double subTotal) {
    getSubTotal = subTotal.obs;
  }
}
