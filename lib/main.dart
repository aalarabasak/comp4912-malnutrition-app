import 'package:flutter/material.dart';
import 'package:malnutrition_app/screens/field_worker_home.dart';
import 'screens/welcome_screen.dart'; 
//import 'screens/login_screen.dart';
//import 'screens/select_role_screen.dart';
//import 'screens/signup_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{ //'async' -> because app will wait for Firebase to initialize

  //This initialization code is taken from the official Firebase documentation:
  //https://firebase.google.com/docs/flutter/setup?platform=ios#initialize_firebase
  WidgetsFlutterBinding.ensureInitialized(); //to ensure flutter is ready
  // initialize Firebase 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Malnutrition APP',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      
      home: const WelcomeScreen(),
      //home: const FieldWorkerHome(), 
    );
  }
}

