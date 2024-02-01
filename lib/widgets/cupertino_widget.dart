import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import 'package:expensize/widgets/reusable_home_cards.dart';

class CupertinoWidget extends StatefulWidget {
  CupertinoWidget({
    super.key,
    required this.selectedMonths,
  });

  Function selectedMonths;

  @override
  State<CupertinoWidget> createState() => _CupertinoWidgetState();
}

class _CupertinoWidgetState extends State<CupertinoWidget> {
  @override
  void initState() {
    super.initState();
    yearMonthFun();
    widget.selectedMonths(formatThisMonth!);
  }

  final today = DateTime.now();
  String? formatThisMonth;

  int indexOfThisMonth = 0;
  List<String> yearsMonths = [];
  bool isUpdateDropDown = false;

  List<String>? yearMonthFun() {
    final currentYear = today.year;

    for (var tenYearsMinus = -10; tenYearsMinus <= 60; tenYearsMinus++) {
      for (var months = 1; months <= 12; months++) {
        final date = DateTime(currentYear + tenYearsMinus, months);
        final formatDate = DateFormat('MMM-yyyy').format(date);
        yearsMonths.add(formatDate);
      }
    }
    formatThisMonth = DateFormat('MMM-yyyy').format(today);
    indexOfThisMonth = yearsMonths.indexOf(formatThisMonth!);
    return yearsMonths;
  }

  @override
  Widget build(BuildContext context) {
    return ReusableHomeCards(
      headTitle: 'Months',
      cupertinoPicker: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: DropdownButton(
              value: formatThisMonth,
              items: yearsMonths
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  formatThisMonth = value;
                  widget.selectedMonths(formatThisMonth);
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}


   // CupertinoPicker(
          //     selectionOverlay: AnimatedContainer(
          //       duration: Duration(milliseconds: 500),
          //       curve: Curves.easeInOut,
          //     ),
          //     diameterRatio: 1,
          //     scrollController:
          //         FixedExtentScrollController(initialItem: widget.cupertinoTrigger ?? indexOfThisMonth ),
          //     itemExtent: 40,
          //     onSelectedItemChanged: (index) {
          //       widget.selectedMonths(yearsMonths[index]);
          //     },
          //     children: [
          //       ...yearMonthFun()!.map(
          //         (dates) => Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Text(dates),
          //         ),
          //       ),
          //     ]),