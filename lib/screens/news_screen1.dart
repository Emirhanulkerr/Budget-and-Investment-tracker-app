import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Makine Öğrenmesi ve Yapay Zeka gibi\n özellikler ikinci dönemde eklenecektir.\n',
        style: TextStyle(fontSize: 15),
      ),

    );
  }
}