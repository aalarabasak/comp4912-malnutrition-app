import 'package:flutter/material.dart';
import '../widgets/date_picker_field.dart';

class AddChildScreen extends StatefulWidget{
  const AddChildScreen({super.key});

  @override
  State <AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State <AddChildScreen> {
  
  final _formkey = GlobalKey<FormState>(); //to control form state of each box

  //at first, there is no selection on dropdowns, so string has "?". 
  String? _selectedgender;
  String? _selectedcampblock;
  bool _hasdisability = false;
  
  final _datecontroller = TextEditingController();

  @override
  void dispose() {
    _datecontroller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(
      title: Icon(Icons.monitor_heart_outlined, color: Colors.black,),
        centerTitle: true,

      backgroundColor: Colors.transparent, 
    ),
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Form(
        key: _formkey,
        child: ListView(
          children: [

            //1st element
            Text('Please fill in the details below.', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left),
            
            const SizedBox(height: 30),

            //2nd element
            TextFormField(decoration: InputDecoration(
              labelText: 'Child ID',
              border: OutlineInputBorder(),
            ),
            validator: (value){
              if(value == null || value.isEmpty){
                return 'This field is required.';
              }
              return null;
            },),

            const SizedBox(height: 16),

            //3rd element
            TextFormField(decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if(value == null || value.isEmpty){
                return 'This field is required.';
              }
              return null;
            },),

            const SizedBox(height: 16),

            //4th element
            TextFormField(decoration: InputDecoration(
              labelText: 'Surname',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if(value == null || value.isEmpty){
                return 'This field is required.';
              }
              return null;
            },),

            const SizedBox(height: 16),

            //5th element
            DropdownButtonFormField <String>(
              initialValue: _selectedgender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Male', child: Text('Male')),
              ],
              onChanged: (newValue) {
                setState(() {
                  _selectedgender= newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                      return 'Please select a gender.';
                    }
                    return null;
              },
              ),

            const SizedBox(height: 16),


            //6th element date picker
            DatePickerField(
              controller: _datecontroller, 
              labelText: 'Date of Birth', 
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please select a date of birth.';
                }
                return null;
              }
              ),

              const SizedBox(height: 16),

            //7th element
            TextFormField(decoration: InputDecoration(
              labelText: 'Caregiver Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if(value == null || value.isEmpty){
                return 'This field is required.';
              }
              return null;
            },),

            const SizedBox(height: 16),

            //8th element
            DropdownButtonFormField <String>(
              initialValue: _selectedcampblock,
              decoration: const InputDecoration(
                labelText: 'Camp Block',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Block A', child: Text('Block A')),
                DropdownMenuItem(value: 'Block B', child: Text('Block B')),
                DropdownMenuItem(value: 'Block C', child: Text('Block C')),
              ],
              onChanged: (newValue) {
                setState(() {
                  _selectedcampblock= newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                      return 'Please select a camp block.';
                    }
                    return null;
              },
              ),

              const SizedBox(height: 16),

              //9 th element
              CheckboxListTile(
                title: const Text('Has Disability'),
                value: _hasdisability, 
                onChanged: (newValue) {
                  setState(() {
                    _hasdisability = newValue!;
                  });
                },

                controlAffinity: ListTileControlAffinity.leading, //Put the box at the beginning of the text
                
                contentPadding: EdgeInsets.zero, // it aligns with the others
                ),
                

                //if child has disability, the explanation code is below.
                if(_hasdisability)
                  TextFormField(decoration: InputDecoration(
                    labelText: 'If yes, explain..',
                    //border: OutlineInputBorder(),
                  ),
                  ),
               
              const SizedBox(height: 16),



              
                

                














          ],
        )


      ),
    ),
      
    
      
  ),
      
);


    
}

}



  
  






















