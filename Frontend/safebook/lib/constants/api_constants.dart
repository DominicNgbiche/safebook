class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static const String signup = '$baseUrl/api/auth/signup';
  static const String verifyEmail = '$baseUrl/api/auth/verify';
  static const String signin = '$baseUrl/api/auth/login';

  static const String services = '$baseUrl/api/services';

  static const String availableSlots = '$baseUrl/api/bookings/available';
  static const String bookings = '$baseUrl/api/bookings';
  static const String myBookings = '$baseUrl/api/bookings/my';
  static String cancelBooking(int bookingId) => '$bookings/$bookingId/cancel';

  // Admin dashboard
  static const String adminUsersCount = '$baseUrl/api/admin/users/count';

  static const String adminServicesCount = '$baseUrl/api/admin/services/count';

  static const String adminBookingsCount = '$baseUrl/api/admin/bookings/count';

  static const String adminServices = '$baseUrl/api/admin/services';

  static String adminDeleteService(int serviceId) =>
      '$adminServices/$serviceId';
}
