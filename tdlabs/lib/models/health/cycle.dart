// ignore_for_file: file_names

class Cycle {
  final int id;
  final String name;

  Cycle({required this.id, required this.name, });

  factory Cycle.fromJson(Map<String, dynamic> json) {
    return Cycle(
      id: json['id'],
      name: json['name'],
    );
  }
}
