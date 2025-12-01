import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:malnutrition_app/utils/chart_utils.dart';

class HeightChart extends StatelessWidget{

  final List<FlSpot> spots;
  final List<String> dates;

  const HeightChart({super.key, required this.dates, required this.spots});

  @override
  Widget build(BuildContext context){
    if(spots.isEmpty){
      return const Center(child: Text("No height data available yet."));
    }

    //use helpers for dynamic, grid-aligned axes.
    final yscale = calculatedynamicYBounds(spots);
    final double minY = yscale.miny;
    final double maxY = yscale.maxy;
    final double yinterval = yscale.interval;
    final double xinterval = calculatedynamicXInterval(dates.length);

    const Color maincolor = Colors.teal;//the theme color of the chart

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
          child:  LineChart( LineChartData(//actual graphic starts here

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
                  horizontalInterval: yinterval,//calculated interval
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
                      interval: xinterval, //calculated interval
                      getTitlesWidget: (value, meta) {
                        final i =value.toInt();
                        if(i >= 0 && i < dates.length){
                          // Check if this is a whole number (not a decimal)
                        if (value == value.toInt().toDouble()) { //Prevents double writing on the x-axis
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text( dates[i],style: const TextStyle(color: Colors.grey,fontSize: 10, ),
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
                    interval: yinterval, //calculated interval
                    getTitlesWidget: (value, meta) {
                       if (value % 1 == 0) {//if it is an integer-> write it without fractions, otherwise write it with a comma
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
                isCurved: true,//let the lines be smooth
                color: maincolor, // line color
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),//put a circle where the dots are
                belowBarData: BarAreaData(//painting below the line
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      maincolor.withOpacity(0.3),
                      maincolor.withOpacity(0.0), 
                    ]
                  )
                )
              ),
            ],

            // Min and max values for Y-axis
            minY: minY,
            maxY: maxY,
            // Min and max values for X-axis with padding
            minX: -0.5,
            maxX: spots.length.toDouble() - 0.5,
            //- + 0.5->prevent the first,last dots from sticking to the glass of the graphic leave some space 

            ),
              
            ),
          
      ),
    ),
  );
}
}