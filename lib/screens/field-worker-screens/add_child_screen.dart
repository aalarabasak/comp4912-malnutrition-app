import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/helper-widgets/date_picker_field.dart';

import '../../services/child_id_service.dart';

class AddChildScreen extends StatefulWidget{
  const AddChildScreen({super.key});

  @override
  State <AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State <AddChildScreen> {

  final ChildIdService childidservice = ChildIdService();
  bool isloadingid = true;
  
  final _formkey = GlobalKey<FormState>(); //control form state of each box


  String? _selectedgender;
  String? _selectedcampblock;
  bool _hasdisability = false;
  

  final _datecontroller = TextEditingController();

  final _childIDcontroller = TextEditingController();
  final _fullNamecontroller = TextEditingController();
  final _caregivercontroller= TextEditingController();
  final _disabilityexplanationController = TextEditingController();

  

  @override
  void initState(){
    super.initState();
    //set the Child ID when screen begins
    getuniquechildid();


  }

  Future<void> getuniquechildid() async {
    try {
      String uniqueid = await childidservice.getuniqueid();
      
      if (mounted) {
        setState(() {
          _childIDcontroller.text = uniqueid;
          isloadingid = false; 
        });
      }
    }
     catch (e) {
      
      if (mounted) {
        setState(() {
          _childIDcontroller.text = "Error generating ID";
          isloadingid = false;
        });
      }

    }
  }

  //cleaning function
  @override
  void dispose() {
    _datecontroller.dispose();
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
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Form(
        key: _formkey,
        child: ListView(
          children: [

       
            Text('Please fill in the details below.', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left),
            
            const SizedBox(height: 30),

          
            TextFormField(
              controller: _childIDcontroller,
              readOnly: true,
              enableInteractiveSelection: false, 
              decoration: InputDecoration(
              labelText: 'Child ID: ',
              suffixIcon: isloadingid
                        ? const Padding(
                            padding: EdgeInsets.all(12.0), 
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ): null,
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[100],
            ),
           ),

            const SizedBox(height: 16),

       
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


           
            DatePickerField(
              controller: _datecontroller, 
              labelText: 'Date of Birth', 
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'This field is required.';
                }
                return null;
              },
              firstDate: DateTime(DateTime.now().year - 5),
              ),

              const SizedBox(height: 16),

           
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

             
              CheckboxListTile(
                title: const Text('Has Disability'),
                value: _hasdisability, 
                onChanged: (newValue) {
                  setState(() {
                    _hasdisability = newValue!;
                  });
                },

                controlAffinity: ListTileControlAffinity.leading, //put the box the beginning of the text
                
                contentPadding: EdgeInsets.zero, 
                ),
                


                if(_hasdisability)
                  TextFormField(controller: _disabilityexplanationController,
                    decoration: InputDecoration(
                    labelText: 'If yes, explain..',

                  ),
                  ),
               
              const SizedBox(height: 16),

              
              Row(
                children: [
                
                  Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 176, 174, 174),
                      foregroundColor: Colors.black, 
                      padding: const EdgeInsets.symmetric(vertical: 20),//height of button
                      textStyle: const TextStyle( fontSize: 15, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
       
                    },
                    child: const Text('Cancel'),
                    )
                  ),

                  const SizedBox(width: 20),

                 
                  Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 229, 142, 171).withOpacity(0.8),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),//height of button
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                    onPressed: () async{
                      //runs all validator functions
                      bool isValid = _formkey.currentState!.validate();

  
                      if(isValid){
                        //shows loading signs after user filled the form
                        showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator(),));

        
                        try{

                          
                          
                          
                          Map<String, dynamic> childdata = {
                            'childID': _childIDcontroller.text.trim(),
                            'fullName': _fullNamecontroller.text.trim(),
                            'gender': _selectedgender,
                            'dateofBirth' : _datecontroller.text.trim(),
                            'caregiverName': _caregivercontroller.text.trim(),
                            'campBlock': _selectedcampblock,
                            'hasDisability': _hasdisability,
                            'disabilityExplanation': _hasdisability ? _disabilityexplanationController.text.trim(): null,
                            'createdAt': FieldValue.serverTimestamp(),
                            'registeredBy': FirebaseAuth.instance.currentUser?.uid, //field worker uid who registred child
                          };

                          //add data to firestore
                          await FirebaseFirestore.instance.collection('children').add(childdata);


                          if(context.mounted){
                            Navigator.pop(context); 

                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Child registered successfully.'),
                              backgroundColor: Colors.green,),
                            );

                            Navigator.pop(context); //backs to the child list screen
                          }

                        } catch (err){

                          if(context.mounted){
                            Navigator.pop(context); 

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



  
  