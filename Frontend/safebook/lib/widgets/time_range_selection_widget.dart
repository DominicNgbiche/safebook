import 'package:flutter/material.dart';

class TimeRangeSelectionWidget extends StatelessWidget {
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<TimeOfDay> onEndTimeChanged;

  const TimeRangeSelectionWidget({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  Future<void> _pickTime(
    BuildContext context, {
    required TimeOfDay? initialTime,
    required ValueChanged<TimeOfDay> onSelected,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onSelected(picked);
    }
  }

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select time';

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final invalidRange =
        startTime != null &&
        endTime != null &&
        _toMinutes(endTime!) <= _toMinutes(startTime!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Working Hours',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _TimeField(
                label: 'Start Time',
                value: _formatTime(startTime),
                onTap: () => _pickTime(
                  context,
                  initialTime: startTime,
                  onSelected: onStartTimeChanged,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TimeField(
                label: 'End Time',
                value: _formatTime(endTime),
                onTap: () => _pickTime(
                  context,
                  initialTime: endTime,
                  onSelected: onEndTimeChanged,
                ),
              ),
            ),
          ],
        ),

        if (invalidRange) ...[
          const SizedBox(height: 8),
          Text(
            'End time must be later than start time.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.schedule),
            label: Text(value),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
