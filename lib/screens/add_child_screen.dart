import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/date_picker_field.dart';
import 'dart:math';

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
  
  //This is where I create the remote control for the DatePickerField.
  final _datecontroller = TextEditingController();
  //for firebase connection
  final _childIDcontroller = TextEditingController();
  final _fullNamecontroller = TextEditingController();
  final _caregivercontroller= TextEditingController();
  final _disabilityexplanationController = TextEditingController();

  String generateNewchildID(){
    final random = Random();
    // Generate 8 random digits (00000000 to 99999999)
    String id = '';
    for(int i = 0; i < 8; i++){
      id += random.nextInt(10).toString();
    }
    return id;
  }

  @override
  void initState(){
    super.initState();
    // set the Child ID when screen initializes
    final newID = generateNewchildID();
    _childIDcontroller.text = newID;

  }

  //cleaning function
  @override
  void dispose() {
    _datecontroller.dispose();//Destroy the remote if the screen is turned off.
    _childIDcontroller.dispose();
    _fullNamecontroller.dispose();
    _caregivercontroller.dispose();
    _disabilityexplanationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(
      title: Icon(Icons.monitor_heart_outlined, color: Colors.black,),
        centerTitle: true,

      backgroundColor: Colors.transparent, 
      automaticallyImplyLeading: false, //avoid the presence of back button
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
            TextFormField(
              controller: _childIDcontroller,
              readOnly: true,
              enableInteractiveSelection: false, //prevents crashing due to appearing on long-press or double-tap
              decoration: InputDecoration(
              prefixText: 'Child ID: ',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[100],
            ),
           ),

            const SizedBox(height: 16),

            //3rd element
            TextFormField(
              controller: _fullNamecontroller,
              decoration: InputDecoration(
              labelText: 'Full Name',
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
                      return 'This field is required.';
                    }
                    return null;
              },
              ),

            const SizedBox(height: 16),


            //5th element date picker
            DatePickerField(
              controller: _datecontroller, 
              labelText: 'Date of Birth', 
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'This field is required.';
                }
                return null;
              }
              ),

              const SizedBox(height: 16),

            //6th element
            TextFormField(
              controller: _caregivercontroller,
              decoration: InputDecoration(
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

            //7th element
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
                      return 'This field is required.';
                    }
                    return null;
              },
              ),

              const SizedBox(height: 16),

              //8 th element
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
                  TextFormField(controller: _disabilityexplanationController,
                    decoration: InputDecoration(
                    labelText: 'If yes, explain..',
                    //border: OutlineInputBorder(),
                  ),
                  ),
               
              const SizedBox(height: 16),

              //I used row-expanded-elevatedbutton idea from this link
              //https://stackoverflow.com/questions/71197549/how-to-create-a-row-with-2-buttons-that-take-up-the-entire-row-placed-at-the-b
              Row(
                children: [
                  //Cancel button
                  Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 176, 174, 174),
                      foregroundColor: Colors.black, 
                      padding: const EdgeInsets.symmetric(vertical: 25),//height of button
                      textStyle: const TextStyle( fontSize: 15, fontWeight: FontWeight.bold)
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      //closes the current screen and returns  to the previous screen.
                    },
                    child: const Text('Cancel'),
                    )
                  ),

                  const SizedBox(width: 20),//space btw two buttons

                  //Save button 
                  Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 25),//height of button
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                    ),
                    onPressed: () async{
                      // This command runs all 'validator' functions.
                      bool isValid = _formkey.currentState!.validate();

                      //if everything is okay->>
                      if(isValid){
                        //shows loading signs after user completely filled the form
                        showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator(),));

                        // Source for saving and preparing data to Cloud Firestore:
                        //https://firebase.google.com/docs/firestore/manage-data/add-data#set_a_document
                        try{

                          String childID = _childIDcontroller.text.trim(); // to make sure ID is unique, first I need to get it
                          final check = await FirebaseFirestore.instance //Look firestore if it exists, search
                            .collection('children')
                            .where('childID', isEqualTo: childID)
                            .get();
                          
                          // If ID exists, generate a new one
                          if(check.docs.isNotEmpty){
                            childID = generateNewchildID();
                            _childIDcontroller.text = childID;
                          }
                          
                          Map<String, dynamic> childdata = {
                            'childID': childID,
                            'fullName': _fullNamecontroller.text.trim(),
                            'gender': _selectedgender,
                            'dateofBirth' : _datecontroller.text.trim(),
                            'caregiverName': _caregivercontroller.text.trim(),
                            'campBlock': _selectedcampblock,
                            'hasDisability': _hasdisability,
                            'disabilityExplanation': _hasdisability ? _disabilityexplanationController.text.trim(): null,
                            'createdAt': FieldValue.serverTimestamp(),
                          };

                          //add data to firestore
                          await FirebaseFirestore.instance.collection('children').add(childdata);

                          //if thr saving process is successful ->>
                          if(context.mounted){
                            Navigator.pop(context); //close loading sign

                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Child registered successfully.'),
                              backgroundColor: Colors.green,),
                            );

                            Navigator.pop(context); //close add child screen, backs to the child list screen(fieldworker_home)
                          }

                        } catch (err){

                          if(context.mounted){
                            Navigator.pop(context); //close loading sign

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to save child.'),
                              backgroundColor: Colors.red,),
                            );
                          }
                        }

                      }
                    },
                    child: Text('Save Child'),
                   )
                  )
                ],
              ),

              const SizedBox(height: 30),

          ],
        )


      ),
    ),
      
    
      
  ),
      
);


    
}

}



  
  