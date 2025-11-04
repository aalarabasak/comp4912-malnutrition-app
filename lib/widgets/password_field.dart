import 'package:flutter/material.dart';
//I got this piece of code from the link below:
//https://medium.com/@applelappala/show-hide-password-in-flutter-how-i-do-it-1000e94e7574

class PasswordToggleField extends StatefulWidget {

  final String? Function(String?)? validator;
  const PasswordToggleField({super.key,this.validator});

  @override
  _PasswordToggleFieldState createState() => _PasswordToggleFieldState();
}

class _PasswordToggleFieldState extends State<PasswordToggleField> {
  
  bool isPasswordHidden = true; //true -> no visible, false -> visible

  @override
  Widget build(BuildContext context) {
    return TextFormField( 
      obscureText: isPasswordHidden, 
      validator: widget.validator,

      decoration: InputDecoration(
        labelText: 'Password',
        
        prefixIcon: Icon(Icons.lock), 
        
        border: OutlineInputBorder(), 
        
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordHidden ? Icons.visibility_off : Icons.visibility,
            //if isPasswordhidden is true, then the password is no visible; 
            //if it is false, thenn the password is visible
          ),
          onPressed: () {
            //updates memory
            setState(() {
              isPasswordHidden = !isPasswordHidden;
            });
          },
        ),
      ),
    );
  }
}