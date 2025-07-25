import 'package:intl/intl.dart';

String formatToKST(DateTime utcTime) {
  final kst = utcTime.toLocal(); // 시스템 타임존이 KST면 자동으로 KST
  return DateFormat('yyyy-MM-dd HH:mm').format(kst);
}