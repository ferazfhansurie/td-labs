// ignore_for_file: non_constant_identifier_names

class Goal {
  final int user_id;
  final int duration;
  final int steps;



  Goal(
      {required this.user_id,
      required this.duration,
      required this.steps,
      });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      user_id: json['user_id'],
      duration: json['duration'],
      steps: json['steps'],
    );
  }
 
}
