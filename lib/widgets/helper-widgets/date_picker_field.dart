import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget{


//passes the selected date value back to the parent
final TextEditingController controller; 
final String labelText;
final DateTime firstDate;


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
      
    
      onTap: () async{//show ready calendar 
        DateTime? selecteddate = await showDatePicker(
          context: context,
          initialDate:DateTime.now(),
          firstDate: firstDate,
          lastDate: DateTime.now(),
        );

      //format the date to year-month-day if there is seleciton
        if(selecteddate != null){
          String date = '${selecteddate.day}/${selecteddate.month}/${selecteddate.year}';
          controller.text = date;
        }
      },
    );
  }
}