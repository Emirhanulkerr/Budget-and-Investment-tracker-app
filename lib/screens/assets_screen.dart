import 'package:flutter/material.dart';

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Display remaining counts for each asset category.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Kalan Taksit Sayıları'),
          Text('Ev, Araba, Telefon, Laptop'),
        ],
      ),
    );
  }
}
