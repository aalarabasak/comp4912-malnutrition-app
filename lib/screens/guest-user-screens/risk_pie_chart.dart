import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/info_display_widgets.dart';//for buildlegendwithvalue function

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
          width: 130,
          height: 130,
          child: PieChart(
            PieChartData(
              sectionsSpace: 1,
              centerSpaceRadius: 30,
              sections: [
                //normal risk
                PieChartSectionData(
                  value: greencount,
                  color: Colors.green,
                  title: '${greencount.toInt()}',
                  radius: 35,

                  showTitle: false,
                ),
                //medium risk
                PieChartSectionData(
                  value: yellowcount,
                  color: Colors.orange,
                  title: '${yellowcount.toInt()}',
                  radius: 35,

                  showTitle: false,
                ),
                //high risk
                PieChartSectionData(
                  value: redcount,
                  color: Colors.red,
                  title: '${redcount.toInt()}',
                  radius: 35,

                  showTitle: false,
                ),

                
              ],
              
            )
          ),
        ),

        const SizedBox(width: 50),
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
              buildlegendwithvalue(Colors.red, "High Risk: ", redcount.toInt()),
            ],
          ),
        )
      ],
    );
  }




}