import 'package:flutter/material.dart';
import 'package:malnutrition_app/utils/formatting_helpers.dart';
import 'package:malnutrition_app/utils/risk_calculator.dart';
import '../../widgets/date_picker_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTestResultsScreen extends StatefulWidget{

  final String childid;//this screen needs to know child id to add the test for

  const AddTestResultsScreen({super.key, required this.childid}); //constructure function

  @override
  State <AddTestResultsScreen> createState() => _AddTestResultsScreenState();
}

class _AddTestResultsScreenState extends State <AddTestResultsScreen>{

  final formkey = GlobalKey<FormState>(); //to control form state of each box
  String? selectedEdemaOption;

  final dateController = TextEditingController(); //for date picker field
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
        //  to hide the keyboard
          // It removes focus from the currently active text field
        FocusScope.of(context).unfocus();
      },
    child:SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Form(
        key: formkey,
        child: ListView(
          children: [

            //1st element title indicator
            Text('Please fill in the details below.',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold,)),

            const SizedBox(height: 50,),

            //2nd element date of measurement bloğu
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

            //3rd element for MUAC result
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

            //4th element for weight
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

            //5th element 
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

            //6th element edema dropdown choices
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

            //7th notes section, optional
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
                //cancel button
                Expanded(child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 176, 174, 174),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onPressed:() {
                    Navigator.of(context).pop(); //closes the current screen and returns  to the previous screen.
                  }, 
                  child: const Text('Cancel')),
                  ),

                  const SizedBox(width: 20),

                  Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed:() async{
                      // This command runs all validator functions.
                      bool isValid = formkey.currentState!.validate();

                      //if everything is okay, validated
                      if(isValid){
                        showDialog(context: context, builder: (context) => Center(child: CircularProgressIndicator(),));

                        try{

                          // take the user inputs
                          String muactext = muacController.text.trim();
                          String weighttext = weightController.text.trim();
                          String heighttext = heightController.text.trim();

                          
                          // (,) ->> (.) should be in international format
                          muactext = muactext.replaceAll(',', '.');
                          weighttext = weighttext.replaceAll(',', '.');
                          heighttext = heighttext.replaceAll(',', '.');

                          //risk calculation part
                          double muacvalue = double.tryParse(muactext) ?? 0.0;
                          String edemavalue = selectedEdemaOption ?? 'No';
                          double currentweight =double.tryParse(weighttext) ?? 0.0;
                          DateTime currentdate = parseDateString(dateController.text.trim());
                          
                          //Get past records last 30 from firestore just one time
                          var historySnapshot = await FirebaseFirestore.instance
                          .collection('children')
                          .doc(widget.childid)
                          .collection('measurements')
                          .orderBy('recordedAt', descending: true)
                          .limit(30).get(); //get is not like snapshot(), it is just one time reading from firestore
                          
                          //ask for weight loss using the static calculator
                          bool isweightLossDetected = RiskCalculator.checkWeightLoss(historySnapshot.docs, currentdate, currentweight);
                          
                          // Get the child's current risk status from Firestore
                          var childDoc = await FirebaseFirestore.instance.collection('children').doc(widget.childid).get();
                          String? preRiskstatus = childDoc.data()?['currentRiskStatus'] as String?;
                        
                          //Make risk calculation with these information
                          var riskresult = RiskCalculator.calculateRisk(muacvalue, edemavalue, weightLossDetected:isweightLossDetected, preRiskstatus: preRiskstatus);

                          String calculatedStatus = riskresult['textStatus'];//???
                          String riskReason = riskresult['reason'];
                          //end of risk calc

                          //Prepare the data map
                          Map<String, dynamic> measurementdata = {
                            // Try to parse numbers if they are not suitable then it is arranged to  0.0 
                            //the suitable format: '112.0', or, '112.5'
                            'muac': muacvalue,
                            'weight': currentweight,
                            'height': double.tryParse(heighttext) ?? 0.0,
                            'edema': selectedEdemaOption,
                            'dateofMeasurement': dateController.text.trim(),
                            'notes': optionalNotesController.text.trim(),
                            'recordedAt': FieldValue.serverTimestamp(),
                            //for risk status variables->>
                            'calculatedRiskStatus':calculatedStatus,
                            'riskReason':riskReason,
                          };

                          await FirebaseFirestore.instance
                          .collection('children')
                          .doc(widget.childid)// Use the ID from the previous screen
                          .collection('measurements')// Create a new subcollection
                          .add(measurementdata);// Add new  data

                          //updating risk status based on new measurement data
                          await FirebaseFirestore.instance.collection('children').doc(widget.childid)
                          .update({
                            'currentRiskStatus': calculatedStatus,
                            'lastRiskUpdate': FieldValue.serverTimestamp(),
                          });

                          //if the process successful
                          if(context.mounted){
                            Navigator.pop(context); //close loading

                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Data is saved successfully.'),
                              backgroundColor: Colors.green,));

                            Navigator.pop(context); 
                            //close add test screen, backs to the child profile screen
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