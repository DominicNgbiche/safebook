import 'package:flutter/material.dart';

import 'package:http/http.dart' as https;
import 'package:safebook/constants/api_constants.dart';
import 'package:safebook/screens/admin_services_page.dart';
import 'package:safebook/widgets/build_stat_card.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key, required this.token});

  final String token;

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color secondaryOrange = Color(0xFFF28C28);
  static const Color successGreen = Color(0xFF16A34A);

  int? totalUsers;
  int? totalServices;
  int? totalBookings;

  bool isLoadingStats = true;
  String? statsError;

  Future<void> fetchDashboardStats() async {
    setState(() {
      isLoadingStats = true;
      statsError = null;
    });

    try {
      final headers = {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      };

      final responses = await Future.wait([
        https.get(Uri.parse(ApiConstants.adminUsersCount), headers: headers),
        https.get(Uri.parse(ApiConstants.adminServicesCount), headers: headers),
        https.get(Uri.parse(ApiConstants.adminBookingsCount), headers: headers),
      ]);

      for (final response in responses) {
        if (response.statusCode != 200) {
          throw Exception(
            'Failed to load statistics. HTTP ${response.statusCode}',
          );
        }
      }

      if (!mounted) return;

      setState(() {
        totalUsers = int.parse(responses[0].body);
        totalServices = int.parse(responses[1].body);
        totalBookings = int.parse(responses[2].body);
        isLoadingStats = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        statsError = 'Could not load dashboard statistics.';
        isLoadingStats = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'SafeBook Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Admin!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your booking platform from here.',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            const Text(
              'Overview',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            BuildStatCard(
              title: 'Total Users',
              value: isLoadingStats ? '-' : (totalUsers?.toString() ?? '--'),
              icon: Icons.people_outline,
              color: primaryBlue,
            ),
            const SizedBox(height: 12),

            BuildStatCard(
              title: 'Total Services',
              value: isLoadingStats ? '-' : (totalServices?.toString() ?? '--'),
              icon: Icons.miscellaneous_services_outlined,
              color: secondaryOrange,
            ),
            const SizedBox(height: 12),

            BuildStatCard(
              title: 'Total Bookings',
              value: isLoadingStats ? '-' : (totalBookings?.toString() ?? '--'),
              icon: Icons.calendar_month_outlined,
              color: successGreen,
            ),
            const SizedBox(height: 28),

            if (statsError != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statsError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: fetchDashboardStats,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Text(
              'Service Management',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'View your services and remove services when necessary.',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AdminServicesPage(token: widget.token),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Manage Services'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
