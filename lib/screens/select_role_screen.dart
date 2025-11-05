import 'package:flutter/material.dart';
import 'signup_screen.dart';

class SelectRoleScreen extends StatelessWidget{
  const SelectRoleScreen ({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
       appBar: AppBar(leading: IconButton(icon: Icon(Icons.arrow_back),
        onPressed: () {
          //this part will be back to welcome screen
          Navigator.of(context).pop();
        },
      ),

      title: Icon(Icons.monitor_heart_outlined, color: Colors.black,),
        centerTitle: true,

      backgroundColor: Colors.transparent, 
    ),



    body: SafeArea(child: Padding( 
      padding:const EdgeInsets.symmetric(horizontal: 40.0), 
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            //first element
            Text(
              'Please choose your role...', 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),

            SizedBox(height: 50), 

            //Second element
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 229, 186, 121),
                                  foregroundColor:Color.fromARGB(255, 114, 71, 6),
                                  padding: const EdgeInsets.symmetric(vertical: 68),
                                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                       onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context)=> const SignUpScreen(selectedrole: 'Field Worker')),
                          );
                       },
                       child: Text('Field Worker'),
                )
            ),

            SizedBox(height: 20), 

            //third element
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 168, 167, 167),
                                  foregroundColor:Color.fromARGB(255, 52, 51, 51),
                                  padding: const EdgeInsets.symmetric(vertical: 68),
                                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                       onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context)=> const SignUpScreen(selectedrole: 'Nutrition Officer')),
                          );
                       },
                       child: Text('Nutrition Officer'),
                )
            ),

            SizedBox(height: 20), 

            //fourth element
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 118, 193, 120),
                                  foregroundColor:const Color.fromARGB(255, 37, 85, 38),
                                  padding: const EdgeInsets.symmetric(vertical: 68),
                                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                       onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context)=> const SignUpScreen(selectedrole: 'Camp Manager')),
                          );
                       },
                       child: Text('Camp Manager'),
                )
            ),


          ],


        ),


      ),

    
    )
    
    ),


    );

  
  }

}