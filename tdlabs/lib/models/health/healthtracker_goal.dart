import 'package:flutter/cupertino.dart';
import '../../utils/web_service.dart';

class HealthTrackerGoal {
   int step;
   int heartRate;

   HealthTrackerGoal({required this.step, required this.heartRate});

  factory HealthTrackerGoal.fromJson(Map<String, dynamic> json) {
    return HealthTrackerGoal(
        step: json['step'],
        heartRate: json['heart_rate'],
    );
  }

  static Future<Response?> create(BuildContext context, HealthTrackerGoal model) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('catalog/carts/add-to-cart');

    Map<String, String> data = {};
    data['step'] = model.step.toString();
    data['heart_rate'] = model.heartRate.toString();

    return await webService.setData(data).send();
  }
}
