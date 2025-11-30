import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeightChart extends StatelessWidget{

  final List<FlSpot> spots;
  final List<String> dates;

  const WeightChart({super.key, required this.dates, required this.spots});

  Widget build(BuildContext context){
    if(spots.isEmpty){
      return const Center(child: Text("No weight data available yet."));
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
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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

                //grid lines -yatay ızgara çizgileri
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.5,//Draw a line every 0.5 units
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
                    interval: 0.5,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(1), // eg 11.0, 11.5, 12.0
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),

            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,//let the lines be smooth
                color: const Color(0xFF2196F3), // line color
                barWidth: 3,
                isStrokeCapRound: true,

                belowBarData: BarAreaData(
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

            // Min and max values for Y-axis
            minY: 10,
            maxY: 14,
            // Min and max values for X-axis with padding
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