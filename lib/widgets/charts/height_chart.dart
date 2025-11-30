import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';//for min and max calculations

class HeightChart extends StatelessWidget{

  final List<FlSpot> spots;
  final List<String> dates;

  const HeightChart({super.key, required this.dates, required this.spots});

  Widget build(BuildContext context){
    if(spots.isEmpty){
      return const Center(child: Text("No height data available yet."));
    }

    // --- 1. Y EKSENİ DİNAMİK VE TEMİZ HESAPLAMA (SNAP TO GRID) ---
    // Boy verileri genelde 50cm - 120cm vb. aralığında olur.

    double rawMinY = spots.map((e) => e.y).reduce(min);
    double rawMaxY = spots.map((e) => e.y).reduce(max);
    double range = rawMaxY - rawMinY;

    // Adım A: Aralığı (Interval) veri genişliğine göre seç
    double yInterval;
    if (range >= 20) {
      yInterval = 5; // Fark çoksa 5'er 5'er (Örn: 100, 105, 110)
    } else if (range >= 10) {
      yInterval = 2; // Orta farkta 2'şer
    } else if (range >= 2) {
      yInterval = 1; // Az farkta 1'er
    } else {
      yInterval = 0.5; // Çok hassas farkta 0.5
    }

    // Adım B: Min ve Max değerlerini seçilen aralığın TAM KATLARINA yuvarla
    // (rawMinY - yInterval * 0.5) diyerek alt tarafta sıkışmayı önlüyoruz.
    double minY = ((rawMinY - (yInterval * 0.5)) / yInterval).floor() * yInterval;
    double maxY = ((rawMaxY + (yInterval * 0.5)) / yInterval).ceil() * yInterval;

    if (minY < 0) minY = 0;

    // Tek veri veya dümdüz çizgi durumunda manuel aralık
    if (minY == maxY) {
      minY -= yInterval;
      maxY += yInterval;
      if (minY < 0) minY = 0;
    }

    // --- 2. X EKSENİ OPTİMİZASYONU ---
    double xInterval = 1;
    if (dates.length > 8) {
      xInterval = (dates.length / 5).ceilToDouble();
    }

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
                  horizontalInterval: yInterval,//calculated interval
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
                      interval: xInterval, //calculated interval
                      getTitlesWidget: (value, meta) {
                        final i =value.toInt();
                        if(i >= 0 && i < dates.length){
                          // Check if this is a whole number (not a decimal)
                        if (value == value.toInt().toDouble()) { //Prevents double writing on the x-axis
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text( dates[i],
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
                    interval: yInterval, //calculated interval
                    getTitlesWidget: (value, meta) {
                       if (value % 1 == 0) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        );
                      }
                      return Text(
                        value.toStringAsFixed(1),
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
                dotData: FlDotData(show: true),
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
              ),
            ],

            // Min and max values for Y-axis
            minY: minY,
            maxY: maxY,
            // Min and max values for X-axis with padding
            minX: -0.5,
            maxX: spots.length.toDouble() - 0.5,

            ),
              
            ),
          
      ),
    ),
  );
}
}