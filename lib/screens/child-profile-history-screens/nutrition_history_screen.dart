import 'package:flutter/material.dart';
import 'package:malnutrition_app/services/nutrition_history_service.dart';
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

  int selectedindex = 4; //default shows the last week
  bool isloading = true;
  List<Map<String, dynamic>> historydata = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future <void> loadData() async{
    final data = await NutritionHistoryService.getWeeklyNutritiondata(widget.childId);

    if(mounted){
      setState(() {
        historydata = data;
        isloading=false;

        if(historydata.isNotEmpty){//default selected index to the last element newest week
          selectedindex = historydata.length-1;
        }
      });
    }
  }
  

  @override
  Widget build(BuildContext context){

    if(isloading){
      return const Scaffold(body: Center(child: CircularProgressIndicator()),
      );
    }


    if(historydata.isEmpty){
      return Scaffold(
        appBar: AppBar(title: const Text('Weekly Nutrition Analysis')),
        body: const Center(child: Text("No nutrition data found for the last 5 weeks.")),
      );
    }

    final currentdata = historydata[selectedindex]; //get data for the selected week


    return Scaffold(
      backgroundColor:const Color(0xFFF5F7FA) ,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('Weekly Nutrition Analysis', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 19)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: Column(
          children: [
            //chart wiht touch callback
            NutritionLineChart(
              caloriespots: historydata.map((e) => e['calPercent'] as double).toList(),
              proteinspots: historydata.map((e) => e['proPercent'] as double).toList(),
              dateLabels: historydata.map((e) => e['dateRange'] as String).toList(),//pass the formatted date strings to the chart
              onPointTapped: (index) {
                setState(() {
                  selectedindex = index;//saves which data point was tapped 
                });
              },
              ),

              const SizedBox(height: 11),

      
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
                eatenkcal: (currentdata['cal'] as double).toInt(),
                eatenprotein: (currentdata['pro'] as double).toInt(),
                percentagecal: currentdata['calPercent'],
                percentageprotein: currentdata['proPercent'],
                percentagecarbs: currentdata['carbPercent'],
                percentagefat: currentdata['fatPercent'],
                eatencarbs: (currentdata['carb']as double).toInt(),
                eatenfat:(currentdata['fat']as double).toInt() ,
                )
          ],
        ),
      ),
    );
  }
}