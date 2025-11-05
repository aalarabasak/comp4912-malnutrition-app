import 'package:flutter/material.dart';
import '../widgets/password_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {

  final String selectedrole; //to keep the role of the user 

  const SignUpScreen({super.key, required this.selectedrole});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();

}

class _SignUpScreenState extends State<SignUpScreen>{

  final _formkey = GlobalKey<FormState>();

  //controllers for firebase connection 
  final _emailcontroller = TextEditingController();
  final _usernamecontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();


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
              controller: _emailcontroller,
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'This field is required.';
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
            controller: _usernamecontroller,
            validator: (value){
              if(value == null || value.isEmpty){
                return "This field is required.";
              }
              return null;
            },
            ),

            SizedBox(height: 20),

            //4th element
            PasswordToggleField(
              controller: _passwordcontroller,
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'This field is required.';
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
                onPressed: () async{ 
                  //Source for validation pattern in this onPressed() method:
                  //https://docs.flutter.dev/cookbook/forms/validation
                  if(_formkey.currentState!.validate()){
                    showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
                  
                  //I used this link as a reference of try-catch block for firebase authentication
                  //https://firebase.google.com/docs/auth/flutter/password-auth
                  try{
                    // Create user in Firebase
                    UserCredential usercredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: _emailcontroller.text.trim(),
                    password: _passwordcontroller.text.trim(),);

                    // Source for saving data to Cloud Firestore:
                    //https://firebase.google.com/docs/firestore/manage-data/add-data#set_a_document
                    await FirebaseFirestore.instance
                      .collection('users')
                      .doc(usercredential.user!.uid)
                      .set({
                        'email':_emailcontroller.text.trim(),
                        'role': widget.selectedrole,
                        'username': _usernamecontroller.text.trim(),
                        'createdat': FieldValue.serverTimestamp(),});

                    // Hide loading indicator
                    if (context.mounted) Navigator.pop(context);

                    if(context.mounted){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Account created successfully.'),
                        backgroundColor: Colors.green,
                        ) 
                      );
                    }

                    //check if user is still on sign up screen
                    if (!context.mounted) return; //this is for safety
                    Navigator.of(context).popUntil((route) => route.isFirst); //if account created successfully, back to welcome screen.

                  } on FirebaseAuthException catch (err){

                    // Hide loading indicator
                    if (context.mounted) Navigator.pop(context);

                    //these are for firebase special errors.
                    String errormessage = "An error occurred. Please try again.";
                    if (err.code == 'email-already-in-use') {
                      errormessage = 'This email is already in use.';
                    } 
                    else if (err.code == 'invalid-email') {
                      errormessage = 'The email address is invalid.';
                    }
                    
                    
                    if(context.mounted){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(errormessage),
                        backgroundColor: Colors.red,
                        ) 
                      );
                    }                 
                  }
                  } //end of if block
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
