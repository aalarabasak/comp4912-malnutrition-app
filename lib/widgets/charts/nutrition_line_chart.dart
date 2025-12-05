import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../info_display_widgets.dart';

class NutritionLineChart extends StatelessWidget{
  final List<double> caloriespots;
  final List<double> proteinspots;
  final Function(int) onPointTapped;

  const NutritionLineChart({
    super.key, 
    required this.caloriespots, 
    required this.proteinspots,
    required this.onPointTapped,//parent screen wants to know when a dot is clicked, can be null
  });

  @override
  Widget build(BuildContext context){
    if(caloriespots.isEmpty || proteinspots.isEmpty){
      return const Center(child: Text("No data available."));
    }
    return Container(
      padding: const EdgeInsets.all(12.0), //12units of space from the inside
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

      AspectRatio(
        aspectRatio: 1.5,
        child: Padding(
          padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
          child: LineChart(
            LineChartData(
              //grid lines
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 0.2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1, );
                },
              ),


              //x and y borders
              borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(color: Colors.grey, width: 1),
                left: BorderSide(color: Colors.grey, width: 1),
                right: BorderSide.none,
                top: BorderSide.none,
              )
            ),

            //limits of the chart
            minY: 0,
            maxY: 1.2,
            minX: 0.5,
            maxX: caloriespots.length.toDouble() + 0.4,

            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              //weeks - x axis
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final int xValue = value.toInt();
                    // Only show labels for valid week positions (x >= 1 and x <= number of data points)
                    // Data points are at x=1, 2, 3, ..., caloriespots.length
                    if (xValue < 1 || xValue > caloriespots.length) {
                      return const SizedBox.shrink();
                    }
                    // Only show label if value is close to an integer (within 0.05)
                    if ((value - xValue).abs() > 0.05) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('W$xValue', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    );
                  },

                
                ),
                
              ),

              //left y axis
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 0.2,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    // 0.2 -> 20, 1.0 -> 100 translation
                    final int percentage = (value * 100).toInt();
                    return Text(
                      '$percentage', // just number
                      style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                )
              )

            ),

            lineBarsData: [
              LineChartBarData(
                spots: caloriespots.asMap().entries.map((e) => FlSpot((e.key + 1).toDouble(), e.value)).toList(),
                //shift x positions by +1 so data points start at x=1 instead of x=0
                isCurved: true,
                color: Colors.orange,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false)
              ),
              LineChartBarData(
                spots: proteinspots.asMap().entries.map((e) => FlSpot((e.key + 1).toDouble(), e.value)).toList(),
                //shift x positions by +1 so data points start at x=1 instead of x=0
                isCurved: true,
                color: Colors.redAccent.shade400,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false)
              )
            ],

            //touch handling
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,//show standard tooltip bubble
              touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                if(event is FlTapUpEvent && touchResponse != null && touchResponse.lineBarSpots != null){
                  final spot = touchResponse.lineBarSpots!.first;
                  // Convert shifted x position back to original index (x=1 -> index=0, x=2 -> index=1, etc.)
                  final index = spot.x.toInt() - 1;

                  if (index >= 0 && index < caloriespots.length) {////if index is valid
                    onPointTapped(index);//notifies the screen which point was tapped
                  }
                }
              },
            )
            )
          ),
        ),
      ),


      //legend-explanation of colors
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildlegend(Colors.orange, "Calories"),
          const SizedBox(width: 12),
          buildlegend(Colors.redAccent, "Protein")
        ],
      )
       ]
      )
    );
  }
}
