import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InvestmentsPriceScreen extends StatefulWidget {
  const InvestmentsPriceScreen({Key? key}) : super(key: key);

  @override
  _InvestmentsPriceScreenState createState() =>
      _InvestmentsPriceScreenState();
}

class _InvestmentsPriceScreenState extends State<InvestmentsPriceScreen> {
  late Timer _timer;
  double _dollarPrice = 0.0;
  double _euroPrice = 0.0;
  double _bitcoinPrice = 0.0;
  double _goldPrice = 0.0;
  double _ethPrice = 0.0;
  static const String apiKey = 'YOUR-API-KEY';

  @override
  void initState() {
    super.initState();
    _fetchPrices();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchPrices();
    });
  }

  Future<void> _fetchPrices() async {
    try {
      final cryptoUrl = Uri.parse(
          'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd&api_key=$apiKey');
      final cryptoResponse = await http.get(cryptoUrl);

      // API returns TRY-based rates when base is TRY.
      final currencyUrl = Uri.parse(
          'https://v6.exchangerate-api.com/v6/YOUR-API-KEY/latest/TRY');
      final currencyResponse = await http.get(currencyUrl);

      if (cryptoResponse.statusCode == 200 &&
          currencyResponse.statusCode == 200) {
        final cryptoData = json.decode(cryptoResponse.body);
        final currencyData = json.decode(currencyResponse.body);

        // Invert the values to get USD/TL and EUR/TL.
        final usdRate = (currencyData['conversion_rates']?['USD'] as num?)?.toDouble() ?? 0.0;
        final eurRate = (currencyData['conversion_rates']?['EUR'] as num?)?.toDouble() ?? 0.0;
        setState(() {
          _bitcoinPrice = (cryptoData['bitcoin']?['usd'] as num?)?.toDouble() ?? 0.0;
          _ethPrice = (cryptoData['ethereum']?['usd'] as num?)?.toDouble() ?? 0.0;
          _dollarPrice = usdRate != 0.0 ? 1 / usdRate : 0.0;
          _euroPrice = eurRate != 0.0 ? 1 / eurRate : 0.0;
          _goldPrice = 1900.0;
        });
      }
    } catch (e) {
      print('Error fetching prices: $e');
    }
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
        _buildPriceTile('Dollar/TL', '', _dollarPrice),
        _buildPriceTile('Euro/TL', '', _euroPrice),
        _buildPriceTile('Gold', '\$', _goldPrice),
        _buildPriceTile('Bitcoin', '\$', _bitcoinPrice),
        _buildPriceTile('Ethereum', '\$', _ethPrice),
      ],
    );
  }
}
