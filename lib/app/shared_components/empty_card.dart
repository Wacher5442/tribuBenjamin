import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class EmptyWidget extends StatelessWidget {
  EmptyWidget({super.key, required this.text});
  String text;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Lottie.asset('assets/lotties/empty-search.json',
              width: 150, height: 150),
          Text(text, style: TextStyle(color: HexColor("#c0202f"), fontSize: 14))
        ],
      ),
    );
  }
}
