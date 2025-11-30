import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class MuacChart extends StatelessWidget{

  final List<FlSpot> spots;
  final List<String> dates;
  const MuacChart({
    super.key,
    required this.dates,
    required this.spots,
    });

Widget build(BuildContext context){
  if(spots.isEmpty){
    return const Center(child: Text("No MUAC data available yet."));
  }

  // --- 1. Y EKSENİ İÇİN SABİT TUVAL (CORE CANVAS) MANTIĞI ---
    
    // Verilerin en düşük ve en yüksek değerlerini bul
    double dataMin = spots.map((e) => e.y).reduce(min);
    double dataMax = spots.map((e) => e.y).reduce(max);

    // MUAC için "Standart Görünüm Çerçevesi" belirliyoruz.
    // Bu aralık (90 - 150), veri ne kadar az veya dar aralıkta olursa olsun 
    // DAİMA ekranda görünecek. Böylece renkli bölgeler kaybolmayacak.
    double coreMin = 100.0; 
    double coreMax = 140.0; 

    // Eğer veriler bu çerçevenin dışına taşıyorsa (Örn: çocuk 160mm ise),
    // çerçeveyi veriye göre genişletiyoruz. Padding ekleyerek (±5 birim) 
    // çizginin kenara yapışmasını önlüyoruz.
    double viewMin = min(coreMin, dataMin - 5);
    double viewMax = max(coreMax, dataMax + 5);

    // SNAP TO GRID (IZGARAYA HİZALAMA)
    // Y ekseni çizgilerinin ve etiketlerinin her zaman 10'un katları 
    // (90, 100, 110...) olmasını sağlıyoruz. Temiz bir görüntü verir.
    double interval = 10;
    double minY = (viewMin / interval).floor() * interval;
    double maxY = (viewMax / interval).ceil() * interval;

    // MUAC değeri negatif olamaz.
    if (minY < 0) minY = 0;

    // --- 2. X EKSENİ OPTİMİZASYONU ---
    // Tarihler üst üste binmesin diye dinamik aralık
    double xInterval = 1;
    if (dates.length > 8) {
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
                horizontalInterval: interval,//fixed interval - 10units
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
                    interval: xInterval, //x axis dynamic interval
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
                  interval: interval,
                  getTitlesWidget: (value, meta) {
                    // Sadece tam sayıları göster (90, 100, 110...)
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
                dotData: FlDotData(show: true)

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



    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildlegend(Colors.red.withOpacity(0.4), "High Risk"),
        const SizedBox(width: 12),
        buildlegend(Colors.amber.withOpacity(0.4), "Moderate"),
        const SizedBox(width: 12),
        buildlegend( Colors.green.withOpacity(0.4), "No Risk"),
      ],
    )
    ],
    ),
  );
}

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
}