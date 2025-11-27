import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

//!!!replace with real data later
  List<FlSpot> get _dummyData {
    return const [
      FlSpot(0, 88.0), // Başlangıç
      FlSpot(1, 88.5),
      FlSpot(2, 89.2),
      FlSpot(3, 90.0),
      FlSpot(4, 90.8),
      FlSpot(5, 91.5),
      FlSpot(6, 92.0), // Güncel
    ];
  }

//replace with real data later
List<String>get _dummyDates{
  return[
     'Jan 1',
      'Jan 15',
      'Feb 1',
      'Feb 15',
      'Mar 1',
      'Mar 15',
      'Apr 1',
  ];
}

class HeightChart extends StatelessWidget{
  const HeightChart({super.key});

  Widget build(BuildContext context){

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

                      if(i>=0 && i < _dummyDates.length){
                        if(value == value.toInt().toDouble()){//Prevents double writing on the x-axis
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(_dummyDates[i], style: TextStyle(color: Colors.grey, fontSize: 10, ),
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
                    spots: _dummyData,
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
              minY: 87, //slightly below the lowest data
              maxY: 93,//slightly above the highest data
              minX: 0,
              maxX: 6,

              )
            ),
          ),
       ),
      ),
    );
  }
}