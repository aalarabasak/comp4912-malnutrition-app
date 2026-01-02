import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../screens/child-profile-history-screens/measurements_history_screen.dart'; 
import '../helper-widgets/info_display_widgets.dart'; 

class LatestMeasurementCard extends StatelessWidget{
  final QueryDocumentSnapshot latestDoc; 
  final String childId; //need for navigation

  const LatestMeasurementCard({super.key,required this.latestDoc,required this.childId,});

  @override
  Widget build(BuildContext context){
    
    //convert the doc to Map 
    Map<String, dynamic> measurementdata = latestDoc.data() as Map<String, dynamic>;

    String muac = measurementdata['muac'].toString();
    String weight = measurementdata['weight'].toString();
    String height = measurementdata['height'].toString();
    String edema = measurementdata['edema'].toString();
    String date = measurementdata['dateofMeasurement'].toString();
    String notes = measurementdata['notes']?.toString() ?? '';

      
      return GestureDetector(
        onTap: () {//navigate to the history screen when tapped
          Navigator.push(context, MaterialPageRoute(builder: (context) => MeasurementsHistoryScreen(childid: childId)));
        },
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 15.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(10.0),
            color: const Color.fromARGB(255, 226, 237, 240),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Measurements: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400],),
                ],
              ),
              
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
  }
}