import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malnutrition_app/screens/risk_status_history_screen.dart';
import 'package:malnutrition_app/widgets/info_display_widgets.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class RiskStatusCard extends StatelessWidget{
  final String childId;

  const RiskStatusCard({super.key, required this.childId});

  Map<String,dynamic> calculateRisk(double muac, String edema){
    if(edema == 'Yes'){
      return {'text': 'High Risk', 'reason': 'Edema detected'};
    }
    if(muac < 115){
      return {'text': 'High Risk', 'reason': 'MUAC: $muac mm (<115)'};
    }
    if(muac >=  115 && muac < 125){
      return {'text': 'Moderate Risk', 'reason': 'MUAC: $muac mm'};
    }
    return {'text': 'Healthy', 'reason': 'Measurements are stable'};
  }

  double calculateGaugeValue(double muac, String edema){
    if(edema == 'Yes' || muac < 115){
      return 2.5;
    }
    if(muac >=  115 && muac < 125){
      return 1.5;
    }
    return 0.5;
  }


  @override
  Widget build(BuildContext context){
    return StreamBuilder(
      stream:FirebaseFirestore.instance
      .collection('children')
      .doc(childId)
      .collection('measurements')
      .orderBy('recordedAt', descending: true)
      .limit(1)
      .snapshots(),

      builder:(context, snapshot) {
        if(snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty){
          return buildCards("Risk Status", "No available data");
        }

        var data = snapshot.data!.docs.first.data();

        double muac = double.tryParse(data['muac'].toString()) ?? 0;
        String edema = data['edema'];

        //get the values
        double gaugevalue = calculateGaugeValue(muac, edema);
        var info = calculateRisk(muac, edema);

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => RiskStatusHistoryScreen(childid: childId)));
          },
        child:Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 15.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
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
              SizedBox(
                height: 150,
                child: SfRadialGauge(
                  axes: <RadialAxis>[RadialAxis(
                    minimum: 0, maximum: 3, showLabels: false, showTicks: false, 
                    startAngle: 180, endAngle: 0,
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

                    GaugeRange(startValue: 2, endValue: 3, color: Colors.red, startWidth: 0.2, endWidth: 0.2, sizeUnit: GaugeSizeUnit.factor,),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: gaugevalue,
                      needleColor: Colors.black87,
                      enableAnimation: true,
                      knobStyle: KnobStyle(color: Colors.black87),
                    )
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Risk Status ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                          Text(info['text'], style: TextStyle(fontSize: 12, color: Colors.grey[800]),),
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

              Divider(),
              //reasons kısmı
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
                        Text(info['reason'], style: TextStyle(fontSize: 15),),
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