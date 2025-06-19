// dart
// File: lib/screens/investments_screen4.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InvestmentHolding {
  final String asset;
  final double quantity;
  final double tlValue;

  InvestmentHolding({
    required this.asset,
    required this.quantity,
    required this.tlValue,
  });
}

class InvestmentsPriceScreen extends StatefulWidget {
  const InvestmentsPriceScreen({Key? key}) : super(key: key);

  @override
  _InvestmentsPriceScreenState createState() => _InvestmentsPriceScreenState();
}

class _InvestmentsPriceScreenState extends State<InvestmentsPriceScreen> {
  late Timer _timer;
  double _dollarPrice = 0.0;
  double _euroPrice = 0.0;
  double _bitcoinPrice = 0.0;
  double _goldPrice = 0.0;
  double _ethPrice = 0.0;
  double _silverPrice = 0.0;

  List<InvestmentHolding> _holdings = [];

  @override
  void initState() {
    super.initState();
    _fetchPrices();
    _timer = Timer.periodic(const Duration(seconds: 100), (timer) {
      _fetchPrices();
    });
  }

  Future<void> _fetchPrices() async {
    try {
      final cryptoUrl = Uri.parse(
          'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd&api_key=CG-HvUmadPn6VmzSmjS9iEcanf2');
      final cryptoResponse = await http.get(cryptoUrl);
      final currencyUrl = Uri.parse(
          'https://v6.exchangerate-api.com/v6/2103d13e3d31336e65522c18/latest/TRY');
      final currencyResponse = await http.get(currencyUrl);
      final metalUrl = Uri.parse(
          'https://api.metalpriceapi.com/v1/latest?api_key=63d033b74dbcb952e8432fbe148e6757&base=USD&currencies=XAU,XAG');
      final metalResponse = await http.get(metalUrl);
      if (cryptoResponse.statusCode == 200 && currencyResponse.statusCode == 200) {
        final cryptoData = json.decode(cryptoResponse.body);
        final currencyData = json.decode(currencyResponse.body);
        final metalData = json.decode(metalResponse.body);
        final usdRate = (currencyData['conversion_rates']?['USD'] as num?)?.toDouble() ?? 0.0;
        final eurRate = (currencyData['conversion_rates']?['EUR'] as num?)?.toDouble() ?? 0.0;
        setState(() {
          _bitcoinPrice = (cryptoData['bitcoin']?['usd'] as num?)?.toDouble() ?? 0.0;
          _ethPrice = (cryptoData['ethereum']?['usd'] as num?)?.toDouble() ?? 0.0;
          _dollarPrice = usdRate != 0.0 ? 1 / usdRate : 0.0;
          _euroPrice = eurRate != 0.0 ? 1 / eurRate : 0.0;
          _goldPrice = (metalData['rates']?['USDXAU'] as num?)?.toDouble() ?? 0.0;
          _silverPrice = (metalData['rates']?['USDXAG'] as num?)?.toDouble() ?? 0.0;
        });
      }
    } catch (e) {
      print('Error fetching prices: $e');
    }
  }

