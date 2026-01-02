import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/helper-widgets/password_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../field-worker-screens/field_worker_home.dart';
import '../camp-manager-screens/camp_manager_home.dart';
import '../nutrition-officer-screens/nutrition_officer_home.dart';

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

      (Route<dynamic> route) => route.isFirst, ); //keep the WelcomeScreen clean logout later
  }


  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.arrow_back),
        onPressed: () {
       
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

        
              Text(
                'Login',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold), 
              ),

            
              Text(
                'Sign in to continue',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal), 
              ),

              SizedBox(height: 40), 

          
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

         
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 54, 136, 203),
                                  foregroundColor: Colors.white),
                       onPressed: () async{
                    
                          if(_formkey.currentState!.validate()){
                            showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator(),));

                          
                            try{
                              //create user in Firebase
                             UserCredential usercredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: _emailcontroller.text.trim(),
                              password: _passwordcontroller.text.trim(),);

                              // hide loading sign
                              if(context.mounted){
                                Navigator.pop(context);

                                //read the role from firestore and navigate accordingly after login 
                                String uid = usercredential.user!.uid;

                                DocumentSnapshot userdocument = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .get();

                                String role = userdocument.get('role');
                                _navigateToRelatedHome(context, role);
                              }

                              debugPrint("LOGIN SUCCESSFUL!");
                              
                              
                            }on FirebaseAuthException catch (err){

                              //hide loading sign
                              if(context.mounted){
                                Navigator.pop(context);
                              }

                      

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
                          } 
                       }
                      },
                       child: Text('LOGIN'),
                ),
              ),

              SizedBox(height: 10),

              
              
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