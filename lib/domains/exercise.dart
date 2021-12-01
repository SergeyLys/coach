import 'dart:convert';

class Exercise {
  int id;
  String name;
  Map<String, List<dynamic>> sets;
  String createdAt;
  String updatedAt;
  bool hasChanges = false;

  static Map<String, int> blankSet = {"w": 0, "r": 0};

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.createdAt,
    required this.updatedAt,
  });

  List<ParsedSet> setsToList() {
    return [
      new ParsedSet(new DateTime(2017, 9, 19), 5),
      new ParsedSet(new DateTime(2017, 9, 26), 25),
      new ParsedSet(new DateTime(2017, 10, 3), 100),
      new ParsedSet(new DateTime(2017, 10, 10), 75),
    ];
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
        id: json['id'] as int,
        name: json['name'] as String,
        updatedAt: json['updatedAt'] as String,
        createdAt: json['createdAt'] as String,
        sets: Map<String, List<dynamic>>.from(json['sets'])
    );
  }
}

class ParsedSet {
  final DateTime date;
  final int weight;

  ParsedSet(this.date, this.weight);
}