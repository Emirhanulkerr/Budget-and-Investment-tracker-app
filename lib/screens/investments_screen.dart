import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class InvestmentsPriceScreen extends StatefulWidget {
  const InvestmentsPriceScreen({Key? key}) : super(key: key);

  @override
  _InvestmentsPriceScreenState createState() => _InvestmentsPriceScreenState();
}

class _InvestmentsPriceScreenState extends State<InvestmentsPriceScreen> {
  late Timer _timer;
  final Random _random = Random();

  double _dollarPrice = 0.0;
  double _euroPrice = 0.0;
  double _bitcoinPrice = 0.0;
  double _ethereumPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _updatePrices();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updatePrices();
    });
  }

  void _updatePrices() {
    setState(() {
      _dollarPrice = 1 + _random.nextDouble() * 0.5;
      _euroPrice = 0.8 + _random.nextDouble() * 0.5;
      _bitcoinPrice = 20000 + _random.nextDouble() * 5000;
      _ethereumPrice = 1500 + _random.nextDouble() * 500;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _buildPriceTile(String label, String currency, double price) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '$currency${price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, color: Colors.green),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Header row from investments_screen
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Total Balance: \$X,XXX',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'PnL: \$Y,YYY',
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Price tiles from price_screen
        _buildPriceTile('Dollar', '\$', _dollarPrice),
        _buildPriceTile('Euro', '€', _euroPrice),
        _buildPriceTile('Bitcoin', '\$', _bitcoinPrice),
        _buildPriceTile('Ethereum', '\$', _ethereumPrice),
      ],
    );
  }
}