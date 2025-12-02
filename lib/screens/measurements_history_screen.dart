import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malnutrition_app/utils/measurement_historydata_processor.dart';
import 'package:malnutrition_app/widgets/charts/muac_chart.dart';
import 'package:malnutrition_app/widgets/charts/measurement_statistic_card.dart';
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

                    //process preparation all measurement data using the service
                    final processedData = MeasurementDataProcessor.processMeasurements(docs);
                    
                    //get prepared data for access
                    final muacspots = processedData.muacSpots;
                    final weightspots = processedData.weightSpots;
                    final heightspots = processedData.heightSpots;
                    final datelabels = processedData.dateLabels;
                    
                    //get statistics for stat cards
                    final muacStats = processedData.muacStats;
                    final weightStats = processedData.weightStats;
                    final heightStats = processedData.heightStats;

                return SingleChildScrollView(//made it scrollable
                  child: Column(
                    children: [
                      //if muac is chosen then show the graph
                    if(selectedtype == MeasurementType.muac)...[
                      MuacChart(spots: muacspots, dates: datelabels),
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
                            MeasurementStatisticCard(
                              title: "Current Status", 
                              icon: Icons.monitor_heart_outlined, 
                              themecolor: Colors.blue, 
                              value: muacStats.current),

                            MeasurementStatisticCard(
                              title: "Average", 
                              icon: Icons.analytics_outlined, 
                              themecolor: Colors.orange, 
                              value: muacStats.average),

                            MeasurementStatisticCard(
                              title: "Lowest Record", 
                              icon: Icons.arrow_downward, 
                              themecolor: Colors.red, 
                              value: muacStats.min),

                            MeasurementStatisticCard(
                              title: "Highest Record", 
                              icon: Icons.arrow_upward, 
                              themecolor: Colors.green, 
                              value: muacStats.max),
                            
                          ],
                        ),
                      )
                      

                    ]
                    else if(selectedtype == MeasurementType.weight)...[
                      WeightChart(spots: weightspots, dates: datelabels),
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
                            MeasurementStatisticCard(
                              title: "Current Weight", 
                              icon: Icons.monitor_heart_outlined, 
                              themecolor: Colors.blue, 
                              value: weightStats.current),

                            MeasurementStatisticCard(
                              title: "Total Change", //to show difference btw the last and the first record
                              icon: Icons.trending_up, 
                              themecolor: Colors.green, 
                              value: weightStats.change),
                            
                            MeasurementStatisticCard(
                              title: "Lowest Record", 
                              icon: Icons.arrow_downward, 
                              themecolor: Colors.red, 
                              value: weightStats.min),

                            MeasurementStatisticCard(
                              title: "Highest Record", 
                              icon: Icons.arrow_upward, 
                              themecolor: Colors.blue, 
                              value: weightStats.max),
                          ],
                          ),
                      )
                    ]
                    else if(selectedtype == MeasurementType.height)...[
                      HeightChart(spots: heightspots, dates: datelabels),
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
                            MeasurementStatisticCard(
                              title: "Current Height", 
                              icon: Icons.height, 
                              themecolor: Colors.blue, 
                              value: heightStats.current),

                            MeasurementStatisticCard(
                              title: "Total Growth", 
                              icon: Icons.trending_up, 
                              themecolor: Colors.orange, 
                              value: heightStats.totalGrowth),

                            MeasurementStatisticCard(
                              title: "Avg. Growth Rate", 
                              icon: Icons.speed, 
                              themecolor: Colors.purple, 
                              value: heightStats.avgGrowthRate),

                            MeasurementStatisticCard(
                              title: "Highest Record", 
                              icon: Icons.arrow_upward, 
                              themecolor: Colors.green, 
                              value: heightStats.max),
                            
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
