import 'package:flutter/material.dart';
import 'package:safebook/models/service_model.dart';
import 'package:safebook/screens/booking_screen.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, required this.token});

  final ServiceModel service;
  final String token;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const darkText = Color(0xFF172033);
    const mutedText = Color(0xFF64748B);

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  BookingScreen(service: service, token: token),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/SafeBook Logo.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.calendar_month_rounded,
                      color: primaryBlue,
                      size: 30,
                    );
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: mutedText,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${service.durationMinutes} minutes',
                          style: const TextStyle(
                            fontSize: 13,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
