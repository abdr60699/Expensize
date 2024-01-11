import 'package:flutter/material.dart';

class ReusableTextInput extends StatelessWidget {
  ReusableTextInput({
    this.controller,
    required this.hintText,
    required this.textInput,
    super.key,
  });

  void Function(String) textInput;
  String hintText;
  TextEditingController? controller;

  bool containsInteger(String input) {
  RegExp digitRegex = RegExp(r'\d');
  return digitRegex.hasMatch(input);
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        keyboardType: containsInteger(hintText) ? TextInputType.number : null,
        maxLines: null,
        controller: controller,
        onChanged: textInput,
        decoration: InputDecoration(
          hintText: hintText,
          helperStyle:
              TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
      ),
    );
  }
}
