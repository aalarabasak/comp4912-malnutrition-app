import 'package:flutter/material.dart';
import '../widgets/password_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();

}

class _SignUpScreenState extends State<SignUpScreen>{

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

      title: Icon(Icons.monitor_heart_outlined, color: Colors.black,),
        centerTitle: true,

      backgroundColor: Colors.transparent, 
    ),
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0), 
      child: Center(
        child: Form(key: _formkey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //1st element
            Text('Sign Up', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),

            SizedBox(height: 40),

            //2nd element -beginning of form
            TextFormField(decoration: InputDecoration(
              labelText: 'Email', 
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter your email';
                }
                return null;
              },
              ),

            SizedBox(height: 20),

            //3rd element
            TextFormField(decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value){
              if(value == null || value.isEmpty){
                return "Please enter your username";
              }
              return null;
            },
            ),

            SizedBox(height: 20),

            //4th element
            PasswordToggleField(
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter password';
                }
                if(value.length < 8){
                  return 'Password should be at least 8 characters';
                }
                return null;

              },
            ),

            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 54, 136, 203),
                                  foregroundColor: Colors.white),
                onPressed: (){
                  //will be updated

                  if(_formkey.currentState!.validate()){
                    print('Form is valid');
                  }
                },
                child: Text('SIGN UP'),
              ),
            )


          ],


        ),
        
        
        ),



      ),
      
      
      ),
      
      
      
      ),



    );



  }


}