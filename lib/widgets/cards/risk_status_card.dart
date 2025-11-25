import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malnutrition_app/screens/risk_status_history_screen.dart';
import 'package:malnutrition_app/utils/risk_calculator.dart';
import 'package:malnutrition_app/widgets/info_display_widgets.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:malnutrition_app/utils/formatting_helpers.dart';

class RiskStatusCard extends StatelessWidget{
  final String childId;//need the child's ID to get specific data

  const RiskStatusCard({super.key, required this.childId});

  bool checkWeightLoss(List <QueryDocumentSnapshot> docs, DateTime latestdate, double currentweight){

    if (currentweight <= 0) return false; 

    double? pastweight;

    for(var doc in docs){
      var data = doc.data() as Map<String, dynamic>;

      //takes the data of measurement from list docs
      String datestring = data['dateofMeasurement'].toString();
      
      DateTime testdate = parseDateString(datestring);
      int daysdiff = latestdate.difference(testdate).inDays;//// Find the difference in days between two dates

      if(daysdiff >= 21 && daysdiff <= 35){//Search 21 to 35 days about 1 month
        pastweight = double.tryParse(data['weight'].toString());

        if(pastweight != null && pastweight >0){
          //If the weight was entered on that date -> use it as a reference and finish t
          break;
        }

      }

    }
    //If past weight is found check the 5% rule
    if(pastweight != null && pastweight>0){
      double percentage = (pastweight-currentweight)/pastweight; //apply formula
      if(percentage >= 0.05){//if it is 0.05 or greater , make it true
        return true;// Risk detected
      }
    }
    return false;//no risk
  }

  //it is for updating currentRiskStatus field in child's unique document if weight loss detected.
  void updateRiskStatusInFirestore(Map <String,dynamic> riskresult) async{
    FirebaseFirestore.instance.collection('children').doc(childId)
    .update({
      'currentRiskStatus':riskresult['textStatus'],
      'lastRiskUpdate':FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context){
    return StreamBuilder(//listen to realtime updates from Firestore
      stream:FirebaseFirestore.instance
      .collection('children')
      .doc(childId)
      .collection('measurements')
      .orderBy('recordedAt', descending: true)// Get the latest date first
      .limit(30)//pull the last 30 records to scan the history
      .snapshots(),

      builder:(context, snapshot) {
        if(snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty){
          return buildCards("Risk Status", "No available data");
        }

        // Extract data from the document
        // The ! tells Dart that I am sure data is not null here
        var latestdoc = snapshot.data!.docs.first;
        var data = latestdoc.data();

        double muac = double.tryParse(data['muac'].toString()) ?? 0;
        double currentweight = double.tryParse(data['weight'].toString()) ?? 0;
        String edema = data['edema'];
        

        String latestDateString = data['dateofMeasurement'].toString();// Parse the date of the last measurement -reference point for comparison
        DateTime latestdate = parseDateString(latestDateString);
        //run weight loss analysis function
        bool weightlossdetected =checkWeightLoss(snapshot.data!.docs, latestdate, currentweight);
        
        //call for calculator
        //get the values for UI
        var result = RiskCalculator.calculateRisk(muac, edema, weightLossDetected: weightlossdetected);       
        double gaugevalue = result['gaugevalue'];
        
        if(weightlossdetected){
          //if weightloss risk is detected, then I need to update the currentriskstatus field of the child
          //if it not detected, No updates for nothing
          updateRiskStatusInFirestore(result);//update child's status
        }
        
 
        //UI PART
        return GestureDetector(// Make the card clickable
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => RiskStatusHistoryScreen(childid: childId)));
          },
        child:Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 15.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(// Card styling (background color, borders, shadow)
            color: const Color.fromARGB(255, 226, 237, 240),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey[400]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 3),
              )
            ]
          ),
          child: Column(
            children: [
              // The Radial Gauge Widget
              SizedBox(
                height: 150,
                child: SfRadialGauge(
                  axes: <RadialAxis>[RadialAxis(
                    minimum: 0, maximum: 3, showLabels: false, showTicks: false, 
                    startAngle: 180, endAngle: 0,// Half circle shape
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.2,
                      thicknessUnit: GaugeSizeUnit.factor,
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                  ranges: <GaugeRange>[
                    //green area -healhty
                    GaugeRange(startValue: 0, endValue: 1, color: Colors.green, startWidth: 0.2, endWidth: 0.2, sizeUnit: GaugeSizeUnit.factor,),

                    //yellow area moderate risk
                    GaugeRange(startValue: 1, endValue: 2, color: Colors.amber, startWidth: 0.2, endWidth: 0.2, sizeUnit: GaugeSizeUnit.factor,),

                    //red area -high risk
                    GaugeRange(startValue: 2, endValue: 3, color: Colors.red, startWidth: 0.2, endWidth: 0.2, sizeUnit: GaugeSizeUnit.factor,),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(// The needle pointing to current status
                      value: gaugevalue,
                      needleColor: Colors.black87,
                      enableAnimation: true,
                      knobStyle: KnobStyle(color: Colors.black87),
                    )
                  ],
                  annotations: <GaugeAnnotation>[// Text displayed in the center of the gauge
                    GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Risk Status ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                          Text(result['textStatus'], style: TextStyle(fontSize: 12, color: result['statusColor'], fontWeight: FontWeight.w600),),
                        ],
                      ),
                    angle: 90,
                    positionFactor: 0.5,
                      ),
                  ],
                  )
                    
                  ],
                ),
              ),

              //----

              Divider(),//separator line
              //reasons part of the card
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reasons:' , style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.black54,),
                        SizedBox(width: 5,),
                        Text(result['reason'], style: TextStyle(fontSize: 15),),
                      ],
                    )
                  ],
                ),
              )

            ],
          ),








        )
        );
      },
      
    
    
    );
  }
}