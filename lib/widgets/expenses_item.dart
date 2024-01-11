import 'package:expensize/screens/edit_screen.dart';
import 'package:flutter/material.dart';

import 'package:expensize/models/expenses.dart';

class ExpenseItem extends StatefulWidget {
  ExpenseItem({
    this.deletFun,
    this.redEdit,
    this.expensesList,
    super.key,
  });

  Function? redEdit;
  Function? deletFun;

  List<Expenses>? expensesList;

  @override
  State<ExpenseItem> createState() => _ExpenseItemState();
}

class _ExpenseItemState extends State<ExpenseItem> {
  void onPress({index}) {
    showModalBottomSheet(
        context: context,
        builder: (context) => EditScreen(
              editData: (
                  {required title,
                  required amount,
                  required date,
                  required category}) {
                widget.expensesList![index].title = title;
                widget.expensesList![index].amount = amount;
                widget.expensesList![index].category = category;
                widget.expensesList![index].date = date.toString();

                widget.redEdit!();
              },
              resAmount: widget.expensesList![index].amount,
              resTitle: widget.expensesList![index].title,
              resCategory: widget.expensesList![index].category,
              resDate: widget.expensesList![index].date.toString(),
            ));
  }


    


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.expensesList?.length ?? 0,
        itemBuilder: (context, index) {
          return Dismissible(
            direction: DismissDirection.endToStart,
            key: Key(widget.expensesList![index].toString()),
            background: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(
                color: Colors.red,
                child: Icon(Icons.delete),
              ),
            ),
            onDismissed: (u) {
              widget.deletFun!(index);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  onPress(index: index);
                },
                child: Card(
                  child: ListTile(
                    trailing: Column(
                      children: [
                        Text(
                          widget.expensesList![index].category,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          widget.expensesList![index].date.toString(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    title: Text(
                      widget.expensesList![index].title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Text(
                      '₹ ${widget.expensesList![index].amount}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
