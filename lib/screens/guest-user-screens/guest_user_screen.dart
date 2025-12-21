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
  List<double> yvalues= []; //y axis of line chrt
  List<String> xlabels=[];//x axis of lien chrrt



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
    Map<String,dynamic> linedata= await service.gethighrisklinedata(period);

    setState(() {
      totalchildren = count;
      greencount =risks['green']!;
      redcount=risks['red']!;
      yellowcount=risks['yellow']!;
      remainingstock=stocks['remaining']!;
      usedstock =stocks['used']!;
      isloading = false; 

      yvalues=List<double>.from(linedata['spots']);
      xlabels=List<String>.from(linedata['labels']);

    });
  }

  @override
  Widget build(BuildContext context){

    //line chart data preparation needs to converted to flspot
    List<FlSpot> finalyvalues=[];
    for(int i=0; i<yvalues.length; i++){
      FlSpot value = FlSpot(i.toDouble(), yvalues[i]);
      finalyvalues.add(value);
    }

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
                title: "Critical Cases Trend (High Risk)" ,
                child: isloading ? Center(child: CircularProgressIndicator(),)
                :TrendLineChart(spots: finalyvalues, datelabels: xlabels),
                containercolor: Colors.blue.withOpacity(0.1),
              ),

              const SizedBox(height: 10),
              //Stock levels 
              buildchartcontainer(
                title: "RUTF Stock Levels" ,
                child: isloading ? Center(child: CircularProgressIndicator(),)
                :StockPieChart(distributeditemsnum: usedstock, remainingitemsnum: remainingstock),
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

