const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Formats a date as "Wed, Jul 9" without pulling in the intl package.
String formatShortDate(DateTime date) {
  return '${_weekdays[date.weekday - 1]}, ${_months[date.month - 1]} ${date.day}';
}

/// Formats a timestamp relative to now, e.g. "Just now", "5m", "3h", "2d".
/// Falls back to [formatShortDate] beyond a week.
String formatRelativeShort(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return formatShortDate(dateTime);
}
