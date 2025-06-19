import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/salary_model.dart';

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Kalan Taksit Sayıları'),
            Text('Ev, Araba, Telefon, Laptop'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final TextEditingController _controller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Enter Salary'),
                content: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter salary',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      double entered = double.tryParse(_controller.text) ?? 0;
                      Provider.of<SalaryModel>(context, listen: false)
                          .setSalary(entered);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Set'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.attach_money),
      ),
    );
  }
}
