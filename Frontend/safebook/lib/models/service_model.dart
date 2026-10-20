class ServiceModel {
  final int id;
  final String name;
  final String description;
  final int durationMinutes;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int,
    );
  }
}
