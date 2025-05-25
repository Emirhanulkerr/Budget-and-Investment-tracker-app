// File: lib/screens/savings_wizard_screen.dart
import 'package:flutter/material.dart';

class SavingsWizardScreen extends StatefulWidget {
  const SavingsWizardScreen({Key? key}) : super(key: key);

  @override
  _SavingsWizardScreenState createState() => _SavingsWizardScreenState();
}

class _SavingsWizardScreenState extends State<SavingsWizardScreen> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();

  double? _payment12, _payment24, _payment36;

  void _calculateSavings() {
    final String targetText = _targetController.text;
    final String interestText = _interestController.text;
    final double? target = double.tryParse(targetText);
    final double? interestAnnual = double.tryParse(interestText);

    if (target != null && target > 0 && interestAnnual != null && interestAnnual >= 0) {
      setState(() {
        _payment12 = _calculateMonthlyPayment(target, interestAnnual, 12);
        _payment24 = _calculateMonthlyPayment(target, interestAnnual, 24);
        _payment36 = _calculateMonthlyPayment(target, interestAnnual, 36);
      });
    } else {
      setState(() {
        _payment12 = null;
        _payment24 = null;
        _payment36 = null;
      });
    }
  }

  double _calculateMonthlyPayment(double target, double annualInterest, int months) {
    // Simple interest over the period:
    double totalInterest = target * (annualInterest / 100) * (months / 12.0);
    double totalWithInterest = target + totalInterest;
    return totalWithInterest / months;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontFamily: 'San Francisco'),
      child: Padding(
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
            ElevatedButton(
              onPressed: _calculateSavings,
              child: const Text('Hesapla'),
            ),
            const SizedBox(height: 20),
            if (_payment12 != null && _payment24 != null && _payment36 != null)
              Column(
                children: [
                  Text('12 ayda: ₺${_payment12!.toStringAsFixed(2)} / ay'),
                  Text('24 ayda: ₺${_payment24!.toStringAsFixed(2)} / ay'),
                  Text('36 ayda: ₺${_payment36!.toStringAsFixed(2)} / ay'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}