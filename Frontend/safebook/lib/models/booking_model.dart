class BookingModel {
  final int id;
  final String serviceName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String status;

  const BookingModel({
    required this.id,
    required this.serviceName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      serviceName: json['serviceName'] as String,
      bookingDate: json['bookingDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as String,
    );
  }
}