  void _showAddInvestmentDialog() {
    String selectedAsset = 'Dolar';
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Yatırım Aracı Ekle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedAsset,
                  items: <String>['Dolar', 'Euro', 'Gram Altın','Ons Altın', 'Gram Gümüş','Ons Gümüş', 'Bitcoin', 'Ethereum']
                      .map((String asset) {
                    return DropdownMenuItem<String>(
                      value: asset,
                      child: Text(asset),
                    );
                  }).toList(),
                  onChanged: (String? newAsset) {
                    if (newAsset != null) {
                      setModalState(() {
                        selectedAsset = newAsset;
                      });
                    }
                  },
                ),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Sahip Olunan',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.indigo),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('İptal'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.indigo),
                onPressed: () {
                  final String input = amountController.text.replaceAll(',', '.');
                  final double amount = double.tryParse(input) ?? 0.0;
                  double conversionFactor = 0.0;
                  switch (selectedAsset) {
                    case 'Dolar':
                      conversionFactor = _dollarPrice;
                      break;
                    case 'Euro':
                      conversionFactor = _euroPrice;
                      break;
                    case 'Gram Altın':
                      conversionFactor = _goldPrice * _dollarPrice / 31.1035;
                      break;
                    case 'Ons Altın':
                      conversionFactor = _goldPrice * _dollarPrice;
                      break;
                    case 'Gram Gümüş':
                      conversionFactor = _silverPrice * _dollarPrice / 31.1035;
                      break;
                    case 'Ons Gümüş':
                      conversionFactor = _silverPrice * _dollarPrice;
                      break;
                    case 'Bitcoin':
                      conversionFactor = _bitcoinPrice * _dollarPrice;
                      break;
                    case 'Ethereum':
                      conversionFactor = _ethPrice * _dollarPrice;
                      break;
                  }
                  final double tlValue = amount * conversionFactor;
                  setState(() {
                    _holdings.add(
                      InvestmentHolding(
                        asset: selectedAsset,
                        quantity: amount,
                        tlValue: tlValue,
                      ),
                    );
                  });
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showEditInvestmentDialog(InvestmentHolding holdingToEdit, int index) {
    String selectedAsset = holdingToEdit.asset;
    final TextEditingController amountController =
    TextEditingController(text: holdingToEdit.quantity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Yatırımı Düzenle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedAsset,
                  items: <String>['Dolar', 'Euro', 'Gram Altın', 'Gram Gümüş', 'Bitcoin', 'Ethereum']
                      .map((String asset) {
                    return DropdownMenuItem<String>(
                      value: asset,
                      child: Text(asset),
                    );
                  }).toList(),
                  onChanged: (String? newAsset) {
                    if (newAsset != null) {
                      setModalState(() {
                        selectedAsset = newAsset;
                      });
                    }
                  },
                ),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Sahip Olunan',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.indigo),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('İptal'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.indigo),
                onPressed: () {
                  final String input = amountController.text.replaceAll(',', '.');
                  final double amount = double.tryParse(input) ?? 0.0;
                  double conversionFactor = 0.0;
                  switch (selectedAsset) {
                    case 'Dolar':
                      conversionFactor = _dollarPrice;
                      break;
                    case 'Euro':
                      conversionFactor = _euroPrice;
                      break;
                    case 'Gram Altın':
                      conversionFactor = _goldPrice * _dollarPrice / 31.1035;
                      break;
                    case 'Ons Altın':
                      conversionFactor = _goldPrice * _dollarPrice;
                      break;
                    case 'Gram Gümüş':
                      conversionFactor = _silverPrice * _dollarPrice / 31.1035;
                      break;
                    case 'Ons Gümüş':
                      conversionFactor = _silverPrice * _dollarPrice;
                      break;
                    case 'Bitcoin':
                      conversionFactor = _bitcoinPrice * _dollarPrice;
                      break;
                    case 'Ethereum':
                      conversionFactor = _ethPrice * _dollarPrice;
                      break;
                  }
                  final double tlValue = amount * conversionFactor;

                  final updatedHolding = InvestmentHolding(
                    asset: selectedAsset,
                    quantity: amount,
                    tlValue: tlValue,
                  );

                  setState(() {
                    _holdings[index] = updatedHolding;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Güncelle'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildPriceTile(String label, String currency, double price) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '$currency${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoldingTile(InvestmentHolding holding, int index) {
    String formattedQuantity;

    if (holding.asset == 'Bitcoin' || holding.asset == 'Ethereum') {
      formattedQuantity = holding.quantity.toStringAsFixed(6);
    } else {
      formattedQuantity = holding.quantity.toStringAsFixed(2);
    }

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: ListTile(
        title: Text(
          '${holding.asset} - $formattedQuantity',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          'Toplam Değer: ₺${holding.tlValue.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.green),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            _showEditInvestmentDialog(holding, index);
          },
        ),
      ),
    );
  }

  double _calculateTotalBalance() {
    return _holdings.fold(0.0, (sum, currentHolding) => sum + currentHolding.tlValue);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double totalBalance = _calculateTotalBalance();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yatırımlarım'),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toplam Bakiye: ₺${totalBalance.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),

              ],
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPriceTile('Dolar/TL', '₺', _dollarPrice),
                _buildPriceTile('Euro/TL', '₺', _euroPrice),
                _buildPriceTile('Ons Altın', r'$', _goldPrice),
                _buildPriceTile('Ons Gümüş', r'$', _silverPrice),
                _buildPriceTile('Bitcoin', r'$', _bitcoinPrice),
                _buildPriceTile('Ethereum', r'$', _ethPrice),
                _buildPriceTile('Gram Altın', r'$', _goldPrice/ 31.1035),
                _buildPriceTile('Gram Gümüş', r'$', _silverPrice/ 31.1035),


              ],
            ),
          ),

          const Divider(color: Colors.white, thickness: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Varlıklarım',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _holdings.length,
            itemBuilder: (context, index) {
              final holding = _holdings[index];
              return _buildHoldingTile(holding, index);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.shade900,
        onPressed: _showAddInvestmentDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}