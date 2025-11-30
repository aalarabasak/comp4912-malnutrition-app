import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';//for min-max operations

class WeightChart extends StatelessWidget{

  final List<FlSpot> spots;
  final List<String> dates;

  const WeightChart({super.key, required this.dates, required this.spots});

  Widget build(BuildContext context){
    if(spots.isEmpty){
      return const Center(child: Text("No weight data available yet."));
    }

    // --- 1. Y EKSENİ DİNAMİK VE TEMİZ HESAPLAMA (SNAP TO GRID) ---
    
    // Ham verilerin en küçüğünü ve en büyüğünü bul
    double rawMinY = spots.map((e) => e.y).reduce(min);
    double rawMaxY = spots.map((e) => e.y).reduce(max);
    
    // Veri aralığını hesapla (Range)
    double range = rawMaxY - rawMinY;

    // Adım 1: Aralığa göre en mantıklı adım sayısını (interval) belirle
    // Bu, sayıların üst üste binmesini engeller.
    double yInterval;
    if (range >= 20) {
      yInterval = 5; // Fark çoksa 5'er 5'er git (20, 25, 30...)
    } else if (range >= 10) {
      yInterval = 2; // Orta farkta 2'şer git (12, 14, 16...)
    } else if (range >= 2) {
      yInterval = 1; // Az farkta 1'er git (13, 14, 15...)
    } else {
      yInterval = 0.5; // Çok hassas farkta 0.5 git (13.5, 14.0...)
    }

    // Adım 2: Min ve Max değerlerini seçilen aralığın TAM KATLARINA yuvarla.
    // Bu matematiksel işlem "13.5" gibi ara değerlerde başlamayı engeller,
    // grafiği en yakın tam aralığa (örneğin 13.0 veya 12.0) çeker.
    // (yInterval * 0.5) payı bırakarak çizginin tavana/tabana yapışmasını önlüyoruz.
    double minY = ((rawMinY - (yInterval * 0.5)) / yInterval).floor() * yInterval; 
    double maxY = ((rawMaxY + (yInterval * 0.5)) / yInterval).ceil() * yInterval;

    // Kilo negatif olamayacağı için 0 kontrolü
    if (minY < 0) minY = 0;

    // Eğer tek bir veri varsa veya değerler aynıysa (Düz çizgi durumu),
    // manuel olarak alt ve üst sınır oluştur.
    if (minY == maxY) {
      minY -= yInterval;
      maxY += yInterval;
      if (minY < 0) minY = 0;
    }

    // --- 2. X EKSENİ OPTİMİZASYONU ---
    double xInterval = 1;
    if (dates.length > 8) {
      // Eğer çok fazla tarih varsa, tarihleri atlayarak göster (çakışmayı önler)
      xInterval = (dates.length / 5).ceilToDouble();
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
                  horizontalInterval: yInterval, //calculated interval
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
                      reservedSize: 30,//put 30 units space for text at the bottom
                      interval: xInterval,
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
                       // Eğer sayı tam sayı ise (14.0 gibi), ".0" kısmını at.
                      if (value % 1 == 0) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        );
                      }
                      // Değilse ondalıklı göster (14.5)
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
                isCurved: false,
                color: const Color(0xFF2196F3), // line color
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
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