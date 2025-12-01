import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';//for min and max

class MuacChart extends StatelessWidget{

  final List<FlSpot> spots;
  final List<String> dates;
  const MuacChart({
    super.key,
    required this.dates,
    required this.spots,
    });

@override
  Widget build(BuildContext context){
  if(spots.isEmpty){
    return const Center(child: Text("No MUAC data available yet."));
  }
    //use helper functions at the bottom for dynamic, grid axes.
    final yscale = calculatemuacscale(spots);
    final double minY = yscale.minY;//start of Y axis
    final double maxY = yscale.maxY;//end of Y axis
    final double yinterval = yscale.interval;
    final double xinterval = calculatexIntervalmuac(dates.length);//calculate how often to show date labels on X axis

  return Container(
    padding: const EdgeInsets.all(8.0), //8units of space from the inside-Padding inside the white card
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
    child: Column(
      mainAxisSize: MainAxisSize.min, //take up as much space as the content
      children: [
        //chart part
     AspectRatio(
      aspectRatio: 1.5,//width/height ratio is 1.5
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 16.0),
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

              // Background risk zones - colors using RangeAnnotations
              rangeAnnotations: RangeAnnotations(
                horizontalRangeAnnotations: [
                  HorizontalRangeAnnotation(// red zone high Risk 
                    y1: minY, y2: 114.9,
                    color: Colors.red.withOpacity(0.2),
                  ),

                  HorizontalRangeAnnotation(// yellow zone moderate Risk 
                    y1: 115, y2: 124.9,
                    color: Colors.amber.withOpacity(0.2),
                  ),

                  HorizontalRangeAnnotation(// green zone no Risk 
                    y1: 125, y2: maxY,
                    color: Colors.green.withOpacity(0.2),
                  ),

                ]
              ),

              //grid lines -yatay ızgara çizgileri
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yinterval,//fixed interval - 10units
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

                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false
                ),                ),

                bottomTitles:AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,//put 35 units space for text at the bottom
                    interval: xinterval, //x axis dynamic interval
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
                  interval: yinterval,
                  getTitlesWidget: (value, meta) {//// Only show whole numbers                     
                        if (value % 1 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey, 
                              fontSize: 10
                            ),
                          );
                        }
                        return const Text("");
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
                dotData: FlDotData(show: true)// Show dots on points

              ),
            ],

            // Min and max values for Y-axis
            minY: minY,
            maxY: maxY,
            // Min and max values for X-axis
            minX: -0.5,
            maxX: spots.length.toDouble() - 0.5,

            




            ),
              
            ),
          
      ),
    ),


    Row(//the legend- explanation of colors
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildlegend(Colors.red.withOpacity(0.4), "High Risk"),
        const SizedBox(width: 12),
        buildlegend(Colors.amber.withOpacity(0.4), "Moderate"),
        const SizedBox(width: 12),
        buildlegend(Colors.green.withOpacity(0.4), "Normal"),
      ],
    )
    ],
    ),
  );
}

//helper widget to create small color box plus text
Widget buildlegend(Color color, String text){
  return Row(
    children: [
      Container(//the color container indicator
        width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.rectangle),
      ),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),) //text
    ],
  );
}

//to calculate Y-axis range
({double minY, double maxY, double interval}) calculatemuacscale(List<FlSpot> spots,) {

    //find the min and max y values in the data, map> takes only y values, reduce-> finds min and max
    final datamin = spots.map((e) => e.y).reduce(min);
    final datamax = spots.map((e) => e.y).reduce(max);

    // define Standard Range-even if user data is 120-130,  show 100-140 context
    const double coremin = 100.0;
    const double coremax = 140.0;

    //if data goes below 100, expand down. If above 140, expand up.
    final viewmin = min(coremin, datamin - 5);
    final viewmax = max(coremax, datamax + 5);

    const double interval = 10;
    var minY = (viewmin / interval).floor() * interval;
    var maxY = (viewmax / interval).ceil() * interval;

    if (minY < 0) minY = 0;

    return (minY: minY, maxY: maxY, interval: interval);
  }

  //helper for xaxis intervals
  double calculatexIntervalmuac(int labelCount) {
    if (labelCount <= 8) return 1;
    return (labelCount / 5).ceilToDouble();
  }
}