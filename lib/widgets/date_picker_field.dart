import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget{

//The selected date will be written to this controller as a formatted string.
// This controller passes the selected date value back up to the parent widget.
final TextEditingController controller; 
final String labelText;
final DateTime firstDate;

// Validation function that checks the input and returns an error message or nothing.
final FormFieldValidator<String> validator; 
  const DatePickerField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.validator,
    required this.firstDate,
  });

  @override
  Widget build(BuildContext context){
    return TextFormField(
      controller: controller,
      readOnly: true, //prevents keyboard because it is date picker not a text field to write
      decoration: InputDecoration(
        labelText: labelText,
        border:  OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today_outlined),
        hintText: 'Tap to select date',
      ),
      validator: validator,
      
      //I got this piece of code from the link below:
      //https://api.flutter.dev/flutter/material/showDatePicker.html
      onTap: () async{//Show Flutter's ready calendar (showDatePicker).
        DateTime? selecteddate = await showDatePicker(
          context: context,
          initialDate:DateTime.now(),
          firstDate: firstDate,
          lastDate: DateTime.now(),
        );

      //If the user picked a date, Format the date to year-month-day 
        if(selecteddate != null){
          String date = '${selecteddate.day}/${selecteddate.month}/${selecteddate.year}';
          controller.text = date;
        }
      },
    );
  }
}