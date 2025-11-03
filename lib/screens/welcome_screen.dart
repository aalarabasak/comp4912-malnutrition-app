
import 'package:flutter/material.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //scaffold iskelet
    return Scaffold(
      body: SafeArea(
        // Center: ekranın ortasına hizalar.
        child : Padding(padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(
          // Column : alt alta dizeceğimizi söyler.
          child: Column(
            // mainAxisAlignment... dikey olarak ortalamak için.
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              //1.eleman fotoğraf
              Image.asset('assets/images/IMG_8656.JPG', height:300,),
              // https://www.pinterest.com/pin/680606562448569845/sent/?invite_code=b7e2fd4dbf5b4b75823f47b656cd5a59&sender=857091510242561090&sfo=1


              SizedBox(height: 40,),

              //2. eleman
              Text(
                'Welcome',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), 
              ),

              // 3. eleman 
              Text(
                'Start with sign in or sign up',
                style: TextStyle(fontSize: 20), 
              ),
              
              
              SizedBox(height: 50), 

            // 4. eleman sign up butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 54, 136, 203),
                            foregroundColor: Colors.white),
                onPressed: () {
                  //will be updated
                },
                child: Text('SIGN IN'),
              ),
            ),
              
              SizedBox(height: 20),

            // 5. eleman sign in butonu
            SizedBox(
              width: double.infinity,
              child:ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 54, 136, 203), 
                          foregroundColor: Colors.white,),
                onPressed: () {
                  // will be updated
                },
                child: Text('SIGN UP'),
              ),
            ),

              SizedBox(height: 30),

              // 6. eleman Guest User Butonu
              TextButton(
                onPressed: () {
                  //will be updated
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
    )
    );
  }
}