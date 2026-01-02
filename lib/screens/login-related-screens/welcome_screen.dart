
import 'package:flutter/material.dart';
import 'select_role_screen.dart';
import 'login_screen.dart';
import '../guest-user-screens/guest_user_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SafeArea(
        
        child : Padding(padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(
          
          child: SingleChildScrollView(
            child: Column(
              
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
              
              Image.asset('assets/images/IMG_8656.JPG', height:300,),
              // https://www.pinterest.com/pin/680606562448569845/sent/?invite_code=b7e2fd4dbf5b4b75823f47b656cd5a59&sender=857091510242561090&sfo=1


              SizedBox(height: 40,),

             
              Text(
                'Welcome',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), 
              ),

             
              Text(
                'Start with sign in or sign up',
                style: TextStyle(fontSize: 20), 
              ),
              
              
              SizedBox(height: 50), 

       
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 54, 136, 203),
                            foregroundColor: Colors.white),
                onPressed: () {
             
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                child: Text('SIGN IN'),
              ),
            ),
              
              SizedBox(height: 20),

            //sign up button
            SizedBox(
              width: double.infinity,
              child:ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 54, 136, 203), 
                          foregroundColor: Colors.white,),
                onPressed: () {
      
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const SelectRoleScreen())
                  );
                },
                child: Text('SIGN UP'),
              ),
            ),

              SizedBox(height: 30),

              //guest user button
              TextButton(
                onPressed: () {
                  Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context)=> const GuestDashboard()),
                  );
                },
                child: Text(
                  'Continue as a Guest User',
                  style: TextStyle(color: const Color.fromARGB(255, 4, 103, 184)), 
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    )
    );
  }
}