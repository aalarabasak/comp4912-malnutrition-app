import 'package:flutter/material.dart';
import 'package:malnutrition_app/utils/formatting_helpers.dart';
import 'package:malnutrition_app/utils/risk_calculator.dart';
import '../../widgets/helper-widgets/date_picker_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_service.dart';

class AddTestResultsScreen extends StatefulWidget{

  final String childid;//needs to know child id to add the test for

  const AddTestResultsScreen({super.key, required this.childid}); 

  @override
  State <AddTestResultsScreen> createState() => _AddTestResultsScreenState();
}

class _AddTestResultsScreenState extends State <AddTestResultsScreen>{

  final formkey = GlobalKey<FormState>(); //control form state 
  String? selectedEdemaOption;

  final dateController = TextEditingController(); 
  final muacController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final optionalNotesController = TextEditingController();


  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(
      title: Icon(Icons.monitor_heart_outlined, color: Colors.black,),
        centerTitle: true,

      backgroundColor: Colors.transparent, 
      automaticallyImplyLeading: false, //avoid the presence of back button
    ),

    body: GestureDetector(
      onTap: () {
        //to hide the keyboard

        FocusScope.of(context).unfocus();
      },
    child:SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Form(
        key: formkey,
        child: ListView(
          children: [

     
            Text('Please fill in the details below.',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold,)),

            const SizedBox(height: 50,),

            
            DatePickerField(
              controller: dateController, 
              labelText: 'Date of Measurement', 
              validator:(value) {
                if(value == null || value.isEmpty){
                  return 'This field is required.';
                }
                return null;
              },
              firstDate: DateTime.now().subtract(Duration(days: 365)),
            ),

            const SizedBox(height: 16,),

           
            TextFormField(
              controller: muacController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'MUAC (mm)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if(value == null || value.isEmpty){
                  return 'This field is required.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16,),

            
            TextFormField(
              controller: weightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if(value == null || value.isEmpty){
                  return 'This field is required.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16,),

           
            TextFormField(
              controller: heightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if(value == null || value.isEmpty){
                  return 'This field is required.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16,),

         
            DropdownButtonFormField <String> (
              initialValue: selectedEdemaOption,
              decoration: InputDecoration(
                labelText: 'Edema',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: 'Yes',child: Text('Yes')),
                const DropdownMenuItem(value: 'No',child: Text('No')),
              ] ,
              onChanged:(newValue) {
                setState(() {
                  selectedEdemaOption= newValue;
                });
                
              },
              validator: (value) {
                if(value == null || value.isEmpty){
                  return 'This field is required.';
                }
                return null;
              },
              ),

            const SizedBox(height: 16,),

            // optional
            TextFormField(
              controller: optionalNotesController,
              decoration: InputDecoration(
                labelText: 'Notes (if any): ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 46,),

            Row(

              children: [
                
                Expanded(child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 176, 174, 174),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
                  onPressed:() {
                    Navigator.of(context).pop(); 
                  }, 
                  child: const Text('Cancel')),
                  ),

                  const SizedBox(width: 20),

                  Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 229, 142, 171).withOpacity(0.8),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                    onPressed:() async{
                      //runs all validator functions
                      bool isValid = formkey.currentState!.validate();

                      if(isValid){
                        showDialog(context: context, builder: (context) => Center(child: CircularProgressIndicator(),));

                        try{

                          // take the user inputs
                          String muactext = muacController.text.trim();
                          String weighttext = weightController.text.trim();
                          String heighttext = heightController.text.trim();

                          
                          // (,) ->> (.)
                          muactext = muactext.replaceAll(',', '.');
                          weighttext = weighttext.replaceAll(',', '.');
                          heighttext = heighttext.replaceAll(',', '.');

                          //risk calculation part
                          double muacvalue = double.tryParse(muactext) ?? 0.0;
                          String edemavalue = selectedEdemaOption ?? 'No';
                          double currentweight =double.tryParse(weighttext) ?? 0.0;
                          DateTime currentdate = parseDateString(dateController.text.trim());
                          
                          //get past records last 30  just one time
                          var historySnapshot = await FirebaseFirestore.instance
                          .collection('children')
                          .doc(widget.childid)
                          .collection('measurements')
                          .orderBy('recordedAt', descending: true)
                          .limit(30).get(); 
                          
                          //ask for weight loss using the static calculator
                          bool isweightLossDetected = RiskCalculator.checkWeightLoss(historySnapshot.docs, currentdate, currentweight);
                          
                          //get the child's current risk status 
                          var childDoc = await FirebaseFirestore.instance.collection('children').doc(widget.childid).get();
                          String? preRiskstatus = childDoc.data()?['currentRiskStatus'] as String?;
                        
                          //make risk calculation 
                          var riskresult = RiskCalculator.calculateRisk(muacvalue, edemavalue, weightLossDetected:isweightLossDetected, preRiskstatus: preRiskstatus);

                          String calculatedStatus = riskresult['textStatus'];
                          String riskReason = riskresult['reason'];
     

                          //prepare the data map
                          Map<String, dynamic> measurementdata = {
            
                            'muac': muacvalue,
                            'weight': currentweight,
                            'height': double.tryParse(heighttext) ?? 0.0,
                            'edema': selectedEdemaOption,
                            'dateofMeasurement': dateController.text.trim(),
                            'notes': optionalNotesController.text.trim(),
                            'recordedAt': FieldValue.serverTimestamp(),
               
                            'calculatedRiskStatus':calculatedStatus,
                            'riskReason':riskReason,
                          };

                          await FirebaseFirestore.instance
                          .collection('children')
                          .doc(widget.childid)
                          .collection('measurements')
                          .add(measurementdata);

                          //updating risk status 
                          await FirebaseFirestore.instance.collection('children').doc(widget.childid)
                          .update({
                            'currentRiskStatus': calculatedStatus,
                            'lastRiskUpdate': FieldValue.serverTimestamp(),
                          });

                          //add new acitivity to user's subcollection
                          await UserService().addactivity(childId: widget.childid, activitytype: "Measurement", description: "New Measurement added");

  
                          if(context.mounted){
                            Navigator.pop(context); 

                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Data is saved successfully.'),
                              backgroundColor: Colors.green,));

                            Navigator.pop(context); 
                 
                          }


                        }catch(e){
                          if(context.mounted){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save data.'),
                            backgroundColor: Colors.red,));
                          }
                        }


                      } 

                    }, 
                    child: Text('Save'))),
              ],
            ),

            const SizedBox(height: 30),


          ],

        ),
        ),
      ),
      ),

      ),


    );

  }


}