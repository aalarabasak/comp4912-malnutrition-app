import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class NutritionOfficerHome extends StatelessWidget {
  const NutritionOfficerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      leading: IconButton(
          icon: const Icon(Icons.logout), // back to welcome screen
          onPressed: () {
           
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              (route) => false,
            );
          },
        ),
    ),
    
      body: const Center(
        child: Text(
          'Welcome, Nutrition Officer!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}