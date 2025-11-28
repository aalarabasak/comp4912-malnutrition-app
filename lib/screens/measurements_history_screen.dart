import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';//Only required for printing to the screen(formatting)
import 'package:malnutrition_app/utils/formatting_helpers.dart';
import 'package:malnutrition_app/widgets/charts/muac_chart.dart';
import 'package:malnutrition_app/widgets/charts/statistic_card.dart';
import 'package:malnutrition_app/widgets/charts/weight_chart.dart';
import 'package:malnutrition_app/widgets/charts/height_chart.dart';

enum MeasurementType {muac, weight, height }//a simple enum to manage measurement types

class MeasurementsHistoryScreen extends StatefulWidget{
  final String childid;
  const MeasurementsHistoryScreen({super.key, required this.childid});

  @override
  State <MeasurementsHistoryScreen> createState() => MeasurementsHistoryScreenState();
}

class MeasurementsHistoryScreenState extends State <MeasurementsHistoryScreen>{
  
  MeasurementType selectedtype = MeasurementType.muac;//initial selection is muac

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('History & Analysis', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 19),),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              //I got the segmentenbutton code from below link (segments, selected, onselectionchanged):
              //https://api.flutter.dev/flutter/material/SegmentedButton-class.html
              SegmentedButton <MeasurementType>(
                showSelectedIcon: false, //remove selection icon
                segments:  <ButtonSegment<MeasurementType>>[
                  ButtonSegment<MeasurementType>(
                    value: MeasurementType.muac,
                    label: Text('MUAC'),
                  ),
                  ButtonSegment<MeasurementType>(
                    value: MeasurementType.weight,
                    label: Text('Weight'),
                  ),
                  ButtonSegment<MeasurementType>(
                    value: MeasurementType.height,
                    label: Text('Height'),
                  )
                  
                ],
                selected: <MeasurementType> {selectedtype}, //which one is chosen now

                //what happen if change happen
                onSelectionChanged:(Set<MeasurementType> newSelection) {
                  setState(() {//get the first and only element in the set
                    selectedtype = newSelection.first;
                  });
                  
                },

                //I got the below code from below link for changing background of selection color
                //https://stackoverflow.com/questions/75271399/how-to-control-selected-and-unselected-background-color-for-the-segmentedbutton
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

              const SizedBox(height: 30),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                  .collection('children')
                  .doc(widget.childid)
                  .collection('measurements')
                  .snapshots() , 

                  builder:(context, snapshot) {
                    if(snapshot.hasError)return const Center(child: Text("Error loading data"));

                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator(),);
                    }

                    final docs = snapshot.data!.docs;//get the data from firebase

                    if(docs.isEmpty){
                      return const Center(child: Text("No measurements found."));
                    }

                    List<Map<String,dynamic>> processeddata = [];//Empty basket where put the processed data.

                    for(var doc in docs){

                      Map<String,dynamic> data = doc.data() as Map<String,dynamic>;//take raw data

                      DateTime measurementDate = parseDateString(data['dateofMeasurement']); //convert the date from string to datetime

                      data['parseddate'] = measurementDate;//Add new, smart date to data
                      processeddata.add(data);//add

                    }
                    //sort the date from old to new
                    processeddata.sort((a, b) => (a['parseddate']as DateTime).compareTo(b['parseddate'] as DateTime),);
                    //prepare the lists
                    List<FlSpot> muacspots= [];
                    List<String> datalabels=[];

                    for(int i = 0; i<processeddata.length; i++){

                      var data = processeddata[i];//get the data

                      //eg. Nov 26-  used intl package because I want to format the date not read it
                      String label = DateFormat("MMM d").format(data['parseddate']);                     
                      datalabels.add(label);

                      double val = double.tryParse(data['muac'].toString()) ?? 0;
                      muacspots.add(FlSpot(i.toDouble(), val));
                    }
 
                return SingleChildScrollView(//made it scrollable
                  child: Column(
                    children: [
                      //if muac is chosen then show the graph
                    if(selectedtype == MeasurementType.muac)...[
                      MuacChart(spots: muacspots, dates: datalabels),
                      const SizedBox(height: 25,),

                      //cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 20,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.1,
                          children: [
                            StatisticCard(
                              title: "Current Status", 
                              icon: Icons.monitor_heart_outlined, 
                              themecolor: Colors.blue, 
                              value: "128 mm"),

                            StatisticCard(
                              title: "Average", 
                              icon: Icons.analytics_outlined, 
                              themecolor: Colors.orange, 
                              value: "119 mm"),

                            StatisticCard(
                              title: "Lowest Record", 
                              icon: Icons.arrow_downward, 
                              themecolor: Colors.red, 
                              value: "112 mm"),

                            StatisticCard(
                              title: "Highest Record", 
                              icon: Icons.arrow_upward, 
                              themecolor: Colors.green, 
                              value: "130 mm"),
                            
                          ],
                        ),
                      )
                      

                    ]
                    else if(selectedtype == MeasurementType.weight)...[
                      WeightChart(),
                      const SizedBox(height: 25,),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing:10 ,
                          mainAxisSpacing:20 ,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.1,
                          children: [
                            StatisticCard(
                              title: "Current Weight", 
                              icon: Icons.monitor_heart_outlined, 
                              themecolor: Colors.blue, 
                              value: "12.5 kg"),

                            StatisticCard(
                              title: "Change (Last 30d)", 
                              icon: Icons.trending_up, 
                              themecolor: Colors.green, 
                              value: '+0.5 kg'),
                            
                            StatisticCard(
                              title: "Lowest Record", 
                              icon: Icons.arrow_downward, 
                              themecolor: Colors.red, 
                              value: "11.5 kg"),

                            StatisticCard(
                              title: "Highest Record", 
                              icon: Icons.arrow_upward, 
                              themecolor: Colors.blue, 
                              value: "12.5 kg"),
                          ],
                          ),
                      )
                    ]
                    else if(selectedtype == MeasurementType.height)...[
                      HeightChart(),
                      const SizedBox(height: 25,),

                       Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 20,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.1,
                          children: [
                            StatisticCard(
                              title: "Current Height", 
                              icon: Icons.height, 
                              themecolor: Colors.blue, 
                              value: "92.0 cm"),

                            StatisticCard(
                              title: "Total Growth", 
                              icon: Icons.trending_up, 
                              themecolor: Colors.orange, 
                              value: "+4.0 cm"),

                            StatisticCard(
                              title: "Starting Height", 
                              icon: Icons.start, 
                              themecolor: Colors.purple, 
                              value: "88.0 cm"),

                            StatisticCard(
                              title: "Highest Record", 
                              icon: Icons.arrow_upward, 
                              themecolor: Colors.green, 
                              value: "92.0 cm"),
                            
                          ],
                        ),
                      )
                    ]
                    

                    
                    
                    ],
                  ),
                );
                },
              )
              )
            ],
          ),
          ),
      ),
    );
  }
}
