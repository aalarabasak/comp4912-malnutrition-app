import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/helper-widgets/info_display_widgets.dart';//for buildlegendwithvalue function

class StockPieChart extends StatelessWidget {
  final double distributeditemsnum;
  final double remainingitemsnum;

  const StockPieChart({super.key,required this.distributeditemsnum,required this.remainingitemsnum,});

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

                if((distributeditemsnum == 0) && (remainingitemsnum == 0))...[
                  PieChartSectionData(
                    color: Colors.grey.shade300,
                    value: 1, 
                    title: '',
                    radius: 35,
                    showTitle: false,
                  )
                ]
                else...[
                  //distributed rutf items number 
                  PieChartSectionData(
                    value: distributeditemsnum,
                    color: Colors.blueGrey.shade300,
                    radius: 35,
                    showTitle: false,
                  ),

                  //remaining rutf items number 
                  PieChartSectionData(
                    value: remainingitemsnum,
                    color: Colors.pinkAccent.withOpacity(0.7),
                    radius: 35,
                    showTitle: false,
                  ),
                ],
                            
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
              buildlegendwithvalue(Colors.blueGrey.shade300, "Distributed: ", distributeditemsnum.toInt()),
              const SizedBox(height: 8),
              buildlegendwithvalue(Colors.pinkAccent.withOpacity(0.7), "Remaining: ", remainingitemsnum.toInt()),
            ],
          ),
        )
      ],
    );
  }
}