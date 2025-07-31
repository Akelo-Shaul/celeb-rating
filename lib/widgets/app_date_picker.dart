import 'package:flutter/material.dart';

class CustomDatePicker {
  static Future<DateTime?> show(BuildContext context, {DateTime? initialDate, DateTime? firstDate, DateTime? lastDate}) async {
    final now = DateTime.now();
    final DateTime start = firstDate ?? DateTime(now.year - 100, 1, 1);
    final DateTime end = lastDate ?? now;
    DateTime selected = initialDate ?? DateTime(now.year, now.month, now.day);

    return await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return _DatePickerDialog(
          start: start,
          end: end,
          initialDate: selected,
        );
      },
    );
  }

  static String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

class _DatePickerDialog extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  final DateTime initialDate;
  const _DatePickerDialog({required this.start, required this.end, required this.initialDate});

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController dayController;
  late FixedExtentScrollController yearController;

  @override
  void initState() {
    super.initState();
    monthController = FixedExtentScrollController(initialItem: widget.initialDate.month - 1);
    dayController = FixedExtentScrollController(initialItem: widget.initialDate.day - 1);
    yearController = FixedExtentScrollController(initialItem: widget.initialDate.year - widget.start.year);
  }

  @override
  void dispose() {
    monthController.dispose();
    dayController.dispose();
    yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int selectedMonth = monthController.hasClients ? monthController.selectedItem + 1 : widget.initialDate.month;
    int selectedYear = yearController.hasClients ? widget.start.year + yearController.selectedItem : widget.initialDate.year;
    int daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    int selectedDay = dayController.hasClients ? (dayController.selectedItem + 1).clamp(1, daysInMonth) : widget.initialDate.day;
    // If the selected day is out of range for the new month/year, jump to the last valid day
    if (dayController.hasClients && selectedDay > daysInMonth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dayController.jumpToItem(daysInMonth - 1);
      });
      selectedDay = daysInMonth;
    }
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: 340,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Month
                    SizedBox(
                      width: 90,
                      height: 200, // 5 items * 40
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        controller: monthController,
                        onSelectedItemChanged: (i) {
                          setState(() {});
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (ctx, i) => Center(
                            child: Text(
                              CustomDatePicker._monthName(i + 1),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: i + 1 == selectedMonth ? FontWeight.bold : FontWeight.normal,
                                color: i + 1 == selectedMonth ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                          childCount: 12,
                        ),
                      ),
                    ),
                    // Day
                    SizedBox(
                      width: 60,
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        controller: dayController,
                        onSelectedItemChanged: (i) {
                          setState(() {});
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (ctx, i) => Center(
                            child: Text(
                              "${i + 1}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: i + 1 == selectedDay ? FontWeight.bold : FontWeight.normal,
                                color: i + 1 == selectedDay ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                          childCount: daysInMonth,
                        ),
                      ),
                    ),
                    // Year
                    SizedBox(
                      width: 80,
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        controller: yearController,
                        onSelectedItemChanged: (i) {
                          setState(() {});
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (ctx, i) => Center(
                            child: Text(
                              "${widget.start.year + i}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: widget.start.year + i == selectedYear ? FontWeight.bold : FontWeight.normal,
                                color: widget.start.year + i == selectedYear ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                          childCount: widget.end.year - widget.start.year + 1,
                        ),
                      ),
                    ),
                  ],
                ),
                // Selection overlay
                Positioned(
                  left: 0,
                  right: 0,
                  top: 80, // (200 - 40) / 2
                  child: IgnorePointer(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(DateTime(selectedYear, selectedMonth, selectedDay));
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 