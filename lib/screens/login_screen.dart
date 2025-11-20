import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/password_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'field_worker_home.dart';
import 'CampManagerHome.dart';
import 'NutritionOfficerHome.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen>{
  final _formkey = GlobalKey<FormState>();

  //controllers for firebase connection 
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();

  void _navigateToRelatedHome(BuildContext context, String role){
    Widget screen;

    if(role == 'Field Worker'){
      screen = const FieldWorkerHome();
    }

    else if(role == 'Nutrition Officer'){
      screen = const NutritionOfficerHome();
    }

    else {
      screen = const CampManagerHome();
    }

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => screen),
       // (Route<dynamic> route) => false, ); // erases all history
      (Route<dynamic> route) => route.isFirst, ); //keep the WelcomeScreen to allow clean logout later.
  }


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
        child:SingleChildScrollView(
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
                controller: _emailcontroller,
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
                controller: _passwordcontroller,
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
                       onPressed: () async{
                        //Source for validation pattern in this onPressed() method:
                        //https://docs.flutter.dev/cookbook/forms/validation
                          if(_formkey.currentState!.validate()){
                            showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator(),));

                            //I used this link as a reference of try-catch block for firebase authentication
                            //https://firebase.google.com/docs/auth/flutter/password-auth
                            try{
                              // Create user in Firebase
                             UserCredential usercredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: _emailcontroller.text.trim(),
                              password: _passwordcontroller.text.trim(),);

                              // hide loading sign
                              if(context.mounted){
                                Navigator.pop(context);

                                //read the role from firestore and navigate accordingly after successful login 
                                String uid = usercredential.user!.uid;

                                DocumentSnapshot userdocument = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .get();

                                String role = userdocument.get('role');
                                _navigateToRelatedHome(context, role);
                              }

                              print("LOGIN SUCCESSFUL!");
                              
                              
                            }on FirebaseAuthException catch (err){

                              // hide loading sign
                              if(context.mounted){
                                Navigator.pop(context);
                              }

                              //print("FIREBASE ERROR: ${err.code}"); //for debug

                              // Source for error codes:
                              // https://firebase.google.com/docs/auth/admin/errors

                              String errormessage = "Login failed. Please try again.";
                              if (err.code == 'invalid-credential') {
                                errormessage = 'Invalid email or password.';
                              } 
                              else if (err.code == 'invalid-email') {
                                errormessage = 'This email address is invalid.';
                              } 
                              
                              if(context.mounted){
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(errormessage),
                                  backgroundColor: Colors.red,
                                ) 
                                 );
                              }
                          } // end of try-on
                       }// end of if
                      },
                       child: Text('LOGIN'),
                ),
              ),

              SizedBox(height: 10),

              /*TextButton(
                onPressed: () {
                  //will be updated
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: const Color.fromARGB(255, 118, 118, 118)), 
                ),
              ),
              */
              
            ],
          ),

        ),

      ),

    )
    )
      )
    );
  }
}