import 'package:flutter/material.dart';

class ReusableHomeCards extends StatelessWidget {
  ReusableHomeCards({
    this.cupertinoPicker,
    required this.headTitle,
    this.subTitle,
    super.key,
  });

  String headTitle;
  String? subTitle;
  Widget? cupertinoPicker;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      height: height < 600
          ? MediaQuery.of(context).size.height * 0.30
          : MediaQuery.of(context).size.height * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            headTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          cupertinoPicker ??
              Text(
                subTitle!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
        ],
      ),
    );
  }
}
