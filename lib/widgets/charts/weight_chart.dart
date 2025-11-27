import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

//!!!replace with real data later
  List<FlSpot> get _dummyData {
    return [
      FlSpot(0, 11.5),  // x = 0, y = 11.5 kg (Başlangıç)
      FlSpot(1, 11.8),  // x = 1, y = 11.8 kg
      FlSpot(2, 12.0),  // x = 2, y = 12.0 kg
      FlSpot(3, 11.7),  // x = 3, y = 11.7 kg (Kilo kaybı - Uyarı!)
      FlSpot(4, 11.9),  // x = 4, y = 11.9 kg (Toparlanma başlıyor)
      FlSpot(5, 12.4),  // x = 5, y = 12.4 kg
      FlSpot(6, 12.8),  // x = 6, y = 12.8 kg (Sağlıklı büyüme trendi)
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

class WeightChart extends StatelessWidget{
  const WeightChart({super.key});

  Widget build(BuildContext context){
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
                  horizontalInterval: 0.5, //draw a line every 0.5 unit
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
                    reservedSize: 35,//put 35 units space for text at the bottom
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
                    interval: 0.5,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(1), // eg 11.0, 11.5, 12.0
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
                    color: const Color(0xFF2196F3), // line color                
                    barWidth: 3,
                    

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
                  )
                ],

              minY: 10, 
              maxY: 14,
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