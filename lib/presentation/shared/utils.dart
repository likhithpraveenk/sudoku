import 'package:intl/intl.dart';

String formatTime(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;

  final parts = <String>[];

  if (h > 0) parts.add('${h}h');
  if (m > 0) parts.add('${m}m');

  parts.add('${s}s');

  return parts.join(' ');
}

// user preference?
String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}
