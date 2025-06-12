import 'package:flutter/material.dart';

class SalaryModel extends ChangeNotifier {
  double _salary = 0;

  double get salary => _salary;

  void setSalary(double newSalary) {
    _salary = newSalary;
    notifyListeners();
  }

  void deduct(double amount) {
    _salary -= amount;
    if (_salary < 0) _salary = 0;
    notifyListeners();
  }
}