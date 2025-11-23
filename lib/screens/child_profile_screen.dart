import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:malnutrition_app/screens/add_test_results_screen.dart';
import 'package:malnutrition_app/screens/scan_barcode_screen.dart';
import '../utils(helpers)/formatting_helpers.dart';
import '../widgets/cards/latest_measurement_card.dart';
import '../widgets/info_display_widgets.dart';

class ChildProfileScreen extends StatefulWidget{

  final String childId;

  const ChildProfileScreen({
    super.key,
    required this.childId
  });

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();


}
  
class _ChildProfileScreenState extends State<ChildProfileScreen> {

  //this is for add meal button's dialog page
  void showAddMealOptions(BuildContext context){
    showDialog(
      context: context, 
      builder: (BuildContext dialogcontext){
        return AlertDialog(
          title: Text('Please choose how you want to add the meal.',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),),
          content: Column(
            mainAxisSize: MainAxisSize.min, //Adjusts window size according to content
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.qr_code_scanner),
                title: Text('Add Packaged Food'),
                onTap: () {
                  Navigator.of(dialogcontext).pop();// first close the dialog
                  //after that, direct to the barcode screen
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>  ScanBarcodeScreen(childId: widget.childId )));


                },

              ),

              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Add Unpackaged Food'),
                onTap: () {
                  Navigator.of(dialogcontext).pop();//close for now, will be updated!!!!!
                },
              )

            ],
          ),

        );

      }
      );
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Icon(Icons.monitor_heart_outlined, color: Colors.black,),
        centerTitle: true ,
        
      backgroundColor: Colors.transparent, 
      ),

      body: StreamBuilder<DocumentSnapshot> (
        stream: FirebaseFirestore.instance //this time, we get the specific child from firestore with childId that we get through home page
          .collection('children')
          .doc(widget.childId)
          .snapshots(),

        builder: (context, snapshot) {
          if(snapshot.hasError){
            return Center(child: Text('An error occured'),);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          Map <String, dynamic> childdata = snapshot.data!.data() as Map <String, dynamic>; 

          String name = childdata['fullName'];

          String temp = childdata['dateofBirth'];
          String age = calculateAge(temp);

          String caregiver = childdata['caregiverName'];
          String childidfromDB = childdata['childID'];
          String campblock = childdata['campBlock'];
          String gender = childdata['gender'];

          bool hasDisability = childdata['hasDisability'];
          String disabilityexplanation = '';

          if(hasDisability){
             disabilityexplanation = childdata['disabilityExplanation'];
          }

          return SafeArea(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ListView(

              children: [ //lots of elements from top the down
                //Header row , Name of the child + icon 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [ //there are two elements in this row
                    //name of the child
                    Expanded(child: Text(name, style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600 ),)),

                    //ICON
                    Icon(Icons.person, size: 60, color: const Color.fromARGB(255, 110, 109, 109), ),
                  ],
                ),//End of header row

                const SizedBox(height: 5),

                //child's personal information
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 155, 211, 237),
                    borderRadius: BorderRadius.circular(10.0),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildinformationrow("Age", age ),
                      buildinformationrow("Gender", gender),
                      buildinformationrow("ID", childidfromDB),
                      buildinformationrow("Camp Block", campblock),
                      buildinformationrow("Caregiver", caregiver),
                      buildinformationrow("Has Disability", hasDisability ? "Yes" : "No"),

                      if(hasDisability)
                        buildinformationrow("Explanation " , disabilityexplanation),
                    
                    ],
                  ) ,
                ),

                //Risk status info card
                buildCards(
                  "Risk Status", 
                  "-",),
                
                //measurements info card
                LatestMeasurementCard(childId: widget.childId),
                  

                //Nutrition summary info card
                buildCards(
                  "Nutrition Summary", 
                  "-"),

                //recent activities info card
                buildCards(
                  "Recent Activities", 
                  "-"),

                const SizedBox(height: 10,),

                Row(
                  children: [
                    //add test results button
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          textStyle: TextStyle(fontWeight: FontWeight.bold)),

                        onPressed:() {
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  AddTestResultsScreen(childid: widget.childId)));
                        },

                        icon:  Icon(Icons.text_snippet),
                        label: Text('Add Test Results'),
                        
                      )
                    ),

                    const SizedBox(width: 15), // Space between buttons

                  //add meal button
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          showAddMealOptions(context);
                        },
                        label: Text('Add Meal'),
                        icon: Icon(Icons.medication_liquid_rounded),
                      ),
                    ),
                  ],                  
                ),
                
                const SizedBox(height: 10,),

                //View AI feedback button
                Center(
                child:ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed:() {
                    //will be updated !!!!!!!
                  },
                  label: Text('View AI Feedback'),
                  icon: Icon(Icons.search_sharp),
                )
              ),

             

             ],
            
            ),
            
            
            
            ),
            );

        },
        

        
        ),
    );


  }

}
