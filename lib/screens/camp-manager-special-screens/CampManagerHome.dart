import 'package:flutter/material.dart';
import '../login-related-screens/welcome_screen.dart';

class CampManagerHome extends StatelessWidget {
  const CampManagerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      leading: IconButton(
          icon: const Icon(Icons.logout), //logout sign
          onPressed: () {
           // this allows the demo to quickly return to the Welcome screen.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              (route) => false, // Erases ALL history Login, SelectRole, Dashboard
            );
          },
        ),
    ),

      body: const Center(
        child: Text(
          'Welcome, Camp Manager!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}