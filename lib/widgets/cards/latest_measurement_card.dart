import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../screens/measurements_history_screen.dart'; 
import '../info_display_widgets.dart'; // Import helper widgets for displaying rows and cards ( buildCards, buildRichText)


class LatestMeasurementCard extends StatelessWidget{// This class is a StatelessWidget that receives data instead of fetching it
  final QueryDocumentSnapshot latestDoc; // Receiving just a single document is enough
  final String childId; //need for navigation

  const LatestMeasurementCard({super.key,required this.latestDoc,required this.childId,});

  @override
  Widget build(BuildContext context){
    
    // Convert the Firestore document data into a readable Map structure.
    Map<String, dynamic> measurementdata = latestDoc.data() as Map<String, dynamic>;

    String muac = measurementdata['muac'].toString();
    String weight = measurementdata['weight'].toString();
    String height = measurementdata['height'].toString();
    String edema = measurementdata['edema'].toString();
    String date = measurementdata['dateofMeasurement'].toString();
    String notes = measurementdata['notes']?.toString() ?? '';

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
            color: const Color.fromARGB(255, 226, 237, 240),
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
  }
}