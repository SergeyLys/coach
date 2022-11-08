class RepsModel {
  int? id;
  int? weight;
  int? reps;
  int order;

  RepsModel({this.id, required this.weight, required this.reps, required this.order});

  factory RepsModel.fromJson(Map<String, dynamic> json) {
    return RepsModel(
        id: json['id'],
        weight: json['weight'],
        reps: json['reps'],
        order: json['order'],
    );
  }
}

class SetsModel {
  int? id;
  String date;
  List<RepsModel> reps;
  bool isChanged = false;
  bool isVirtual = false;
  bool isDeactivated = false;


  SetsModel({this.id, required this.date, required this.reps});

  factory SetsModel.fromJson(Map<String, dynamic> json) {
    return SetsModel(
        id: json['id'],
        date: json['date'],
        reps: json['reps'].map<RepsModel>((element) => RepsModel.fromJson(element)).toList(),
    );
  }
}
