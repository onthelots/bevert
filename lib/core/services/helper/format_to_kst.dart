import 'package:intl/intl.dart';

String formatToKST(DateTime utcTime) {
  final kst = utcTime.toLocal();
  return DateFormat('a hh:mm', 'ko').format(kst);
}