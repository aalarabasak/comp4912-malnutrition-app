import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../screens/measurements_history_screen.dart'; 
import '../info_display_widgets.dart'; // Import helper widgets for displaying rows and cards ( buildCards, buildRichText)

// This class is a StatelessWidget because its state depends only on the childId and the Firebase data stream
class LatestMeasurementCard extends StatelessWidget{
  final String childId;

  const LatestMeasurementCard({super.key,required this.childId});

  @override
  Widget build(BuildContext context){
    return StreamBuilder <QuerySnapshot>(
      // StreamBuilder listens to real-time data from firebase and rebuilds the widget when data changes
    stream: FirebaseFirestore.instance
    .collection('children') //go to children collection
    .doc(childId) //go to specific child
    .collection('measurements') //go to measurements subcollection
    .orderBy('recordedAt', descending: true) //Sort by date, newest to oldest
    .limit(1)//give the latest measurement results
    .snapshots(), 

    builder:(context, snapshot) {
      // this function decides what to display based on the stream's status ,snapshot
      if(snapshot.hasError){
        return buildCards("Measurements", "Error loading data");
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return buildCards("Measurements", "Loading...");
      }

      //check if no data exists
      if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MeasurementsHistoryScreen(childid: childId)));
          },
          child: buildCards("Measurements", "No measurements yet."),
        );      
      }

      //success case below

      var latestDocument = snapshot.data!.docs.first;
      // Convert the Firestore document data into a readable Map structure.
      Map <String, dynamic> measurementdata = latestDocument.data() as Map <String,dynamic>;

      String muac = measurementdata['muac'].toString();
      String weight = measurementdata['weight'].toString();
      String height = measurementdata['height'].toString();
      String edema = measurementdata['edema'].toString();
      String date = measurementdata['dateofMeasurement'];
      String notes = measurementdata['notes'];

      //display part
      return GestureDetector(
        onTap: () {//entire card should navigate to the history screen when tapped
          Navigator.push(context, MaterialPageRoute(builder: (context) => MeasurementsHistoryScreen(childid: childId)));
        },
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 15.0),//put space above card
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(10.0),
            color: const Color.fromARGB(255, 178, 190, 194),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Measurements: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              const SizedBox(height: 5,),

              Row(//1st row MUAC-weight side by side
                children: [
                  Expanded(flex: 1,child: buildRichText("MUAC", muac, suffix: " mm"),),
                  Expanded(flex: 1,child: buildRichText("Weight", weight, suffix: " kg"), )
                ],              
              ),

              Row(//2nd row height-edema side by side
                children: [
                  Expanded(flex: 1,child: buildRichText("Height", height, suffix: " cm"),),
                  Expanded(flex: 1,child:  buildRichText("Edema", edema),),
                ],              
              ),           
              
              if(notes.isNotEmpty)
                buildinformationrow("Notes", notes),     
                
              buildinformationrow("Last Updated", date),

            ],
          ),


        ),
      );

    },

    );
  }
}