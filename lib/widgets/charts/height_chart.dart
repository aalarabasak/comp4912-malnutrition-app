import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class HeightChart extends StatelessWidget{

  final List<FlSpot> spots;
  final List<String> dates;

  const HeightChart({super.key, required this.dates, required this.spots});

  Widget build(BuildContext context){

    double minY = spots.map((e) => e.y).reduce((curr, next) => curr < next ? curr : next) - 2; // 2 cm altı
    double maxY = spots.map((e) => e.y).reduce((curr, next) => curr > next ? curr : next) + 2; // 2 cm üstü

    const Color maincolor = Colors.teal;//the theme color of the chart

    return Container(
      padding: const EdgeInsets.all(13.0), //13units of space from the inside
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4) //move the shadow down a little
          )
        ],

      ),
      child: AspectRatio(
        aspectRatio: 1.5 ,//width/height ratio is 1.5
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(
                  //remove top and right border lines
                  show: true,
                  border: Border(
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
                  horizontalInterval: 1, //draw a line every 1 unit
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
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false )),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,//put 35 units space for text at the bottom
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();

                      if(i>=0 && i < dates.length){
                        if(value == value.toInt().toDouble()){//Prevents double writing on the x-axis
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(dates[i], style: TextStyle(color: Colors.grey, fontSize: 10, ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,),
                          );
                        }
                      }
                      return Text("");
                    },
                    
                  )),


                  leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,//show numbers in 1 cm intervals
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(1), 
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.left,
                      );

                    },
                  ))

                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: maincolor, // line color                
                    barWidth: 3,

                    belowBarData: BarAreaData(
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
                  )
                ],
              //graphic limits
              minY: minY < 0 ? 0 : minY, 
              maxY: maxY,
              minX: 0,
              maxX: spots.isNotEmpty ? (spots.length - 1).toDouble() : 0,

              )
            ),
          ),
       ),
      ),
    );
  }
}