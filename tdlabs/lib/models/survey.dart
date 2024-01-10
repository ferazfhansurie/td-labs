class Survey {
  // ignore: non_constant_identifier_names
  final int answer_id;
  // ignore: non_constant_identifier_names
  final int question_id;
  // ignore: non_constant_identifier_names
  final int is_deleted;
  String? answer;
// ignore: non_constant_identifier_names
  Survey({required this.answer_id, required this.question_id,  this.answer,required this.is_deleted});

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      answer_id: json['id'],
      question_id: json['question_id'],
      answer: json['answer'],
      is_deleted: json['is_deleted'],
    );
  }
}
