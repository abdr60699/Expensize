import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:expensize/screens/expenses.dart';
import 'package:expensize/models/expenses.dart';
import 'package:expensize/widgets/reusable_text_input.dart';

class AddScreen extends StatefulWidget {
  AddScreen({
    this.addData,
    super.key,
  });

  Function? addData;

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  String selectedCategory = Categorys[0];
  String? title;
  String? amount;
  String? formattedDate;

  DateTime selectedDates = DateTime.now();

  @override
  Widget build(BuildContext context) {
    formattedDate = DateFormat('dd-MMM-yyyy').format(selectedDates);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16, top: 25),
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ReusableTextInput(
              hintText: 'Title',
              textInput: (inputValue) {
                title = inputValue;
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              mainAxisAlignment: MainAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: ReusableTextInput(
                    hintText: '₹ 100',
                    textInput: (inputValue) {
                      amount = inputValue;
                    },
                  ),
                ),
                DropdownButton(
                    padding: const EdgeInsets.all(16),
                    value: selectedCategory,
                    items: Categorys.map(
                      (eachItem) => DropdownMenuItem(
                        value: eachItem,
                        child: Text(eachItem),
                      ),
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value.toString();
                      });
                    })
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(formattedDate.toString()),
                        IconButton(
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(2100));
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDates = pickedDate;
                                });
                              }
                            },
                            icon: const Icon(Icons.date_range)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer),
                      onPressed: () {
                        widget.addData!(
                            title: title,
                            amount: amount,
                            date: formattedDate,
                            category: selectedCategory);
                        Navigator.pop(context);
                      },
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
