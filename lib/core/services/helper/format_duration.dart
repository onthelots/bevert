String formatDuration(int seconds) {
  final duration = Duration(seconds: seconds);
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  final secs = duration.inSeconds % 60;

  if (hours > 0) {
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(secs)}';
  } else {
    return '${twoDigits(minutes)}:${twoDigits(secs)}';
  }
}