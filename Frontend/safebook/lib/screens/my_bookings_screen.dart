import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:safebook/constants/api_constants.dart';
import 'package:safebook/models/booking_model.dart';

class MyBookingsScreen extends StatefulWidget {
  final String token;

  const MyBookingsScreen({super.key, required this.token});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  Future<void> _cancelBooking(int bookingId) async {
    try {
      final response = await https.delete(
        Uri.parse(ApiConstants.cancelBooking(bookingId)),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _fetchBookings();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not cancel booking (${response.statusCode}).'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong while cancelling.')),
      );

      debugPrint('Error cancelling booking: $e');
    }
  }

  Future<void> _fetchBookings() async {
    try {
      final response = await https.get(
        Uri.parse('${ApiConstants.bookings}/my'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        debugPrint('My bookings API response: ${response.body}');

        final bookings = data
            .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
            .toList();

        bookings.sort((a, b) {
          if (a.status == 'CONFIRMED' && b.status == 'CANCELLED') {
            return -1;
          }

          if (a.status == 'CANCELLED' && b.status == 'CONFIRMED') {
            return 1;
          }

          return 0;
        });

        setState(() {
          _bookings = bookings;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load bookings (${response.statusCode}).';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong while loading bookings.';
      });

      debugPrint('Error fetching bookings: $e');
    }
  }

  String _formatTime(String time) {
    return time.length >= 5 ? time.substring(0, 5) : time;
  }

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_errorMessage!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      _fetchBookings();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : _bookings.isEmpty
          ? const Center(child: Text('You have no bookings yet.'))
          : RefreshIndicator(
              onRefresh: _fetchBookings,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final booking = _bookings[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.serviceName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, size: 20),
                              const SizedBox(width: 8),
                              Text(booking.bookingDate),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${_formatTime(booking.startTime)}'
                                ' - '
                                '${_formatTime(booking.endTime)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Chip(
                            label: Text(booking.status),
                            backgroundColor: booking.status == 'CANCELLED'
                                ? Colors.red.shade100
                                : booking.status == 'CONFIRMED'
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                            labelStyle: TextStyle(
                              color: booking.status == 'CANCELLED'
                                  ? Colors.red.shade900
                                  : booking.status == 'CONFIRMED'
                                  ? Colors.green.shade900
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (booking.status != 'CANCELLED') ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                  side: BorderSide(color: Colors.red.shade200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final shouldCancel = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      icon: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.event_busy_outlined,
                                          color: Color(0xFFDC2626),
                                          size: 30,
                                        ),
                                      ),
                                      title: const Text(
                                        'Cancel this booking?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                          color: Color(0xFF172033),
                                        ),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to cancel your appointment? '
                                        'This action cannot be undone.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          height: 1.5,
                                        ),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actionsPadding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        20,
                                        20,
                                      ),
                                      actions: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(
                                                0xFF2563EB,
                                              ),
                                              side: const BorderSide(
                                                color: Color(0xFFE2E8F0),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 13,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () => Navigator.pop(
                                              dialogContext,
                                              false,
                                            ),
                                            child: const Text('Keep Booking'),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFDC2626,
                                              ),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 13,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () => Navigator.pop(
                                              dialogContext,
                                              true,
                                            ),
                                            child: const Text(
                                              'Yes, Cancel Booking',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (shouldCancel == true) {
                                    await _cancelBooking(booking.id);
                                  }
                                },
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Cancel Booking'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
