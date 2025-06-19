import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/salary_model.dart';
import 'models/expense_model.dart';
import 'screens/regular_expense_screen2.dart';
import 'screens/savings_wizard_screen3.dart';
import 'screens/investments_screen4.dart';
import 'screens/expense_screen5.dart';
import 'screens/news_screen1.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SalaryModel()),
        ChangeNotifierProvider(create: (_) => ExpenseModel()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Budget',
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'San Francisco',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'San Francisco',
      ),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _screens = <Widget>[
    NewsScreen(),
    ExpenseScreen(),
    SavingsWizardScreen(),
    InvestmentsPriceScreen(),
    AssetsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black87,
                Colors.indigo.shade900,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            const Text(
              'Bütçem',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Consumer<SalaryModel>(
              builder: (context, salaryModel, child) {
                return Text(
                  '₺${salaryModel.salary.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black87,
              Colors.black87,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconSize: 40,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Haberler'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Ödemeler'),
            BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Faiz'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Yatırımlar'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Giderler'),
          ],
        ),
      ),
    );
  }
}