class CountryState {
  final String code;
  final String name;
  int? index;

  CountryState({required this.code, required this.name, this.index});

  factory CountryState.fromJson(Map<String, dynamic> json) {
    return CountryState(
      code: json['code'],
      name: json['name'],
      index: json['index'],
    );
  }
}
