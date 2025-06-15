import 'package:flutter/material.dart';

enum ExpenseType { fixedInfinite, fixedCount }

String formatCurrency(double value) {
  String s = value.toStringAsFixed(2);
  List<String> parts = s.split('.');
  String integerPart = parts[0];
  String fractionPart = parts[1];
  String reversed = integerPart.split('').reversed.join();
  StringBuffer buffer = StringBuffer();
  for (int i = 0; i < reversed.length; i++) {
    if (i > 0 && i % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(reversed[i]);
  }
  String formattedInteger = buffer.toString().split('').reversed.join();
  return '₺$formattedInteger,$fractionPart';
}

class Installment {
  String description;
  double amount;
  bool isPaid;
  int remainingInstallments;
  ExpenseType expenseType;

  Installment({
    required this.description,
    required this.amount,
    required this.remainingInstallments,
    required this.expenseType,
    this.isPaid = false,
  });

  String get remainingTotalAmount {
    if (expenseType == ExpenseType.fixedInfinite) {
      return '';
    } else {
      return formatCurrency(remainingInstallments * amount);
    }
  }

  String get remainingInstallmentsDisplay {
    if (expenseType == ExpenseType.fixedInfinite) {
      return '';
    } else {
      return remainingInstallments.toString();
    }
  }
}

class ExpenseModel extends ChangeNotifier {
  final List<Installment> installments = [];

  void addInstallment(Installment installment) {
    installments.add(installment);
    notifyListeners();
  }

  void removeInstallment(int index) {
    installments.removeAt(index);
    notifyListeners();
  }

  void updateInstallment(int index, Installment installment) {
    installments[index] = installment;
    notifyListeners();
  }
}