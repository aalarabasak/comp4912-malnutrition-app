import 'package:flutter/material.dart';

class WeeklyNutiritionCards extends StatelessWidget{
  final double percentagecal;
  final double percentageprotein;

  final int eatenkcal;
  final int eatenprotein;
  final int eatencarbs;
  final int eatenfat;

  const WeeklyNutiritionCards({
    super.key,
    this.eatencarbs=0,
    this.eatenfat =0,
    required this.eatenkcal,
    required this.eatenprotein,
    required this.percentagecal,
    required this.percentageprotein,
  });

  @override
  Widget build(BuildContext context){
    //calculating targets from percentage using formula:Target = Eaten / Percent
    int targetkcal;
    if(percentagecal >0){
      targetkcal = (eatenkcal/percentagecal).round();
    }
    else{
      targetkcal=0;
    }

    int targetprotein;
    if(percentagecal >0){
      targetprotein = (eatenprotein/percentageprotein).round();
    }
    else{
      targetprotein=0;
    }

    // Diğerleri için şimdilik varsayılan yüzde (Mock)
    double carbsPercent = 0.55; 
    double fatPercent = 0.70; 
    int targetCarbs = (eatencarbs > 0) ? (eatencarbs / carbsPercent).round() : 100;
    int targetFat = (eatenfat > 0) ? (eatenfat / fatPercent).round() : 50;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.grey.withOpacity(0.06),
            spreadRadius: 4,
            blurRadius: 15,
            offset: const Offset(0, 4),
        )]
      ),

      child: Column(
        children: [
          //1st row.  kcal - protein progress bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildCircularBar(
                title: "Calories", 
                current: eatenkcal, 
                target: targetkcal, 
                percentage: percentagecal, 
                color: Colors.orange.shade600, 
                unit: "kcal"),
              
               buildCircularBar(
                title: "Protein", 
                current: eatenprotein, 
                target: targetprotein, 
                percentage: percentageprotein, 
                color: Colors.redAccent, 
                unit: "g"),
            ],
          ),

          const SizedBox(height: 8),
          //2nd row- carb and fat progres bars side to side 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               buildCircularBar(
                title: "Carbs", 
                current: eatencarbs, 
                target: targetCarbs, 
                percentage: carbsPercent, 
                color: Colors.amber, 
                unit: "g"),
              
               buildCircularBar(
                title: "Fats", 
                current: eatenfat, 
                target: targetFat, 
                percentage: fatPercent, 
                color: Colors.green, 
                unit: "g"),
            ],
          ),


        ],
      ),
    );
  }

  Widget buildCircularBar({
    required String title,
    required int current,
    required int target,
    required double percentage,
    required Color color,required String unit,}){

    //prevent overflowa
    double displaypercent;
    if(percentage >1.0){
      displaypercent = 1.0;
    }
    else{
      if(percentage<0.0){
      displaypercent = 0.0;
    } else{
      displaypercent=percentage;
    }
    }
    

    return Column(
      
      children: [
        Text(title,style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
        const SizedBox(height: 10),
        //https://stackoverflow.com/questions/74216632/how-can-i-make-a-progress-indicator-using-flutter
        Stack(//nested structures
          alignment: Alignment.center,
          children: [
            
            SizedBox(//background circle
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                color:  Colors.grey.shade200,
              ),

            ),

            //progress circle-colorful
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: displaypercent,
                strokeWidth: 8,
                color: color,
                strokeCap: StrokeCap.round,//circular ends
              ),
            ),

            //the center wrriting -Current/target
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //current value
                Text("$current" , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),),

                //line fraction
                Container(margin: const EdgeInsets.symmetric(vertical: 2),height: 1,width: 40,color: Colors.grey.shade400,
                ),

                //target
                Text("$target $unit" , style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey.shade600),),
              ],
            ),

          ],
          
        ),
        //the percentage writing
        const SizedBox(height: 8),
        Text("${(percentage*100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),)
      ],
      
    );
  }


}