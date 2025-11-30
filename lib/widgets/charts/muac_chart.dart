import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MuacChart extends StatelessWidget{

  final List<FlSpot> spots;
  final List<String> dates;
  const MuacChart({
    super.key,
    required this.dates,
    required this.spots,
    });

Widget build(BuildContext context){
  if(spots.isEmpty){
    return const Center(child: Text("No MUAC data available yet."));
  }

  

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
      aspectRatio: 1.5,//width/height ratio is 1.5
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 16.0),
        child: ClipRRect(//rounded corner crop tool
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: LineChart( LineChartData(//actual graphic starts here

              borderData: FlBorderData(//remove top and right border lines
                show: true,
                border: const Border(
                  bottom: BorderSide(color: Colors.grey, width: 1),
                  left: BorderSide(color: Colors.grey, width: 1),
                  right: BorderSide.none,
                  top: BorderSide.none,
                ),
              ),

              // Background risk zones - colors using RangeAnnotations
              rangeAnnotations: RangeAnnotations(
                horizontalRangeAnnotations: [
                  HorizontalRangeAnnotation(// red zone high Risk 
                    y1: 100, y2: 114.9,
                    color: Colors.red.withOpacity(0.2),
                  ),

                  HorizontalRangeAnnotation(// yellow zone moderate Risk 
                    y1: 115, y2: 124.9,
                    color: Colors.amber.withOpacity(0.2),
                  ),

                  HorizontalRangeAnnotation(// green zone no Risk 
                    y1: 125, y2: 145,
                    color: Colors.green.withOpacity(0.2),
                  ),

                ]
              ),

              //grid lines -yatay ızgara çizgileri
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,//Draw a line every 10 units
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
                  reservedSize: 30//increased space at top for Y-axis label visibility
                ),                ),

                bottomTitles:AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,//put 35 units space for text at the bottom
                    getTitlesWidget: (value, meta) {
                      final i =value.toInt();
                      if(i >= 0 && i < dates.length){
                        // Check if this is a whole number (not a decimal)
                      if (value == value.toInt().toDouble()) { //Prevents double writing on the x-axis
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dates[i],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
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
                  interval: 10,
                  getTitlesWidget: (value, meta) {
                    // Show values 100, 110, 120, 130, 140 
                    if (value == 100 || value == 110 || value == 120 || 
                        value == 130 || value == 140) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              ),

            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,//let the lines be smooth
                color: Colors.black87,
                barWidth: 3,
                isStrokeCapRound: true,


              ),
            ],

            // Min and max values for Y-axis
            minY: 100,
            maxY: 145,
            // Min and max values for X-axis
            minX: -0.5,
            maxX: spots.length - 0.5,

            




            ),
              
            ),
          ),
        ),
      ),
    ),
  );
}
}