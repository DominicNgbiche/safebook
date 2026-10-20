import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:safebook/constants/api_constants.dart';
import 'package:safebook/models/service_model.dart';
import 'package:safebook/screens/add_service_screen.dart';
import 'package:safebook/screens/my_bookings_screen.dart';
import 'package:safebook/screens/my_services_screen.dart';
import 'package:safebook/screens/services_screen.dart';

import 'package:http/http.dart' as https;
import 'package:safebook/widgets/service_preview_card.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key, required this.token});
  final String token;

  @override
  State<UserHomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<UserHomePage> {
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  Future<void> _fetchServices() async {
    try {
      final response = await https.get(Uri.parse(ApiConstants.services));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final services = data
            .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
            .toList();

        if (!mounted) return;

        setState(() {
          _services = services;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Book your next appointment with ease.',
              style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 24),

            // Quick actions grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  title: 'Create a Service',
                  icon: Icons.add_circle_outline,
                  color: const Color(0xFF2563EB),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddServiceScreen(token: widget.token),
                      ),
                    );
                  },
                ),

                _buildActionCard(
                  title: 'My Bookings',
                  icon: Icons.calendar_month_outlined,
                  color: const Color(0xFFF28C28),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MyBookingsScreen(token: widget.token),
                      ),
                    );
                  },
                ),

                _buildActionCard(
                  title: 'My Services',
                  icon: Icons.design_services_outlined,
                  color: const Color(0xFF16A34A),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MyServicesScreen(token: widget.token),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Available services heading and View All on the same line
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Available Services',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172033),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ServicesScreen(token: widget.token),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_services.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No services available yet.'),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _services.take(5).map((service) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 160,
                        child: ServicePreviewCard(
                          service: service,
                          token: widget.token,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Reusable card for the dashboard actions
  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF172033),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
