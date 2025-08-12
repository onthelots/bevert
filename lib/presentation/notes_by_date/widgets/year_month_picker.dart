import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class YearMonthPicker extends StatefulWidget {
  final DateTime initialDate;

  const YearMonthPicker({required this.initialDate});

  @override
  _YearMonthPickerState createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<YearMonthPicker> {
  late int selectedYear;
  late int selectedMonth;
  late FixedExtentScrollController monthController;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
    monthController = FixedExtentScrollController(initialItem: selectedMonth - 1);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int maxMonths = (selectedYear == now.year) ? now.month : 12;

    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text('취소'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.pop(context, DateTime(selectedYear, selectedMonth));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedYear - 2020,
                    ),
                    itemExtent: 32.0,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        selectedYear = 2020 + index;
                        maxMonths = (selectedYear == now.year) ? now.month : 12;
                        if (selectedMonth > maxMonths) {
                          selectedMonth = maxMonths;
                          monthController.animateToItem(selectedMonth - 1, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
                        }
                      });
                    },
                    children: List<Widget>.generate(now.year - 2020 + 1, (int index) {
                      return Center(child: Text('${2020 + index}년'));
                    }),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: monthController,
                    itemExtent: 32.0,
                    onSelectedItemChanged: (int index) {
                      selectedMonth = index + 1;
                    },
                    children: List<Widget>.generate(maxMonths, (int index) {
                      return Center(child: Text('${index + 1}월'));
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}