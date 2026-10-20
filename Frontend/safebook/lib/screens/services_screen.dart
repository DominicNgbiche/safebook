import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:safebook/constants/api_constants.dart';
import 'package:safebook/models/service_model.dart';
import 'package:safebook/widgets/service_card.dart';
import 'package:http/http.dart' as https;

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key, required this.token});

  final String token;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<ServiceModel> _services = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
        throw Exception('Failed to load services (${response.statusCode}).');
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('Error fetching services: $e');

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load services. Please try again.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    final filteredServices = _services.where((service) {
      return service.name.toLowerCase().contains(
        _searchQuery.trim().toLowerCase(),
      );
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Explore Services',
          style: TextStyle(
            color: Color(0xFF172033),
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find the right service for you.',
                    style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for services',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF2563EB),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: const Expanded(
                child: Text(
                  'Available Services',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                      ),
                    )
                  : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_outlined,
                              size: 48,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchServices,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : filteredServices.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 52,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No services available yet.'
                                  : 'No services match your search.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchServices,
                      color: const Color(0xFF2563EB),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filteredServices.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final service = filteredServices[index];

                          return ServiceCard(
                            service: service,
                            token: widget.token,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
