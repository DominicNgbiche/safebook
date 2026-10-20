import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:safebook/constants/api_constants.dart';
import 'package:safebook/models/available_slot_model.dart';
import 'package:safebook/models/service_model.dart';
import 'package:http/http.dart' as https;

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.service, required this.token});

  final ServiceModel service;
  final String token;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const blue = Color(0xFF2563EB);
  static const orange = Color(0xFFF28C28);
  static const green = Color(0xFF16A34A);
  static const background = Color(0xFFF5F7FB);

  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  List<AvailableSlotModel> _slots = [];
  AvailableSlotModel? _selectedSlot;
  bool _isLoading = true;
  bool _isBooking = false;

  String get _date =>
      '${_selectedDate.year}-'
      '${_selectedDate.month.toString().padLeft(2, '0')}-'
      '${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _fetchSlots() async {
    setState(() {
      _isLoading = true;
      _selectedSlot = null;
    });

    final uri = Uri.parse(ApiConstants.availableSlots).replace(
      queryParameters: {
        'date': _date,
        'serviceId': widget.service.id.toString(),
      },
    );

    try {
      final response = await https.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _slots = data
              .map(
                (json) =>
                    AvailableSlotModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _slots = [];
          _isLoading = false;
        });

        debugPrint('Failed to load slots: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _slots = [];
        _isLoading = false;
      });

      debugPrint('Error fetching slots: $e');
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateUtils.dateOnly(
        DateTime.now().add(const Duration(days: 365)),
      ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: blue,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF172033),
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      _selectedDate = DateUtils.dateOnly(pickedDate);
    });

    await _fetchSlots();
  }

  Future<void> _createBooking() async {
    if (_selectedSlot == null || _isBooking) return;

    setState(() => _isBooking = true);

    try {
      final response = await https.post(
        Uri.parse(ApiConstants.bookings),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'serviceId': widget.service.id,
          'bookingDate': _date,
          'startTime': _selectedSlot!.startTime,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking confirmed successfully!'),
            backgroundColor: green,
          ),
        );

        await _fetchSlots();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking failed. Please try another time slot.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to complete booking. Check your connection.'),
        ),
      );

      debugPrint('Error creating booking: $e');
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  @override
  Widget build(BuildContext context) {
    final availableCount = _slots.where((slot) => slot.available).length;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Book Appointment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Choose your appointment',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 26),

                  const Text(
                    'Appointment date',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/'
                      '${_selectedDate.month.toString().padLeft(2, '0')}/'
                      '${_selectedDate.year}',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: blue,
                      backgroundColor: Colors.white,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),

                  const Expanded(
                    child: Text(
                      'Available time slots',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172033),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(color: blue),
                      ),
                    )
                  else if (_slots.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy_rounded,
                              size: 42,
                              color: Color(0xFF94A3B8),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No time slots available for this date.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _slots.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.65,
                          ),
                      itemBuilder: (context, index) {
                        final slot = _slots[index];
                        final selected = _selectedSlot?.id == slot.id;

                        final color = !slot.available
                            ? const Color(0xFF94A3B8)
                            : selected
                            ? blue
                            : const Color(0xFFE2E8F0);

                        return InkWell(
                          onTap: slot.available
                              ? () => setState(() => _selectedSlot = slot)
                              : null,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: !slot.available
                                  ? const Color(0xFFF1F5F9)
                                  : selected
                                  ? blue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: color,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${slot.startTime.substring(0, 5)} - '
                                  '${slot.endTime.substring(0, 5)}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: !slot.available
                                        ? const Color(0xFF64748B)
                                        : selected
                                        ? Colors.white
                                        : const Color(0xFF172033),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  !slot.available
                                      ? 'Unavailable'
                                      : selected
                                      ? 'Selected'
                                      : 'Available',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: !slot.available
                                        ? const Color(0xFF64748B)
                                        : selected
                                        ? Colors.white
                                        : green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedSlot == null || _isBooking || _isLoading
                      ? null
                      : _createBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isBooking
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Confirm Booking',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
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
