import 'package:flutter/material.dart';


import 'screens/login-related-screens/welcome_screen.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


import 'package:connectivity_plus/connectivity_plus.dart'; //internet connection guard

void main() async{ 

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
      debugShowCheckedModeBanner: false, //close debug writing
      title: 'Malnutrition APP',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      
      home: const WelcomeScreen(),


      builder: (context, child) {
        return StreamBuilder <List<ConnectivityResult>>(
          stream: Connectivity().onConnectivityChanged,
          builder:(context, snapshot) {
            
            bool isoffline= false;//to check wheter internet is on or off

            if(snapshot.hasData){
              final result = snapshot.data!;
              if(result.contains(ConnectivityResult.none)){ //no internet case
                isoffline=true;
              }
            }

            return Stack(
              children: [
                if(child != null) child, //if there is no error then the app will work correctly

                if(isoffline)//red messsage
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Material(
                    color: Colors.red,
                    child: Padding(padding:const EdgeInsets.all(12.0), 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              "Check your connection and try again", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),),
                      ],
                    ),),
                  )
                )

              ],
            );
          },
        );
      },
    );
  }
}

