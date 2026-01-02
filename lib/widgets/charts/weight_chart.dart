import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:malnutrition_app/utils/chart_utils.dart';

class WeightChart extends StatelessWidget{

  final List<FlSpot> spots;
  final List<String> dates;

  const WeightChart({super.key, required this.dates, required this.spots});

  @override
  Widget build(BuildContext context){
    if(spots.isEmpty){
      return const Center(child: Text("No weight data available yet."));
    }

  
    final yscale = calculatedynamicYBounds(spots);
    final double miny = yscale.miny;
    final double maxy = yscale.maxy;
    final double yinterval = yscale.interval;
    final double xinterval = calculatedynamicXInterval(dates.length);

    return Container(
      padding: const EdgeInsets.all(8.0), //8units of space from the inside
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),//move the shadow down a little
          )
        ],     
      ),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 16.0),
          child:  LineChart( LineChartData(

                borderData: FlBorderData(//remove top and right border lines
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: Colors.grey, width: 1),
                    left: BorderSide(color: Colors.grey, width: 1),
                    right: BorderSide.none,
                    top: BorderSide.none,
                  ),
                ),

                //grid lines
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yinterval, //calculated interval
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2), strokeWidth: 1,
                    );
                  },
                ),

                //axises
                titlesData: FlTitlesData(
                  show: true,
                  //dont show titles top and right
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, 
                    reservedSize: 30
                  ),                ),

                  bottomTitles:AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                        reservedSize: 30,//space for text at the bottom
                      interval: xinterval,
                      getTitlesWidget: (value, meta) {
                        final i =value.toInt();
                        if(i >= 0 && i < dates.length){
                          //check if this is a whole number 
                        if (value == value.toInt().toDouble()) { //prevents double writing on the x-axis
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(dates[i],style: const TextStyle(color: Colors.grey,fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        }
                        return Text("");
                      },
                    )
                  ),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: yinterval, //calculated interval
                    getTitlesWidget: (value, meta) {
                      if (value % 1 == 0) {//write integers without fraction
                        return Text(value.toInt().toString(),
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        );
                      }
                      return Text(value.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      );
                    },
                  ),
                ),
              ),

            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                color: const Color(0xFF2196F3), // line color
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),//put a circle where the dots are
                belowBarData: BarAreaData(//painting below the line
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF2196F3).withOpacity(0.3),
                      const Color(0xFF2196F3).withOpacity(0.0), 
                    ]
                  )
                )
              ),
            ],

           
            minY: miny,
            maxY: maxy,
         
            minX: -0.5,
            maxX: spots.length.toDouble() - 0.5,

            ),
              
            ),
          
      ),
    ),
  );
}
}