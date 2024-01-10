// ignore_for_file: non_constant_identifier_names

class Event {
  final int id;
  final String name;
  final String start_date;
  final String end_date;
  final String credit_amount;
  final String credit_points;
   final String image_url;
  final List<dynamic> vouchers;


  Event(
      {required this.id,
      required this.name,
      required this.start_date,
      required this.end_date,
      required this.credit_amount,
      required this.credit_points,
       required this.image_url,
      required this.vouchers,
      });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      start_date: json['start_date'],
      end_date: json['end_date'],
      credit_amount: json['credit_amount'],
      credit_points: json['credit_points'],
      image_url: json['image_url'],
      vouchers: json['vouchers'],
     
    );
  }
 
}
