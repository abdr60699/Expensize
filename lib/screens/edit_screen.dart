import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:expensize/widgets/reusable_text_input.dart';
import 'package:expensize/widgets/reusable_button.dart';
import 'package:expensize/models/expenses.dart';

class EditScreen extends StatefulWidget {
  EditScreen(
      {super.key,
      this.editData,
      required this.resTitle,
      required this.resAmount,
      required this.resCategory,
      required this.resDate});

  String resTitle;
  String resCategory;
  String resAmount;
  String resDate;
  Function? editData;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController _title = TextEditingController();
  TextEditingController _amount = TextEditingController();

  String selectedCategory = Categorys[0];
  DateTime _selectedDates = DateTime.now();
  String formattedDate = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _title.text = widget.resTitle;
    _amount.text = widget.resAmount;
    selectedCategory = widget.resCategory;
    formattedDate = widget.resDate;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _title.dispose();
    _amount.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              controller: _title,
              hintText: 'Title',
              textInput: (inputValue) {
                // _title = inputValue;
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              mainAxisAlignment: MainAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: ReusableTextInput(
                    controller: _amount,
                    hintText: '₹ 100',
                    textInput: (inputValue) {},
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
                        Text(formattedDate),
                        IconButton(
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(2100));
                              if (pickedDate != null) {
                                setState(() {
                                  _selectedDates = pickedDate;
                                  formattedDate = DateFormat('dd/MM/yyyy')
                                      .format(_selectedDates);
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
                        widget.editData!(
                            title: _title.text,
                            amount: _amount.text,
                            category: selectedCategory,
                            date: formattedDate);

                        Navigator.pop(context);
                      },
                      child: Text('Update'),
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
