import 'package:flutter/material.dart';

class DateTimeSelectionWidget extends StatefulWidget {
  final List<String> availableSlots;
  final DateTime selectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? selectedTime;
  final bool isLoading;
  final String? errorMessage;

  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onTimeSelected;
  final VoidCallback onContinue;

  const DateTimeSelectionWidget({
    super.key,
    required this.availableSlots,
    required this.selectedDate,
    this.firstDate,
    this.lastDate,
    this.selectedTime,
    this.isLoading = false,
    this.errorMessage,
    required this.onDateChanged,
    required this.onTimeSelected,
    required this.onContinue,
  });

  Future<void> _selectDate(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());

    final first = firstDate ?? today;
    final last = lastDate ?? today.add(const Duration(days: 365));

    final initial = selectedDate.isBefore(first)
        ? first
        : selectedDate.isAfter(last)
        ? last
        : selectedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: 'Choose appointment date',
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }

  @override
  State<DateTimeSelectionWidget> createState() =>
      _DateTimeSelectionWidgetState();
}

class _DateTimeSelectionWidgetState extends State<DateTimeSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Date',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => widget._selectDate(context),
            icon: const Icon(Icons.calendar_today),
            label: Text(
              '${widget.selectedDate.day.toString().padLeft(2, '0')}/'
              '${widget.selectedDate.month.toString().padLeft(2, '0')}/'
              '${widget.selectedDate.year}',
            ),
            style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Available Times',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        if (widget.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (widget.errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.errorMessage!,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          )
        else if (widget.availableSlots.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.event_busy, size: 36),
                SizedBox(height: 8),
                Text(
                  'No available times for this date.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'Please choose another date.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.availableSlots.map((slot) {
              final isSelected = widget.selectedTime == slot;

              return ChoiceChip(
                label: Text(slot),
                selected: isSelected,
                onSelected: (_) => widget.onTimeSelected(slot),
              );
            }).toList(),
          ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed:
                widget.selectedTime == null ||
                    widget.isLoading ||
                    widget.errorMessage != null ||
                    widget.availableSlots.isEmpty
                ? null
                : widget.onContinue,
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}
