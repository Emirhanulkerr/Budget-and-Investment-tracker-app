// File: `lib/main.dart`
import 'package:flutter/material.dart';
import 'screens/expense_screen.dart';
import 'screens/savings_wizard_screen.dart';
import 'screens/investments_screen.dart';
import 'screens/assets_screen.dart';
import 'screens/news_screen.dart';

void main() {
  runApp(MyApp());
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
      home: HomePage(),
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
    // Use ExpenseScreen as defined in expense_screen.dart
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
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade900,
                Colors.deepPurple.shade300,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Personal Budget App',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
      ),
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade800,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.article), label: 'News'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Ödemeler'),
            BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Faiz Sihirbazı'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Yatırımlar'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Giderler'),
          ],
        ),
      ),
    );
  }
}