class TravelTagModel {
  final int id;
  final String name;

  const TravelTagModel({required this.id, required this.name});

  factory TravelTagModel.fromJson(Map<String, dynamic> json) {
    return TravelTagModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
