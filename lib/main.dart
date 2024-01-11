import 'package:flutter/material.dart';

import 'package:expensize/screens/expenses.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlueAccent.withOpacity(0.1),
        ),
      ),
      home:  ExpensesScreen(),
    );
  }
}
