// File: `lib/screens/savings_wizard_screen.dart`
import 'package:flutter/material.dart';

class SavingsWizardScreen extends StatefulWidget {
  const SavingsWizardScreen({Key? key}) : super(key: key);

  @override
  _SavingsWizardScreenState createState() => _SavingsWizardScreenState();
}

class _SavingsWizardScreenState extends State<SavingsWizardScreen> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _installmentCountController = TextEditingController();

  double? _monthlyPayment, _totalAmount;

  void _calculateSavings() {
    final String targetText = _targetController.text;
    final String interestText = _interestController.text;
    final String installmentText = _installmentCountController.text;
    final double? target = double.tryParse(targetText);
    final double? annualInterest = double.tryParse(interestText);
    final int? months = int.tryParse(installmentText);

    if (target != null &&
        target > 0 &&
        annualInterest != null &&
        annualInterest >= 0 &&
        months != null &&
        months > 0) {
      setState(() {
        _totalAmount = _calculateTotalWithInterest(target, annualInterest, months);
        _monthlyPayment = _totalAmount! / months;
      });
    } else {
      setState(() {
        _monthlyPayment = null;
        _totalAmount = null;
      });
    }
  }

  double _calculateTotalWithInterest(double target, double annualInterest, int months) {
    double totalInterest = target * (annualInterest / 100) * (months / 12.0);
    return target + totalInterest;
  }

  // Formats a number so that integer part groups have one dot per three digits and the decimal separator is a comma.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Para Biriktirme Sihirbazı')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Para Biriktirme Sihirbazı',
              style: TextStyle(
                fontFamily: 'San Francisco',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Hedef birikim miktarınızı giriniz:'),
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Gerekli para miktarı',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Yıllık faiz oranını giriniz (yüzde olarak):'),
            TextField(
              controller: _interestController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Faiz oranı',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Taksit sayısını giriniz (ay olarak):'),
            TextField(
              controller: _installmentCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Taksit sayısı',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateSavings,
              child: const Text('Hesapla'),
            ),
            const SizedBox(height: 20),
            if (_monthlyPayment != null && _totalAmount != null)
              Column(
                children: [
                  Text('Ayda: ${formatCurrency(_monthlyPayment!)}'),
                  Text('Faizli Toplam: ${formatCurrency(_totalAmount!)}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}