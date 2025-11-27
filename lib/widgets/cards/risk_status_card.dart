import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malnutrition_app/screens/risk_status_history_screen.dart';
import 'package:malnutrition_app/utils/risk_calculator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class RiskStatusCard extends StatelessWidget{
  final QueryDocumentSnapshot latestdoc;//takes the doc-data as a parameter
  final String childId; 

  const RiskStatusCard({super.key, required this.latestdoc, required this.childId, });


  @override
  Widget build(BuildContext context){
    
    var data = latestdoc.data() as Map<String, dynamic>;
    
    String textStatus = data['calculatedRiskStatus'] ?? 'Healthy'; //healthy is insurance
    String reason = data['riskReason'] ?? 'No previous risk data available'; //no data available is insurance

    var resultGaugeDetails = RiskCalculator.calculateGaugeValueandColor(textStatus);
  
    
    //UI PART
    return GestureDetector(// Make the card clickable
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RiskStatusHistoryScreen(childid: childId)));
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 15.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(// Card styling (background color, borders, shadow)
          color: const Color.fromARGB(255, 226, 237, 240),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey[400]!),          
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
                    value: resultGaugeDetails['gaugevalue'],
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
                        Text(textStatus, style: TextStyle(fontSize: 12, color: resultGaugeDetails['statusColor'], fontWeight: FontWeight.w600),),
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
                      Text(reason, style: TextStyle(fontSize: 15),),
                    ],
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
