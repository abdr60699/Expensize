import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:expensize/screens/expenses.dart';
import 'package:hive_flutter/adapters.dart';
// import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final documentDir = await getApplicationDocumentsDirectory();

  await Hive.initFlutter();
  await Hive.openBox('expensizeDB');

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
      home: ExpensesScreen(),
    );
  }
}
