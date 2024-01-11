import 'package:flutter/material.dart';

import 'package:expensize/screens/add.dart';


class ReusableButton extends StatelessWidget {
  const ReusableButton(
      {super.key,
      required this.widget,
      required this.title,
      required this.amount,
      required this.formattedDate,
      required this.selectedCategory,
      required this.btnTitle});

  final AddScreen widget;
  final String? title;
  final String? amount;
  final String formattedDate;
  final String selectedCategory;
  final String btnTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer),
        onPressed: () {
          widget.addData!(
              title: title,
              amount: amount,
              date: formattedDate,
              category: selectedCategory);
          Navigator.pop(context);
        },
        child: Text(btnTitle),
      ),
    );
  }
}


