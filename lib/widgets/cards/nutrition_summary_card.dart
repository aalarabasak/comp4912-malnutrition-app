import 'package:flutter/material.dart';

class NutritionSummaryCard extends StatelessWidget{

  const NutritionSummaryCard({super.key});

  @override
  Widget build(BuildContext context){

    //mock data
    double eatenKcal = 1500;
    double targetKcal = 8400; // Haftalık hedef
    
    double eatenProtein = 200;
    double targetProtein = 210;
    
    double eatenCarbs = 600;
    double targetCarbs = 900;
    
    double eatenFat = 100;
    double targetFat = 250;




    return GestureDetector(//make card clickable
      onTap: () {
        //will be updated later!!1
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 15.0),
        padding: EdgeInsets.all(13.0),
        decoration: BoxDecoration(//card styling background color, borders, shadow
          color: const Color.fromARGB(255, 226, 237, 240),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey[400]!),   
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //title and click forward symbol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nutrition Summary :', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400],),
              ],
            ),
            
            const SizedBox(height: 15,),
            
            buildNutritionProgressBar(//calori part
              label: "Calories", 
              icon: Icons.energy_savings_leaf, 
              iconcolor: Colors.orange.shade600, 
              current: eatenKcal, 
              target: targetKcal, 
              unit: "kcal"),
            const SizedBox(height: 20),
            
            buildNutritionProgressBar(//carbs part
              label: "Carbs", 
              icon: Icons.bakery_dining_sharp, 
              iconcolor: Colors.amber, 
              current: eatenCarbs, 
              target: targetCarbs, 
              unit: "g"),
            
            const SizedBox(height: 20),

            buildNutritionProgressBar(//protein part
              label: "Protein", 
              icon: Icons.fitness_center,
              iconcolor: Colors.redAccent, 
              current: eatenProtein, 
              target: targetProtein, 
              unit: "g"),
            
            const SizedBox(height: 20),

            buildNutritionProgressBar(//fat part
              label:"Fat", 
              icon: Icons.water_drop_rounded, 
              iconcolor: Colors.green, 
              current: eatenFat, 
              target: targetFat, 
              unit: "g"),


          ],
        ),
      ),
    );
  }

  Widget buildNutritionProgressBar({//helper widget--draws progress bar etc
    required String label, required IconData icon, required Color iconcolor, required double current, required double target,
    required String unit}){
    
    //preparation
    //percentage calculation- prevent dividing 0
    double percent;
    if(target == 0){
      percent =0;
    }
    else{
      percent = current/target;
    }

    //prevent overflowa
    if(percent >1.0){
      percent = 1.0;
    }
    else if(percent<0.0){
      percent = 0.0;
    }

    //color logic->
    Color progresscolor;
    if(percent <0.5){
      progresscolor = Colors.redAccent;
    }
    else if(percent<0.8){
      progresscolor=Colors.amber;

    }
    else{
      progresscolor=Colors.green;
    }

    return Row(
      children: [
        //ıcon box
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconcolor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconcolor, size: 25,),
        ),

        const SizedBox(width: 15),


        //texts and progress bar
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(//label and number info
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("${current.toInt()} / ${target.toInt()} $unit", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13),)
              ],
            ),
            const SizedBox(height: 8),

            //progress barr
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 10,
                backgroundColor: Colors.grey[200], //head part color
                color: progresscolor, //color of the filled part-dynamic
              ),
            )

          ],
        )),

        const SizedBox(width: 17),
        Text("${(percent*100).toInt()}%", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[600]),)

      ],
 
      
    );
  }
}