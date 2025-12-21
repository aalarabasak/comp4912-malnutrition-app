import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrendLineChart extends StatelessWidget{

  final List <FlSpot> spots;
  final List <String> datelabels;


  const TrendLineChart({
    super.key, 
    required this.datelabels, 
    required this.spots,

  });

  @override
  Widget build(BuildContext context){
    if(spots.isEmpty){
      return const Center(child: Text("No data available."));
    }

    //find the top value to prevent overflow
    double maxy = 0;
    for(var spot in spots){
      if(spot.y> maxy){
        maxy = spot.y;
      }
    }
    
    
    return  AspectRatio(
        aspectRatio: 1.8, 
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 5),
          child: LineChart(LineChartData(
            //grid lines
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1, 
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2), strokeWidth: 1, 
                  dashArray: [4,5] //dashed line
                );
              },
            ),

            borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(color: Color.fromARGB(255, 100, 100, 100), width: 1),
                left: BorderSide(color: Color.fromARGB(255, 100, 100, 100), width: 1),
                right: BorderSide.none,
                top: BorderSide.none,
              )
            ),

            //limits of the chart
            minY: 0,
            maxY: maxy+1,
            minX: -0.5,
            maxX: spots.length.toDouble()-0.8,

            //axises
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

              //x axis
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,//space for labels
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();//convert value double to i int 

                    if(i>= 0 && i < datelabels.length){

                      if (value == value.toInt().toDouble()) { //Prevents double writing on the x-axis
                      //only show labels at integer positions
                      if (datelabels.length > 7 && i % 2 != 0) {
                        return const SizedBox.shrink();//if there is a lot of datashow it by skipping labels
                      }

                      return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(datelabels[i],style: const TextStyle(color: Colors.black45,fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }  
                    }
                    return const SizedBox.shrink();
                  },

                )
              ),

              //y axis
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 23,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if(value % 1 == 0){
                      return Text(value.toInt().toString(), 
                        style: const TextStyle(color: Colors.black45,fontSize: 11,fontWeight: FontWeight.w600),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                )
              ),
              

            ),

            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.redAccent.shade400,
                barWidth: 3,
                isStrokeCapRound: true,//rounded ends

                //points
                dotData: FlDotData(
                  show: true,
                  getDotPainter:(spot, percent, barData, index) {
            
                    return FlDotCirclePainter(radius: 6, color: Colors.redAccent);
                  },
                ),

                belowBarData: BarAreaData(show: false),
              )
            ],

            //touch handling
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => Colors.blueGrey,
                
              )
              
            )

          )
          ),
        ),
      );
    
  }

}