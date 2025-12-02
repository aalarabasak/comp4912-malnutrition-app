import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RiskChart extends StatelessWidget{

  final List <FlSpot> spots;
  final List <String> dates;
  final Function(int)? onPointTapped; //callback when a point is tapped

  const RiskChart({
    super.key, 
    required this.dates, 
    required this.spots,
    this.onPointTapped,//parent screen wants to know when a dot is clicked, can be null
  });

  @override
  Widget build(BuildContext context){
    if(spots.isEmpty){
      return const Center(child: Text("No Risk data available."));
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
      child: AspectRatio(
        aspectRatio: 1.1, //width/height ratio is 1.6
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: LineChart(LineChartData(
            //grid lines
            gridData: FlGridData(
              show: true,//show grid lines
              drawVerticalLine: false,
              horizontalInterval: 1, //0-1-2 levels needs only 1 space btw them
              getDrawingHorizontalLine: (value) {//returns how each horizontal line looks
                return FlLine(
                  color: Colors.grey.withOpacity(0.2), strokeWidth: 1, 
                  dashArray: [4,5] //dashed line
                );
              },
            ),

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
            minY: -0.5,
            maxY: 2.5,
            minX: -0.5,
            maxX: spots.length-0.5,

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
                  interval: 1,//show a title for each integer x
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();//convert value double to i int 
                    if(i>= 0 && i < dates.length){
                      if (value == value.toInt().toDouble()) { //Prevents double writing on the x-axis
                      //only show labels at integer positions
                      if (dates.length > 7 && i % 2 != 0) return const Text("");//If there is a lot of data, show it by skipping labels
                      return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(dates[i],style: const TextStyle(color: Colors.grey,fontSize: 10, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }  
                    }
                    return const Text("");
                  },

                )
              ),

              //y axis
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 55,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if(value == 0){
                      return Text('Normal', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600),);
                    }
                    else if(value == 1){
                      return Text('Moderate', style: TextStyle(color: Colors.amber, fontSize: 11,fontWeight: FontWeight.w600),);
                    }
                    else if(value == 2){
                      return Text('High', style: TextStyle(color: Colors.red, fontSize: 11,fontWeight: FontWeight.w600),);
                    }
                    return const Text("");
                  },
                )
              ),
              

            ),

            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                color: Colors.grey.shade400,
                barWidth: 3,
                isStrokeCapRound: true,//rounded ends

                //points
                dotData: FlDotData(
                  show: true,
                  getDotPainter:(spot, percent, barData, index) {
                    Color dotcolor;
                    if(spot.y == 2) {
                      dotcolor = Colors.red;
                    } 
                    else if(spot.y == 1){
                      dotcolor = Colors.amber;
                    }
                    else{
                      dotcolor = Colors.green;
                    }
                    return FlDotCirclePainter(radius: 8.5, color: dotcolor);
                  },
                ),

                belowBarData: BarAreaData(show: false),
              )
            ],

            //touch handling
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,//show standard tooltip bubble
              //detect clicks-called on any touch event.
              touchCallback: (FlTouchEvent event, LineTouchResponse? touchresponse) {
                // FlTapUpEvent means user lifted their finger finished tap
                if (event is FlTapUpEvent && touchresponse != null) {
                  
                  // Get the spot that was touched
                  final spot = touchresponse.lineBarSpots?[0];//first point that was touched
                  
                  
                  // Double check nulls
                  if (spot != null && onPointTapped != null) {//if spot exists and onPointTapped is not null
                    final index = spot.x.toInt();//get index from spot.x
                    
                    
                    if (index >= 0 && index < spots.length) {//if index is valid
                      onPointTapped!(index);//notifies the screen which point was tapped
                    }
                  }
                }
              },
            )

          )
          ),
        ),
      ),
    );
  }

}