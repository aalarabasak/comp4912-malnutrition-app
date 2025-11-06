import 'package:flutter/material.dart';

class GuestDashboard extends StatelessWidget {
  const GuestDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(leading: IconButton(icon: Icon(Icons.arrow_back),
        onPressed: () {
          //this part will be back to welcome screen
          Navigator.of(context).pop();
        },
      ),

      backgroundColor: Colors.transparent, 
    ),

      body: const Center(
        child: Text(
          'Guest User Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}