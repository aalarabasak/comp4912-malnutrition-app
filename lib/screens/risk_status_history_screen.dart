import 'package:flutter/material.dart';
import 'package:malnutrition_app/widgets/charts/risk_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:malnutrition_app/utils/formatting_helpers.dart';

class RiskStatusHistoryScreen extends StatefulWidget{
  final String childid;
  const RiskStatusHistoryScreen({super.key, required this.childid});

  State<RiskStatusHistoryScreen> createState() => RiskStatusHistoryScreenState();
}

class RiskStatusHistoryScreenState extends State<RiskStatusHistoryScreen>{

  int selectedindex = -1;//state variable

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
              StreamBuilder <QuerySnapshot>(
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
                  var docs = snapshot.data!.docs;
                  List <Map<String, dynamic>> timelinedata = [];

                  for(var doc in docs){

                    var data = doc.data() as Map <String, dynamic>;

                    DateTime date = parseDateString(data['dateofMeasurement']);

                    String riskstatus = data['calculatedRiskStatus'];
                    int riskvalue = 0; //default shoulf be 0
                    
                    if(riskstatus.contains("High Risk")) {
                      riskvalue = 2;
                    }
                    else if(riskstatus.contains("Moderate Risk")){
                      riskvalue = 1;
                    }
                    else{
                      riskvalue = 0; //means Healthy - No Risk
                    }

                    timelinedata.add({
                      'date':date,
                      'riskvalue':riskvalue,
                      'riskstatus': riskstatus,
                      'reason': data['riskReason'],
                    });
                  }

                  timelinedata.sort((a,b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));//sort by Date Oldest to Newest

                  //create empty lists for charts
                  List<FlSpot> spots = [];
                  List<String> dates = [];

                  //fill x and y values to the empty lists for later use of charts
                  for(int i =0; i< timelinedata.length; i++){

                    var chartdata = timelinedata[i];
                    //y axis values 0,1,2 -> riskvalues
                    double yaxisvalue = (chartdata['riskvalue'] as int).toDouble();
                    spots.add(FlSpot(i.toDouble(), yaxisvalue));

                    //x axis dates e.g Nov 26 format
                    String label =  DateFormat("MMM d").format(chartdata['date']);
                    dates.add(label);

                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chart with tap callback
                        RiskChart(dates: dates, spots: spots,
                          onPointTapped: (int index) {
                            setState(() {
                              selectedindex = index;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Information cards that appear when a point is selected
                        if(selectedindex >= 0 && selectedindex < timelinedata.length)
                          _buildDetailCards(timelinedata[selectedindex])
                        else
                          _buildEmptyState(),
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

  // Build detail cards showing risk status and reason
  Widget _buildDetailCards(Map<String, dynamic> selectedData) {
    String riskStatus = selectedData['riskstatus'] as String;
    String reason = selectedData['reason'] as String;
    DateTime date = selectedData['date'] as DateTime;
    
    // Determine color based on risk status
    Color statusColor;
    IconData statusIcon;
    if (riskStatus.contains("High Risk")) {
      statusColor = Colors.red;
      statusIcon = Icons.warning_amber_rounded;
    } else if (riskStatus.contains("Moderate Risk")) {
      statusColor = Colors.amber;
      statusIcon = Icons.info_outline_rounded;
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Risk Status Card
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Status',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      riskStatus,
                      style: TextStyle(
                        fontSize: 16,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat("MMM d, yyyy").format(date),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Risk Reason Card
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description_outlined, 
                       color: Colors.grey[600], 
                       size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Risk Reason',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                reason,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Empty state when no point is selected
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.touch_app_outlined, 
               color: Colors.grey[400], 
               size: 48),
          const SizedBox(height: 12),
          Text(
            'Tap on a data point to view details',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}