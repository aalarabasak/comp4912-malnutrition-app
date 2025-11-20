
import 'package:flutter/material.dart';

class MealConfirmationScreenPackaged extends StatelessWidget {

  final String barcodeId; //takes barcode id as a parameter
  
  const MealConfirmationScreenPackaged({super.key, required this.barcodeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meal Confirmation Screen")),
      body: Center(
        child: Text(
          "Barkod ID: $barcodeId.",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}