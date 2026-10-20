import 'package:flutter/material.dart';
import 'package:safebook/models/service_model.dart';
import 'package:safebook/screens/booking_screen.dart';

class ServicePreviewCard extends StatelessWidget {
  const ServicePreviewCard({
    super.key,
    required this.service,
    required this.token,
  });

  final ServiceModel service;
  final String token;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingScreen(service: service, token: token),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/SafeBook Logo.png',
                width: 40,
                height: 40,
              ),

              const SizedBox(height: 12),

              Text(
                service.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text('${service.durationMinutes} minutes'),
            ],
          ),
        ),
      ),
    );
  }
}
