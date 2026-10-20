import 'package:flutter/material.dart';

import '../widgets/date_time_selection_widget.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  const DateTimeSelectionScreen({super.key});

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  DateTime selectedDate = DateUtils.dateOnly(DateTime.now());
  String? selectedTime;

  bool isLoading = false;
  String? errorMessage;

  List<String> availableSlots = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
  ];

  void _onDateChanged(DateTime date) {
    setState(() {
      selectedDate = date;
      selectedTime = null;
    });

    // We will fetch available slots for this date
    // from the backend in the next step.
  }

  void _onTimeSelected(String time) {
    setState(() {
      selectedTime = time;
    });
  }

  void _onContinue() {
    if (selectedTime == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Selected $selectedTime on '
          '${selectedDate.day.toString().padLeft(2, '0')}/'
          '${selectedDate.month.toString().padLeft(2, '0')}/'
          '${selectedDate.year}',
        ),
      ),
    );

    // Next, we will navigate to the booking confirmation screen.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Date & Time')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: DateTimeSelectionWidget(
          selectedDate: selectedDate,
          availableSlots: availableSlots,
          selectedTime: selectedTime,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onDateChanged: _onDateChanged,
          onTimeSelected: _onTimeSelected,
          onContinue: _onContinue,
        ),
      ),
    );
  }
}
