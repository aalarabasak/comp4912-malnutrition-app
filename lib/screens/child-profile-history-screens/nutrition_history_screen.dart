import 'package:flutter/material.dart';
import 'package:malnutrition_app/widgets/charts/deficit_rate_card.dart';
import '../../widgets/charts/weekly_nutirition_cards.dart';
import '../../widgets/charts/nutrition_line_chart.dart';

class NutritionHistoryScreen extends StatefulWidget{
  final String childId;
  const NutritionHistoryScreen({super.key, required this.childId});

  @override
  State<NutritionHistoryScreen> createState() => NutritionHistoryScreenState();
}

class NutritionHistoryScreenState extends State<NutritionHistoryScreen> {

  int selectedindex = 4; //by default the screen shows the last week

  //MOCK DATA, WILL BE CHANGED
  final List<Map<String, dynamic>> historyData = [
    {"week": "Week 1", "calPercent": 0.4, "proPercent": 0.3, "cal": 3000, "pro": 50, "carb": 400, "fat": 100},
    {"week": "Week 2", "calPercent": 0.55, "proPercent": 0.4, "cal": 4200, "pro": 65, "carb": 550, "fat": 130},
    {"week": "Week 3", "calPercent": 0.7, "proPercent": 0.5, "cal": 5500, "pro": 80, "carb": 700, "fat": 180},
    {"week": "Week 4", "calPercent": 0.85, "proPercent": 0.6, "cal": 6800, "pro": 95, "carb": 900, "fat": 210},
    {"week": "Week 5", "calPercent": 0.95, "proPercent": 0.8, "cal": 7200, "pro": 120, "carb": 950, "fat": 240},
  ];

  @override
  Widget build(BuildContext context){
    final currentdata = historyData[selectedindex]; //get data for the selected week
    return Scaffold(
      backgroundColor:const Color(0xFFF5F7FA) ,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('Nutrition Analysis', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 19)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: Column(
          children: [
            //chart wiht touch callback
            NutritionLineChart(
              caloriespots: historyData.map((e) => e['calPercent'] as double).toList(),
              proteinspots: historyData.map((e) => e['proPercent'] as double).toList(),
              onPointTapped: (index) {
                setState(() {
                  selectedindex = index;//saves which data point was tapped -triggers rebuild so new details appear
                });
              },
              ),

              const SizedBox(height: 11),

              //deficit rate cal-protein
              Row(
                children: [
                  //calorie deficit rate
                  Expanded(child: DeficitRateCard(title: "Calorie Deficit", achievementpercent: currentdata['calPercent'])),
                  const SizedBox(width: 10),
                  //protein deficit rate
                  Expanded(child: DeficitRateCard(title: "Protein Deficit", achievementpercent: currentdata['proPercent'])),
                ],
              ),

              const SizedBox(height: 11),
              //nutrition infos
              WeeklyNutiritionCards(
                eatenkcal: currentdata['cal'],
                eatenprotein: currentdata['pro'],
                percentagecal: currentdata['calPercent'],
                percentageprotein: currentdata['proPercent'],
                eatencarbs: currentdata['carb'],
                eatenfat:currentdata['fat'] ,
                )
          ],
        ),
      ),
    );
  }
}