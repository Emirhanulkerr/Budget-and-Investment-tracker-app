// File: `lib/screens/expense_screen.dart`
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/salary_model.dart';


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

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({Key? key}) : super(key: key);

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final List<Installment> _installments = [];

  void _showAddInstallmentMenu() {
    ExpenseType _selectedExpenseType = ExpenseType.fixedCount;
    final TextEditingController _descriptionController = TextEditingController();
    final TextEditingController _amountController = TextEditingController();
    final TextEditingController _installmentCountController = TextEditingController();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16),
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return Wrap(
                    children: [
                      Text(
                        'Gider-Taksit Ekle',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      DropdownButton<ExpenseType>(
                        value: _selectedExpenseType,
                        onChanged: (ExpenseType? newValue) {
                          if (newValue != null) {
                            setModalState(() {
                              _selectedExpenseType = newValue;
                            });
                          }
                        },
                        items: ExpenseType.values.map((ExpenseType type) {
                          return DropdownMenuItem<ExpenseType>(
                            value: type,
                            child: Text(type == ExpenseType.fixedInfinite
                                ? 'Sabit-sonsuz taksitli'
                                : 'Adetli taksitli'),
                          );
                        }).toList(),
                        isExpanded: true,
                      ),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Gider Açıklaması',
                        ),
                      ),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Toplam Miktar (₺)',
                        ),
                      ),
                      if (_selectedExpenseType == ExpenseType.fixedCount)
                        TextField(
                          controller: _installmentCountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Taksit Sayısı',
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_descriptionController.text.isNotEmpty &&
                              _amountController.text.isNotEmpty) {
                            double? enteredAmount =
                            double.tryParse(_amountController.text);
                            if (enteredAmount != null) {
                              int installmentsCount = 0;
                              double perInstallmentAmount = enteredAmount;
                              if (_selectedExpenseType == ExpenseType.fixedCount) {
                                if (_installmentCountController.text.isEmpty) return;
                                int? count =
                                int.tryParse(_installmentCountController.text);
                                if (count == null || count <= 0) return;
                                installmentsCount = count;
                                perInstallmentAmount = enteredAmount / count;
                              } else {
                                installmentsCount = -1;
                              }
                              setState(() {
                                _installments.add(
                                  Installment(
                                    description: _descriptionController.text,
                                    amount: perInstallmentAmount,
                                    remainingInstallments: installmentsCount,
                                    expenseType: _selectedExpenseType,
                                  ),
                                );
                              });
                              Navigator.pop(ctx);
                            }
                          }
                        },
                        child: const Text('Add'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
          );
        });
  }

  void _removeInstallment(int index) {
    setState(() {
      _installments.removeAt(index);
    });
  }

  void _togglePaid(int index) {
    final installment = _installments[index];
    if (installment.isPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeni taksit süresi henüz gelmedi. Lütfen bekleyin.'),
        ),
      );
      return;
    }
    // Deduct installment amount from salary.
    Provider.of<SalaryModel>(context, listen: false).deduct(installment.amount);
    setState(() {
      if (installment.expenseType == ExpenseType.fixedCount &&
          installment.remainingInstallments > 0) {
        installment.remainingInstallments -= 1;
      }
      installment.isPaid = true;
    });
    Future.delayed(const Duration(days: 30), () {
      if (mounted) {
        setState(() {
          installment.isPaid = false;
        });
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex = newIndex - 1;
    }
    setState(() {
      final item = _installments.removeAt(oldIndex);
      _installments.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Updated background color to black
      appBar: AppBar(title: const Text('Gider ve Taksit Takibi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _installments.isEmpty
            ? const Center(child: Text('Henüz Gider veya Taksit Eklenmedi.'))
            : ReorderableListView(
          onReorder: _onReorder,
          children: [
            for (int index = 0; index < _installments.length; index++)
              Card(
                key: ValueKey('installment_$index'),
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(_installments[index].description),
                  subtitle: Text(
                    _installments[index].expenseType == ExpenseType.fixedInfinite
                        ? 'Miktar: ${formatCurrency(_installments[index].amount)}'
                        : 'Taksit Ücreti: ${formatCurrency(_installments[index].amount)}\nKalan Taksit: ${_installments[index].remainingInstallmentsDisplay}\nKalan Toplam: ${_installments[index].remainingTotalAmount}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _installments[index].remainingInstallments == 0 &&
                            _installments[index].expenseType == ExpenseType.fixedCount
                            ? 'Tamamlandı'
                            : _installments[index].isPaid
                            ? 'Ödendi'
                            : 'Ödenmedi',
                        style: TextStyle(
                          color: _installments[index].isPaid ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeInstallment(index),
                      ),
                    ],
                  ),
                  onTap: (_installments[index].expenseType == ExpenseType.fixedInfinite ||
                      _installments[index].remainingInstallments > 0)
                      ? () => _togglePaid(index)
                      : null,
                ),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddInstallmentMenu,
        child: const Icon(Icons.add),
      ),
    );
  }
}