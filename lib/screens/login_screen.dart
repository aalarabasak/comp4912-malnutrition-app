import 'package:flutter/material.dart';
import '../widgets/password_field.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen>{
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.arrow_back),
        onPressed: () {
          //this part will be back to welcome screen
          Navigator.of(context).pop();
        },
      ),

      backgroundColor: Colors.transparent, 
    ),


      body: SafeArea(
        child : Padding(padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(
          child: Form(key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [

              Icon(Icons.monitor_heart_outlined, size: 80, color: Colors.blueGrey,),

              SizedBox(height: 30), 

              //1st element
              Text(
                'Login',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold), 
              ),

              //2nd element
              Text(
                'Sign in to continue',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal), 
              ),

              SizedBox(height: 40), 

              //3rd element
              TextFormField(
                decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email), border: OutlineInputBorder(),),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'This field is required.';
                  }
                  return null;
                },
              ),

               SizedBox(height: 20), 

              //4th element
              PasswordToggleField(
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'This field is required.';
                  }
                  return null;
                },
              ),

              SizedBox(height: 40),

              //5th element
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 54, 136, 203),
                                  foregroundColor: Colors.white),
                       onPressed: (){
                          //will be updated

                          if(_formkey.currentState!.validate()){
                            print('Form is valid');
                          }
                       },
                       child: Text('LOGIN'),
                )
              ),

              SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  //will be updated
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: const Color.fromARGB(255, 118, 118, 118)), 
                ),
              ),

              
            ],
          ),

        ),

      ),

    )
      )
    );
  }
}