// dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/salary_model.dart';
import '../models/expense_model.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({Key? key}) : super(key: key);

  @override
  _AssetsScreenState createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  void _showAddExpenseDialog() {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Düzensiz Gider Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration:
                const InputDecoration(labelText: 'Gider Açıklaması'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: 'Giderin Miktarı'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                String description = descriptionController.text;
                double? amount = double.tryParse(amountController.text);
                if (description.isNotEmpty && amount != null && amount > 0) {
                  final salaryModel =
                  Provider.of<SalaryModel>(context, listen: false);
                  if (salaryModel.salary < amount) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Yeterli Bakiyeniz Yok')),
                    );
                    return;
                  }
                  Provider.of<ExpenseModel>(context, listen: false)
                      .addIrregularExpense(
                    IrregularExpense(
                      description: description,
                      amount: amount,
                      dateAdded: DateTime.now(),
                    ),
                  );
                  salaryModel.deduct(amount);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('geçerli miktar giriniz')),
                  );
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _showEditExpenseDialog(IrregularExpense expense, int index) {
    final TextEditingController descriptionController =
    TextEditingController(text: expense.description);
    final TextEditingController amountController =
    TextEditingController(text: expense.amount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Gideri Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration:
                const InputDecoration(labelText: 'Gider Açıklaması'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: 'Giderin Miktarı'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                String newDescription = descriptionController.text;
                double? newAmount = double.tryParse(amountController.text);
                if (newDescription.isNotEmpty &&
                    newAmount != null &&
                    newAmount > 0) {
                  final salaryModel =
                  Provider.of<SalaryModel>(context, listen: false);
                  // Restore old expense amount.
                  salaryModel.setSalary(salaryModel.salary + expense.amount);
                  if (salaryModel.salary < newAmount) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Yeterli Bakiyeniz Yok')),
                    );
                    return;
                  }
                  salaryModel.deduct(newAmount);
                  final updatedExpense = IrregularExpense(
                    description: newDescription,
                    amount: newAmount,
                    dateAdded: expense.dateAdded,
                  );
                  final expenseModel =
                  Provider.of<ExpenseModel>(context, listen: false);
                  expenseModel.irregularExpenses[index] = updatedExpense;
                  expenseModel.notifyListeners();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('geçerli miktar giriniz')),
                  );
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _showSalaryDialog() {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Maaş Giriniz'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration:
            const InputDecoration(hintText: 'Para miktarı giriniz'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                double? entered = double.tryParse(_controller.text);
                if (entered != null && entered > 0) {
                  final salaryModel =
                  Provider.of<SalaryModel>(context, listen: false);
                  salaryModel.setSalary(salaryModel.salary + entered);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('geçerli miktar giriniz')),
                  );
                }
              },
              child: const Text('Gelir Ekle'),
            ),
            TextButton(
              onPressed: () {
                double? entered = double.tryParse(_controller.text);
                if (entered != null && entered > 0) {
                  Provider.of<SalaryModel>(context, listen: false)
                      .setSalary(entered);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('geçerli miktar giriniz')),
                  );
                }
              },
              child: const Text('Maaşı Düzenle'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Düzensiz Giderler')),
      body: Consumer<ExpenseModel>(
        builder: (context, expenseModel, child) {
          return expenseModel.irregularExpenses.isEmpty
              ? const Center(child: Text('Henüz gider eklenmedi.'))
              : ListView.builder(
            itemCount: expenseModel.irregularExpenses.length,
            itemBuilder: (context, index) {
              final expense = expenseModel.irregularExpenses[index];
              String formattedDate =
              DateFormat('dd-MM-yyyy').format(expense.dateAdded);
              return ListTile(
                title: Text(expense.description),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₺${expense.amount.toStringAsFixed(2)}'),
                    Text(formattedDate,
                        textAlign: TextAlign.right),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          _showEditExpenseDialog(expense, index),
                    ),
                    IconButton(
                      icon:
                      const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        final salaryModel =
                        Provider.of<SalaryModel>(context,
                            listen: false);
                        salaryModel.setSalary(
                            salaryModel.salary + expense.amount);
                        Provider.of<ExpenseModel>(context,
                            listen: false)
                            .removeIrregularExpense(index);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.startFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'salary',
            onPressed: _showSalaryDialog,
            child: const Icon(Icons.account_balance_wallet),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'expense',
            onPressed: _showAddExpenseDialog,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}