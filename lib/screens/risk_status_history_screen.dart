import 'package:flutter/material.dart';

class RiskStatusHistoryScreen extends StatelessWidget{
  final String childid;
  const RiskStatusHistoryScreen({super.key, required this.childid});

  @override
  Widget build (BuildContext context){
    return Scaffold(body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Text('risk status for doc firebase: $childid'),),)
    
      
    );
  }
}