import 'package:flutter/material.dart';
//reference:
//https://medium.com/@applelappala/show-hide-password-in-flutter-how-i-do-it-1000e94e7574

class PasswordToggleField extends StatefulWidget {

  final String? Function(String?)? validator;
  final TextEditingController? controller;
  const PasswordToggleField({
    super.key,
    this.validator, 
    this.controller});

  @override
  _PasswordToggleFieldState createState() => _PasswordToggleFieldState();
}

class _PasswordToggleFieldState extends State<PasswordToggleField> {
  
  bool isPasswordHidden = true; //true means no visible, false means visible

  @override
  Widget build(BuildContext context) {
    return TextFormField( 
      obscureText: isPasswordHidden, 
      validator: widget.validator,
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: 'Password',
        
        prefixIcon: Icon(Icons.lock), 
        
        border: OutlineInputBorder(), 
        
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordHidden ? Icons.visibility_off : Icons.visibility,
            //if isPasswordhidden is true, then the password is no visible; 
  
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