import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatTime(DateTime t) => DateFormat('dd/MM/yyyy HH:mm').format(t);

/// Chọn ngày rồi chọn giờ. Trả về null nếu người dùng huỷ.
Future<DateTime?> pickDateTime(BuildContext context, {DateTime? initial}) async {
  final now = DateTime.now();
  final date = await showDatePicker(
    context: context,
    initialDate: initial ?? now,
    firstDate: DateTime(now.year, now.month, now.day),
    lastDate: DateTime(2100),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial ?? now),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}