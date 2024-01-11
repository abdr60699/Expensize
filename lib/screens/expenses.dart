import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:expensize/models/expenses.dart';
import 'package:expensize/screens/add.dart';
import 'package:expensize/widgets/expenses_item.dart';
import 'package:expensize/widgets/cupertino_widget.dart';
import 'package:expensize/widgets/reusable_home_cards.dart';

class ExpensesScreen extends StatefulWidget {
  ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Expenses> myExpensesList = [
    Expenses(
        title: 'Dress', amount: '100', date: '12-Jan-2024', category: 'work'),
    Expenses(
        title: 'Dress', amount: '100', date: '12-Feb-2024', category: 'work'),
    Expenses(
        title: 'Dress', amount: '100', date: '12-Feb-2024', category: 'work'),
    Expenses(
        title: 'Dress', amount: '400', date: '19-Jan-2024', category: 'work'),
    Expenses(
        title: 'Dress', amount: '400', date: '13-Jan-2024', category: 'work'),
    Expenses(
        title: 'Dress', amount: '100', date: '12-Jan-2024', category: 'work'),
  ];

  void onPressed() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => AddScreen(
              addData: ({title, amount, date, category}) {
                setState(() {});
                myExpensesList.add(Expenses(
                    title: title,
                    amount: amount,
                    date: date,
                    category: category));
              },
            ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xffF16627).withOpacity(0.8),
          onPressed: onPressed,
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Expensize',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.background),
          ),
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
                  CupertinoWidget(selectedMonths: (input){
                      print( '123  $input');
                  },),
                  const SizedBox(
                    width: 10,
                  ),
                  ReusableHomeCards(
                    headTitle: 'Total',
                    subTitle: '\$ 1003',
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: ExpenseItem(
                deletFun: (index) {
                  setState(() {
                    myExpensesList.removeAt(index);
                  });
                },
                redEdit: () {
                  setState(() {});
                },
                expensesList: myExpensesList,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 // List.generate(12, (index) {
    //   DateFormat('MMM', 'en-us')
    //       .format(DateTime(2001,1,1,1,))
    //       .split('0')
    //       .map((e) => months.add(e))
    //       .toList();
    // });

    // return months};



    
                  // Expanded(
                  //   child: Card(
                  //     child: CupertinoPicker(
                  //         backgroundColor: Colors.red,
                  //         itemExtent: 32,
                  //         onSelectedItemChanged: (index) {},
                  //         children: const [
                  //           Text('data'),
                  //           Text('dataaaaa'),
                  //           Text('dataaa'),
                  //         ]),
                  //   ),
                  // ),