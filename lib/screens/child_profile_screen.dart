import 'package:flutter/material.dart';

class ChildProfileScreen extends StatelessWidget{

  final String childId;

  const ChildProfileScreen({
    super.key,
    required this.childId
  });

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back),
        onPressed: () {
          //this part will be back to welcome screen
          Navigator.of(context).pop();
        },
      ),

      backgroundColor: Colors.transparent, 
      ),
      body: Center(
        child: Text(
          'Profilini gösterdiğimiz çocuğun ID\'si:\n\n$childId',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );


  }

}