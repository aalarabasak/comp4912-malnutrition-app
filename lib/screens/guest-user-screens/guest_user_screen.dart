import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:malnutrition_app/services/guest_dashboard_service.dart';
import 'risk_pie_chart.dart';
import 'stock_pie_chart.dart';
import 'trend_line_chart.dart';

enum Timefilter {all, month, week}

class GuestDashboard extends StatefulWidget {
  const GuestDashboard({super.key});

  @override
  State<GuestDashboard> createState() => GuestDashboardState();
}

class GuestDashboardState extends State<GuestDashboard>{

  Timefilter selectedfilter = Timefilter.all; //default selection
  final GuestDashboardService service = GuestDashboardService(); //call the service for firebase

  int totalchildren =0;//for total child 
  double greencount =0;//for risk
  double yellowcount =0;//for risk card
  double redcount =0;//for risk card
  bool isloading = true;
  double remainingstock=0;//for stock levels
  double usedstock=0;


  @override
  void initState() {//when the page opens first get all filtered data
    super.initState();
    getdata(); 
    
  }

  Future<void>getdata() async{
    setState(() {
      isloading = true;
    });

    String period= "all";
    if(selectedfilter == Timefilter.month) period = "month";
    if(selectedfilter == Timefilter.week) period = "week";

    int count = await service.getchildcount(period); //go service and take the value by using the func 
    Map<String,double>risks=await service.getriskvalues(period);//go service and take the value ofrisks 
    Map<String,double>stocks=await service.getstockvalues(period);

    setState(() {
      totalchildren = count;
      greencount =risks['green']!;
      redcount=risks['red']!;
      yellowcount=risks['yellow']!;
      remainingstock=stocks['remaining']!;
      usedstock =stocks['used']!;
      isloading = false; 
    });
  }

  @override
  Widget build(BuildContext context){

    // DUMMY DATA WİLL BE CHANGED DEĞİŞTİRRR



    List<FlSpot> trendSpots = [];
    List<String> trendDates = [];

    switch (selectedfilter) {
      case Timefilter.all:


        trendSpots = const [
          FlSpot(0, 2), FlSpot(1, 2), FlSpot(2, 1), 
          FlSpot(3, 1), FlSpot(4, 0), FlSpot(5, 0)
        ];
        trendDates = ["May", "Jun", "Jul", "Aug", "Sep", "Oct"];
        break;
      case Timefilter.month:



        trendSpots = const [
          FlSpot(0, 2), // Week 1: High
          FlSpot(1, 1), // Week 2: Moderate
          FlSpot(2, 1), // Week 3: Moderate
          FlSpot(3, 0), // Week 4: Normal
        ];
        trendDates = ["W1", "W2", "W3", "W4"];
        break;
      case Timefilter.week:



        trendSpots = const [
          FlSpot(0, 1), // Pzt: Moderate
          FlSpot(1, 1), // Sal: Moderate
          FlSpot(2, 0), // Çar: Normal
          FlSpot(3, 0), // Per: Normal
          FlSpot(4, 2), // Cum: High
          FlSpot(5, 1), // Cmt: Moderate
          FlSpot(6, 0), // Paz: Normal
        ];
        trendDates = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        break;
    }
    //--!!!

    return Scaffold(
      appBar: AppBar(
        title: const Icon(Icons.monitor_heart_outlined, color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            //above tab filter with 3 segment
            SegmentedButton <Timefilter>(
                showSelectedIcon: false, //remove selection icon
                segments:  <ButtonSegment<Timefilter>>[
                  ButtonSegment<Timefilter>(
                    value: Timefilter.all,
                    label: Text('All'),
                  ),
                  ButtonSegment<Timefilter>(
                    value: Timefilter.month,
                    label: Text('Last Month'),
                  ),
                  ButtonSegment<Timefilter>(
                    value: Timefilter.week,
                    label: Text('Last Week'),
                  )
                  
                ],
                selected: <Timefilter> {selectedfilter}, //which one is chosen now

                //what happen if change happen
                onSelectionChanged:(Set<Timefilter> newSelection) {
                  setState(() {//get the first and only element in the set
                    selectedfilter = newSelection.first;
                  });

                  getdata(); //if the tab changes then the data should chnged
                  
                },

                
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return const Color.fromARGB(255, 229, 142, 171);
                    }
                    return Colors.white; 
                  },
                  ),
                ),
              ),
              

              //total number of children
              if(selectedfilter == Timefilter.all)...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),

                  ),
                  
                  child:  isloading ? Center(child: CircularProgressIndicator(),)
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.people_alt_rounded, size: 22, color: Colors.blueAccent),
                      SizedBox(width: 5,),             
                      Text("Total Registered Children: ", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                                
                      Text("$totalchildren",style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),           
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),

              //risk distribution pie chart
              buildchartcontainer(
                title: "Risk Distribution",
                child:  isloading ? Center(child: CircularProgressIndicator(),)
                : RiskPieChart(greencount: greencount, yellowcount: yellowcount, redcount: redcount),
                containercolor: Colors.amber.withOpacity(0.1),
              ),

              const SizedBox(height: 10),
              buildchartcontainer(
                title: "Critical Cases Trend" ,
                child: TrendLineChart(spots: trendSpots, dates: trendDates,),
                containercolor: Colors.blue.withOpacity(0.1),
              ),

              const SizedBox(height: 10),
              //Stock levels 
              buildchartcontainer(
                title: "RUTF Stock Levels" ,
                child: StockPieChart(distributeditemsnum: usedstock, remainingitemsnum: remainingstock),
                containercolor: Colors.pink.withOpacity(0.1),
              ),
              


          ],
        ),
      ),

    );
  }

  Widget buildchartcontainer({required String title, required Widget child, required Color containercolor}) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: containercolor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),

      ),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

}

