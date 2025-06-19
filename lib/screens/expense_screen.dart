import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../models/salary_model.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({Key? key}) : super(key: key);

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
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
            right: 16,
          ),
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
                      labelText: 'Toplam Miktar (\u20BA)',
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
                        double? enteredAmount = double.tryParse(_amountController.text);
                        if (enteredAmount != null) {
                          int installmentsCount = 0;
                          double perInstallmentAmount = enteredAmount;
                          if (_selectedExpenseType == ExpenseType.fixedCount) {
                            if (_installmentCountController.text.isEmpty) return;
                            int? count = int.tryParse(_installmentCountController.text);
                            if (count == null || count <= 0) return;
                            installmentsCount = count;
                            perInstallmentAmount = enteredAmount / count;
                          } else {
                            installmentsCount = -1;
                          }
                          final newInstallment = Installment(
                            description: _descriptionController.text,
                            amount: perInstallmentAmount,
                            remainingInstallments: installmentsCount,
                            expenseType: _selectedExpenseType,
                          );
                          Provider.of<ExpenseModel>(context, listen: false).addInstallment(newInstallment);
                          Navigator.pop(ctx);
                        }
                      }
                    },
                    child: const Text('Add'),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _togglePaid(int index, Installment installment) {
    final salaryModel = Provider.of<SalaryModel>(context, listen: false);
    if (installment.isPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeni taksit süresi henüz gelmedi. Lütfen bekleyin.'),
        ),
      );
      return;
    }
    if (salaryModel.salary < installment.amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeterli bakiyeniz yok'),
        ),
      );
      return;
    }
    salaryModel.deduct(installment.amount);
    installment.isPaid = true;
    if (installment.expenseType == ExpenseType.fixedCount &&
        installment.remainingInstallments > 0) {
      installment.remainingInstallments -= 1;
    }
    Provider.of<ExpenseModel>(context, listen: false).notifyListeners();
    Future.delayed(const Duration(days: 30), () {
      if (mounted) {
        installment.isPaid = false;
        Provider.of<ExpenseModel>(context, listen: false).notifyListeners();
      }
    });
  }

  void _onReorder(ExpenseModel expenseModel, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = expenseModel.installments.removeAt(oldIndex);
    expenseModel.installments.insert(newIndex, item);
    expenseModel.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Gider ve Taksit Takibi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ExpenseModel>(
          builder: (context, expenseModel, child) {
            return expenseModel.installments.isEmpty
                ? const Center(
              child: Text('Henüz Gider veya Taksit Eklenmedi.'),
            )
                : ReorderableListView(
              onReorder: (oldIndex, newIndex) => _onReorder(expenseModel, oldIndex, newIndex),
              children: [
                for (int index = 0; index < expenseModel.installments.length; index++)
                  Card(
                    key: ValueKey('installment_$index'),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(expenseModel.installments[index].description),
                      subtitle: Text(
                        expenseModel.installments[index].expenseType == ExpenseType.fixedInfinite
                            ? 'Miktar: ${formatCurrency(expenseModel.installments[index].amount)}'
                            : 'Taksit Ücreti: ${formatCurrency(expenseModel.installments[index].amount)}\nKalan Taksit: ${expenseModel.installments[index].remainingInstallmentsDisplay}\nKalan Toplam: ${expenseModel.installments[index].remainingTotalAmount}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            expenseModel.installments[index].remainingInstallments == 0 &&
                                expenseModel.installments[index].expenseType == ExpenseType.fixedCount
                                ? 'Tamamlandı'
                                : expenseModel.installments[index].isPaid
                                ? 'Ödendi'
                                : 'Ödenmedi',
                            style: TextStyle(
                              color: expenseModel.installments[index].isPaid ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => Provider.of<ExpenseModel>(context, listen: false).removeInstallment(index),
                          ),
                        ],
                      ),
                      onTap: (expenseModel.installments[index].expenseType == ExpenseType.fixedInfinite ||
                          expenseModel.installments[index].remainingInstallments > 0)
                          ? () => _togglePaid(index, expenseModel.installments[index])
                          : null,
                    ),
                  )
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddInstallmentMenu,
        child: const Icon(Icons.add),
      ),
    );
  }
}