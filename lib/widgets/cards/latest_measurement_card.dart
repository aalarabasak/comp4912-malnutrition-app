import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../screens/measurements_history_screen.dart'; 
import '../info_display_widgets.dart'; 

class LatestMeasurementCard extends StatelessWidget{
  final String childId;

  const LatestMeasurementCard({super.key,required this.childId});

  @override
  Widget build(BuildContext context){
    return StreamBuilder <QuerySnapshot>(
    stream: FirebaseFirestore.instance
    .collection('children') //go to children collection
    .doc(childId) //go to specific child
    .collection('measurements') //go to measurements subcollection
    .orderBy('recordedAt', descending: true) //Sort by date, newest to oldest
    .limit(1)//give the latest measurement results
    .snapshots(), 

    builder:(context, snapshot) {

      if(snapshot.hasError){
        return buildCards("Measurements", "Error loading data");
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return buildCards("Measurements", "Loading...");
      }

      if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MeasurementsHistoryScreen(childid: childId)));
          },
          child: buildCards("Measurements", "No measurements yet."),
        );      
      }

      var latestDocument = snapshot.data!.docs.first;
      Map <String, dynamic> measurementdata = latestDocument.data() as Map <String,dynamic>;

      String muac = measurementdata['muac'].toString();
      String weight = measurementdata['weight'].toString();
      String height = measurementdata['height'].toString();
      String edema = measurementdata['edema'].toString();
      String date = measurementdata['dateofMeasurement'];
      String notes = measurementdata['notes'];

      return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MeasurementsHistoryScreen(childid: childId)));
        },
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 15.0),//put space btw cards
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

              Row(
                children: [
                  Expanded(flex: 1,child: buildRichText("MUAC", muac, suffix: " mm"),),
                  Expanded(flex: 1,child: buildRichText("Weight", weight, suffix: " kg"), )
                ],              
              ),

              Row(
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