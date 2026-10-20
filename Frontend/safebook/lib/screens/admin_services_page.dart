import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;

import '../../constants/api_constants.dart';

class AdminServicesPage extends StatefulWidget {
  const AdminServicesPage({super.key, required this.token});

  final String token;

  @override
  State<AdminServicesPage> createState() => _AdminServicesPageState();
}

class _AdminServicesPageState extends State<AdminServicesPage> {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color secondaryOrange = Color(0xFFF28C28);
  static const Color successGreen = Color(0xFF16A34A);

  List<dynamic> services = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await https.get(
        Uri.parse(ApiConstants.adminServices),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load services: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Unexpected response from the server.');
      }

      if (!mounted) return;

      setState(() {
        services = decoded;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not load services. Please try again.';
        isLoading = false;
      });
    }
  }

  Future<void> deleteService(int serviceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete service?'),
        content: const Text(
          'Are you sure you want to delete this service? '
          'If it has existing bookings, it may be deactivated instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final response = await https.delete(
        Uri.parse(ApiConstants.adminDeleteService(serviceId)),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Request failed: ${response.statusCode}');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.body.isNotEmpty
                ? response.body
                : 'Service deleted or deactivated successfully.',
          ),
        ),
      );

      await fetchServices();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete the service. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Manage Services',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: fetchServices,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh services',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: fetchServices,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (services.isEmpty) {
      return const Center(child: Text('No services found.'));
    }

    return RefreshIndicator(
      onRefresh: fetchServices,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${services.length} service(s)',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...services.map((service) {
            final name = service['name']?.toString() ?? 'Unnamed service';
            final description = service['description']?.toString() ?? '';
            final duration = service['durationMinutes']?.toString() ?? '--';
            final active = service['active'] == true;

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFE8ECF3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (!active)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: secondaryOrange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Inactive',
                              style: TextStyle(
                                color: secondaryOrange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 18,
                          color: primaryBlue,
                        ),
                        const SizedBox(width: 6),
                        Text('$duration minutes'),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            final serviceId = service['id'];

                            if (serviceId is int) {
                              deleteService(serviceId);
                            }
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          tooltip: 'Delete service',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
