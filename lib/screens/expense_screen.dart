import 'package:flutter/material.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement expense tracking UI here.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Kira - Fatura Takibi'),
          Text('Kişisel Bakım'),
          Text('Market Alışverişi'),
        ],
      ),
    );
  }
}