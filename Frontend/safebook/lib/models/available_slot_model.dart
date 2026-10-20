class AvailableSlotModel {
  final int id;
  final String startTime;
  final String endTime;
  final bool available;

  const AvailableSlotModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.available,
  });

  factory AvailableSlotModel.fromJson(Map<String, dynamic> json) {
    return AvailableSlotModel(
      id: json['id'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      available: json['available'] as bool,
    );
  }
}
