import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:safebook/constants/api_constants.dart';
import 'package:safebook/models/appointment_slot.dart';
import 'package:safebook/utils/appointment_slot_generator.dart';
import 'package:safebook/widgets/time_range_selection_widget.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key, required this.token});

  final String token;

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color secondaryOrange = Color(0xFFF28C28);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color pageBackground = Color(0xFFF5F7FB);
  static const Color borderColor = Color(0xFFE5EAF2);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  int _durationMinutes = 30;
  final List<int> _durations = [15, 30, 45, 60, 90, 120];

  String _availabilityType = 'dateRange';
  DateTime? _startDate;
  DateTime? _endDate;

  final Set<int> _selectedDays = {1, 2, 3, 4, 5};

  bool _isSubmitting = false;

  List<AppointmentSlot> get _generatedSlots {
    if (_startTime == null || _endTime == null) return [];

    try {
      return AppointmentSlotGenerator.generate(
        startHour: _startTime!.hour,
        startMinute: _startTime!.minute,
        endHour: _endTime!.hour,
        endMinute: _endTime!.minute,
        durationMinutes: _durationMinutes,
      );
    } on ArgumentError {
      return [];
    }
  }

  List<DateTime> _generateServiceDates() {
    final dates = <DateTime>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_availabilityType == 'dateRange') {
      if (_startDate == null ||
          _endDate == null ||
          _endDate!.isBefore(_startDate!)) {
        return [];
      }

      for (
        var date = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );
        !date.isAfter(_endDate!);
        date = date.add(const Duration(days: 1))
      ) {
        if (!date.isBefore(today)) {
          dates.add(date);
        }
      }
    } else {
      if (_selectedDays.isEmpty) return [];

      for (var i = 0; i < 30; i++) {
        final date = today.add(Duration(days: i));

        if (_selectedDays.contains(date.weekday)) {
          dates.add(date);
        }
      }
    }

    return dates;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickStartDate() async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? todayOnly,
      firstDate: todayOnly,
      lastDate: todayOnly.add(const Duration(days: 365)),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _startDate = picked;

      if (_endDate != null && _endDate!.isBefore(picked)) {
        _endDate = null;
      }
    });
  }

  Future<void> _pickEndDate() async {
    if (_startDate == null) return;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: todayOnly.add(const Duration(days: 365)),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _endDate = picked;
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? Colors.red.shade700 : successGreen,
        ),
      );
  }

  Future<void> _addService() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    if (_startTime == null || _endTime == null) {
      _showMessage('Please select the service working hours.', isError: true);
      return;
    }

    if (_generatedSlots.isEmpty) {
      _showMessage(
        'Choose valid working hours that fit at least one appointment.',
        isError: true,
      );
      return;
    }

    if (_availabilityType == 'dateRange' &&
        (_startDate == null ||
            _endDate == null ||
            _endDate!.isBefore(_startDate!))) {
      _showMessage('Please select a valid start and end date.', isError: true);
      return;
    }

    if (_availabilityType == 'weekdays' && _selectedDays.isEmpty) {
      _showMessage('Select at least one day of the week.', isError: true);
      return;
    }

    final serviceDates = _generateServiceDates();

    if (serviceDates.isEmpty) {
      _showMessage(
        'No available dates were selected. Please check your availability.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await https.post(
        Uri.parse(ApiConstants.services),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'durationMinutes': _durationMinutes,
          'startTime':
              '${_startTime!.hour.toString().padLeft(2, '0')}:'
              '${_startTime!.minute.toString().padLeft(2, '0')}:00',
          'endTime':
              '${_endTime!.hour.toString().padLeft(2, '0')}:'
              '${_endTime!.minute.toString().padLeft(2, '0')}:00',
          'slots': serviceDates.expand((date) {
            return _generatedSlots.map((slot) {
              return {
                'slotDate':
                    '${date.year.toString().padLeft(4, '0')}-'
                    '${date.month.toString().padLeft(2, '0')}-'
                    '${date.day.toString().padLeft(2, '0')}',
                'startTime': '${slot.startTime}:00',
                'endTime': '${slot.endTime}:00',
              };
            });
          }).toList(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        _showMessage('Service created successfully!');
        Navigator.pop(context, true);
      } else {
        final body = response.body.trim();
        _showMessage(
          body.isNotEmpty
              ? body
              : 'Could not create service. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('CREATE SERVICE ERROR: $e');

      if (!mounted) return;

      _showMessage(
        'Could not connect to the server. Check your connection.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Add Service',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              _buildSection(
                number: '01',
                title: 'Service details',
                subtitle: 'Tell customers what they can book.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Service name'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 100,
                      decoration: _inputDecoration(
                        hint: 'e.g. Basic Consultation',
                        icon: Icons.work_outline_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a service name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Description'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      maxLength: 500,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        hint: 'Describe what this service includes.',
                        icon: Icons.notes_rounded,
                      ).copyWith(alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 12),
                    _buildFieldLabel('Appointment duration'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _durations.map((duration) {
                        final selected = _durationMinutes == duration;

                        return ChoiceChip(
                          label: Text('$duration min'),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: primaryBlue,
                          backgroundColor: const Color(0xFFF5F7FB),
                          side: BorderSide(
                            color: selected ? primaryBlue : borderColor,
                          ),
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF344054),
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _durationMinutes = duration;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _buildSection(
                number: '02',
                title: 'Working hours',
                subtitle: 'Choose when customers can book.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TimeRangeSelectionWidget(
                      startTime: _startTime,
                      endTime: _endTime,
                      onStartTimeChanged: (time) {
                        setState(() {
                          _startTime = time;
                        });
                      },
                      onEndTimeChanged: (time) {
                        setState(() {
                          _endTime = time;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildSlotPreview(),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _buildSection(
                number: '03',
                title: 'Service availability',
                subtitle: 'Choose which dates customers can book.',
                child: Column(
                  children: [
                    _buildAvailabilityOption(
                      value: 'dateRange',
                      title: 'Date range',
                      subtitle: 'Offer appointments between two dates.',
                      icon: Icons.date_range_rounded,
                    ),
                    if (_availabilityType == 'dateRange') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateButton(
                              label: 'Start date',
                              date: _startDate,
                              onPressed: _pickStartDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDateButton(
                              label: 'End date',
                              date: _endDate,
                              onPressed: _pickEndDate,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildAvailabilityOption(
                      value: 'weekdays',
                      title: 'Days of the week',
                      subtitle: 'Repeat your availability over 30 days.',
                      icon: Icons.calendar_view_week_rounded,
                    ),
                    if (_availabilityType == 'weekdays') ...[
                      const SizedBox(height: 12),
                      _buildWeekdaySelector(),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 26),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _addService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: primaryBlue.withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline_rounded),
                            SizedBox(width: 10),
                            Text(
                              'Create service',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Review the service details and availability before creating it.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.add_business_rounded, color: Colors.white, size: 32),
          SizedBox(height: 18),
          Text(
            'Create a new service',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Set up your service, choose its duration, and define when appointments are available.',
            style: TextStyle(
              color: Color(0xFFE0EAFF),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172033),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF344054),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF98A2B3)),
      prefixIcon: Icon(icon, color: const Color(0xFF667085), size: 21),
      filled: true,
      fillColor: const Color(0xFFFAFBFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      counterStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback? onPressed,
  }) {
    final hasDate = date != null;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(13),
        foregroundColor: primaryBlue,
        side: const BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 17),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hasDate ? _formatDate(date) : 'Select date',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: hasDate
                        ? const Color(0xFF172033)
                        : const Color(0xFF98A2B3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _availabilityType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _availabilityType = value;
        });
      },
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected
              ? primaryBlue.withValues(alpha: 0.05)
              : const Color(0xFFFAFBFD),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? primaryBlue : borderColor,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? primaryBlue.withValues(alpha: 0.1)
                    : const Color(0xFFEEF1F6),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: selected ? primaryBlue : const Color(0xFF667085),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? primaryBlue : const Color(0xFF98A2B3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdaySelector() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: List.generate(7, (index) {
          final day = index + 1;
          final selected = _selectedDays.contains(day);

          return CheckboxListTile(
            value: selected,
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _selectedDays.add(day);
                } else {
                  _selectedDays.remove(day);
                }
              });
            },
            activeColor: primaryBlue,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            dense: true,
            title: Text(
              days[index],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF344054),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSlotPreview() {
    if (_startTime == null || _endTime == null) {
      return _buildSlotMessage(
        icon: Icons.info_outline_rounded,
        message: 'Select your start and end times to preview appointments.',
      );
    }

    if (_generatedSlots.isEmpty) {
      return _buildSlotMessage(
        icon: Icons.warning_amber_rounded,
        message: 'No complete appointments fit within these working hours.',
        warning: true,
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: successGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: successGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: successGreen,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_generatedSlots.length} appointments per available day',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: successGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _generatedSlots.map((slot) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: successGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '${slot.startTime} – ${slot.endTime}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF344054),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotMessage({
    required IconData icon,
    required String message,
    bool warning = false,
  }) {
    final color = warning ? secondaryOrange : const Color(0xFF667085);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: warning
            ? secondaryOrange.withValues(alpha: 0.07)
            : const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: warning ? secondaryOrange.withValues(alpha: 0.2) : borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, height: 1.5, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
