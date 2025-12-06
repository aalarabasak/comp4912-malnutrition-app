import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:malnutrition_app/screens/field-worker-screens/add_test_results_screen.dart';
import 'package:malnutrition_app/screens/field-worker-screens/scan_barcode_screen.dart';
import 'package:malnutrition_app/screens/child-profile-history-screens/measurements_history_screen.dart';
import 'package:malnutrition_app/widgets/ai_feedback_button.dart';
import 'package:malnutrition_app/widgets/cards/risk_status_card.dart';
import '../../utils/formatting_helpers.dart';
import '../../widgets/cards/latest_measurement_card.dart';
import '../../widgets/info_display_widgets.dart';

class ChildProfileScreen extends StatefulWidget{

  final String childId;

  const ChildProfileScreen({super.key,required this.childId});

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
      actions: [
        //View AI feedback button
        Padding(padding: const EdgeInsets.only(right: 30.0),
        child: AiFeedbackButton(
          onPressed:() {
            //will be updated!!!!!!!
            print("ai button is presseed");
          },)
        )
      ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(247, 241, 241, 241),
          boxShadow:[
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ]
        ),
        child: SafeArea(
          child: Row(
            children: [
                  //add test results button
                  Expanded(
                              child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(vertical: 18),
                                textStyle: TextStyle(fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )),

                              onPressed:() {
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>  AddTestResultsScreen(childid: widget.childId)));
                              },

                              icon:  Icon(Icons.text_snippet),
                              label: Text('Add Test Results'),
                              
                            )
                          ),

                          const SizedBox(width: 20), // Space between buttons

                        //add meal button
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(vertical: 18),
                                textStyle: TextStyle(fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )
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
        ),
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

          // measurements StreamBuilder inside the child data StreamBuilder
          return StreamBuilder<QuerySnapshot>(
            //  Fetch once for both cards -latest measurement card and risk status card
            stream: FirebaseFirestore.instance
                .collection('children')
                .doc(widget.childId)
                .collection('measurements')
                .orderBy('recordedAt', descending: true)
                .limit(1)
                .snapshots(), // getting the last record

            builder: (context, measurementsSnapshot) {
              // error and loading checks for measurements
              if (measurementsSnapshot.hasError) {
                return Center(child: Text("Error loading measurements"));
              }
              if (measurementsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var docs = measurementsSnapshot.data?.docs ?? [];//get the data

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: ListView(
                    children: [ //lots of elements from top the down
                      //Header row : name of child + profile icon 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [ //there are two elements in this row
                          //name of the child
                          Expanded(child: Text(name, style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600 ),)),

                          //profile icon
                          Icon(Icons.person, size: 60, color: const Color.fromARGB(255, 110, 109, 109), ),
                        ],
                      ),

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

                      //give the last data to card for showing the latest risk result
                      if(docs.isNotEmpty)
                        RiskStatusCard(latestdoc: docs.first, childId: widget.childId)
                      else
                        buildCards("Risk Status: ", "No available data"),
                      
                      //give the last data to card for showing the latest measurement result
                      if(docs.isNotEmpty)
                        LatestMeasurementCard(latestDoc: docs.first, childId: widget.childId)
                      else
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MeasurementsHistoryScreen(childid: widget.childId)));
                          },
                          child: buildCards("Measurements", "No measurements yet."),
                        ),
                  

                      //Nutrition summary info card
                      buildCards(
                        "Nutrition Summary", 
                        "-"),

                      //recent activities info card
                      buildCards(
                        "Recent Activities", 
                        "-"),

                      const SizedBox(height: 20,),                    
                    ],
                  ),
                ),
              );
            },
          );

        },
        

        
        ),
    );


  }

}
