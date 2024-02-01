import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart' as uuid_package;

// import 'dart:js_interop';

const uuid = uuid_package.Uuid();

List<String> Categorys = ['work', 'personal', 'others'];

final formatter = DateFormat('dd-MMM-yyyy');

class Expenses {
  Expenses(
      {required this.title,
      required this.amount,
      required this.date,
      required this.category})
      : id = uuid.v4();

  String? id;
  String title;
  String amount;
  DateTime date;
  String category;

  String formattedDate() {
    return formatter.format(date);
  }


}
