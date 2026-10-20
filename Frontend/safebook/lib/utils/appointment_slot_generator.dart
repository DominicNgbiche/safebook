import 'package:safebook/models/appointment_slot.dart';

class AppointmentSlotGenerator {
  static List<AppointmentSlot> generate({
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required int durationMinutes,
  }) {
    if (durationMinutes <= 0) {
      throw ArgumentError('Duration must be greater than zero.');
    }

    final start = startHour * 60 + startMinute;
    final end = endHour * 60 + endMinute;

    if (start < 0 ||
        start >= 24 * 60 ||
        end < 0 ||
        end >= 24 * 60 ||
        end <= start) {
      throw ArgumentError('Invalid working time range.');
    }

    final slots = <AppointmentSlot>[];

    for (
      var slotStart = start;
      slotStart + durationMinutes <= end;
      slotStart += durationMinutes
    ) {
      final slotEnd = slotStart + durationMinutes;

      slots.add(
        AppointmentSlot(
          startTime: _formatTime(slotStart),
          endTime: _formatTime(slotEnd),
        ),
      );
    }

    return slots;
  }

  static String _formatTime(int totalMinutes) {
    final hour = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minute = (totalMinutes % 60).toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}
