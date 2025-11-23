import 'package:flutter/material.dart';

class MeasurementsHistoryScreen extends StatelessWidget{
  final String childid;
  const MeasurementsHistoryScreen({super.key, required this.childid});

  @override
  Widget build (BuildContext context){
    return Scaffold(body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Text('measurements for doc firebase: $childid'),),)
    
      
    );
  }
}
