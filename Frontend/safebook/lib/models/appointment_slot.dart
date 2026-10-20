class AppointmentSlot {
  final String startTime;
  final String endTime;

  const AppointmentSlot({required this.startTime, required this.endTime});

  @override
  String toString() => '$startTime - $endTime';
}
