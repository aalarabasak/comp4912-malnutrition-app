import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/helper-widgets/info_display_widgets.dart';

class RiskPieChart extends StatelessWidget{

  final double greencount;
  final double yellowcount;
  final double redcount;

  const RiskPieChart({
    super.key,required this.greencount,required this.yellowcount,required this.redcount});

  @override
  Widget build(BuildContext context){
    return Row(
      children: [

        SizedBox(
          height: 130,
          width: 130,
          child: PieChart(
            PieChartData(
              sectionsSpace: 1,
              centerSpaceRadius: 30,
              sections: [

                if((greencount == 0) && (yellowcount == 0)&&(redcount ==0))...[
                  PieChartSectionData(
                    color: Colors.grey.shade300,
                    value: 1, 
                    radius: 35,
                    showTitle: false,
                  )
                ]
                else...[
                  //normal risk
                  PieChartSectionData(
                    value: greencount,
                    color: Colors.green.shade300,
                    radius: 35,
                    showTitle: false,
                  ),
                  //medium risk
                  PieChartSectionData(
                    value: yellowcount,
                    color: Colors.orange.shade300,

                    radius: 35,
                    showTitle: false

                  ),
                  //high risk
                  PieChartSectionData(
                    value: redcount,
                    color: Colors.red.shade400,
                    radius: 35,
                    showTitle: false

                  ),
                ]
               

                
              ],
              
            )
          ),
        ),

        
        const SizedBox(width: 45),
        //legend
        Expanded(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildlegendwithvalue(Colors.green, "Healthy: ", greencount.toInt()),
              const SizedBox(height: 8),
              buildlegendwithvalue(Colors.orange, "Moderate Risk: ", yellowcount.toInt()),
              const SizedBox(height: 8),
              buildlegendwithvalue(Colors.red.shade400, "High Risk: ", redcount.toInt()),
            ],
          )
        )
        
      ],
    );
  }




}