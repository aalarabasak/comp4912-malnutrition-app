import 'package:flutter/material.dart';
import 'package:malnutrition_app/widgets/charts/risk_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';//helps format dates like Aug 31, 2025
import 'package:fl_chart/fl_chart.dart';
import 'package:malnutrition_app/utils/formatting_helpers.dart';
import 'package:malnutrition_app/widgets/charts/risk_statistic_card.dart';

class RiskStatusHistoryScreen extends StatefulWidget{
  final String childid;
  const RiskStatusHistoryScreen({super.key, required this.childid});

  @override
  State<RiskStatusHistoryScreen> createState() => RiskStatusHistoryScreenState();//tells Flutter which state class manages this widget
}

class RiskStatusHistoryScreenState extends State<RiskStatusHistoryScreen>{

  int selectedindex = -1;//stores which point on the chart is selected, -1> nothing selected yet by default

  @override
  Widget build (BuildContext context){
    return Scaffold(
      backgroundColor:const Color(0xFFF5F7FA) ,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('Risk Analysis', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 19)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              StreamBuilder <QuerySnapshot>(//listens to a stream of data from firestore
                stream: FirebaseFirestore.instance
                .collection('children')
                .doc(widget.childid)
                .collection('measurements')
                .snapshots(), 

                builder:(context, snapshot) {
                  
                  if(snapshot.hasError)return const Center(child: Text("Error loading data"));

                  if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator(),);
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No measurement records found."));
                  }

                  // data processing
                  var docs = snapshot.data!.docs;//list of measurement documents from firestore
                  List <Map<String, dynamic>> timelinedata = [];//new list where stored cleaned and processed data

                  for(var doc in docs){

                    var data = doc.data() as Map <String, dynamic>;

                    DateTime date = parseDateString(data['dateofMeasurement']);

                    String riskstatus = data['calculatedRiskStatus'];// text stored in firestore
                    int riskvalue = 0; //numeric value to draw in the chart 0,1,2 -default shoulf be 0
                    
                    if(riskstatus.contains("High Risk")) {
                      riskvalue = 2;
                    }
                    else if(riskstatus.contains("Moderate Risk")){
                      riskvalue = 1;
                    }
                    else{
                      riskvalue = 0; //means Healthy - No Risk
                    }

                    timelinedata.add({//put a clean map into timelinedata for each measurement
                      'date':date,
                      'riskvalue':riskvalue,
                      'riskstatus': riskstatus,
                      'reason': data['riskReason'],
                    });
                  }

                  timelinedata.sort((a,b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));//sort by Date Oldest to Newest

                  //create empty lists for charts
                  List<FlSpot> spots = [];//list of y points for the chart
                  List<String> dates = [];//list of xaxis labels formatted date strings

                  //fill x and y values to the empty lists for later use of charts
                  for(int i =0; i< timelinedata.length; i++){

                    var chartdata = timelinedata[i];//one map from timelinedata
                    //y axis values 0,1,2 -> riskvalues
                    double yaxisvalue = (chartdata['riskvalue'] as int).toDouble();
                    spots.add(FlSpot(i.toDouble(), yaxisvalue));

                    //x axis dates e.g Nov 26 format
                    String label =  DateFormat("MMM d").format(chartdata['date']);
                    dates.add(label);

                  }
                  // Only set default to last measurement if nothing is selected yet
                    if (selectedindex == -1) {
                      selectedindex = dates.length-1;
                    }
                  
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Chart with tap callback
                        RiskChart(dates: dates, spots: spots,
                          onPointTapped: (int index) {
                            setState(() {
                              selectedindex = index;
                            });
                            //saves which data point was tapped -triggers rebuild so new details appear
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        //information cards that appear when a point is selected
                        if(selectedindex >= 0 && selectedindex < timelinedata.length)//if selectedindex is valid
                          buildriskDetailCards(timelinedata[selectedindex])
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        )
      ),
    
      
    );
  }

  // Build detail cards showing risk date, status and reason
  Widget buildriskDetailCards(Map<String, dynamic> selectedData) {
    
    final String riskstatus = selectedData['riskstatus'];
    final String reason = selectedData['reason'];
    final DateTime date = selectedData['date'];

    //choose color  icon based on status
    Color statuscolor;
    IconData statusicon;
    if (riskstatus.contains('High Risk')) {
      statuscolor = Colors.red;
      statusicon = Icons.warning_amber_rounded;
    } 
    else if (riskstatus.contains('Moderate Risk')) {
      statuscolor = Colors.amber;
      statusicon = Icons.info_outline_rounded;
    } 
    else {
      statuscolor = Colors.green;
      statusicon = Icons.check_circle_outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: GridView.count(
        crossAxisCount: 1,//one column
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 3.5,//width/height ratio
        mainAxisSpacing: 18,//equal vertical space between the three cards
      children: [
        //date measurement card
        RiskStatisticCard(
          title: "Date of Measurement", 
          icon: Icons.date_range_outlined, 
          themecolor: Colors.indigo[300]!, 
          value: DateFormat("MMM d, yyyy").format(date),
        ),

        //risk status card
        RiskStatisticCard(
          title: "Risk Status", 
          icon: statusicon, 
          themecolor: statuscolor, 
          value: riskstatus
        ),

        RiskStatisticCard(
          title: "Risk Reason", 
          icon: Icons.description, 
          themecolor: Colors.blueGrey, 
          value: reason,
        )

      ],
      ),

    );
  }

}