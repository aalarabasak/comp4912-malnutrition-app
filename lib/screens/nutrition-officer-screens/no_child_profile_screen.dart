import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:malnutrition_app/screens/nutrition-officer-screens/create_treatment_plan.dart';

import 'package:malnutrition_app/widgets/cards/nutrition_summary_card.dart';
import 'package:malnutrition_app/widgets/cards/risk_status_card.dart';
import 'package:malnutrition_app/widgets/cards/treatment_plan_card.dart';
import '../../widgets/cards/latest_measurement_card.dart';

import 'package:malnutrition_app/widgets/ai_feedback_button.dart';
import 'package:malnutrition_app/widgets/ai_feedback_dialog.dart';

import 'package:malnutrition_app/services/api_service.dart';//it is for llm short advice
import 'package:malnutrition_app/services/nutrition_data_gathererllm.dart';

import '../../widgets/info_display_widgets.dart';
import '../../utils/formatting_helpers.dart';


class NOChildProfileScreen extends StatefulWidget{

  final String childId;

  const NOChildProfileScreen({super.key,required this.childId});

  @override
  State<NOChildProfileScreen> createState() => _NOChildProfileScreenState();


}
  
class _NOChildProfileScreenState extends State<NOChildProfileScreen> {

  final ApiService apiService = ApiService();
  final NutritionDataGathererllm datagatherer = NutritionDataGathererllm();

  Future<void> handleAiFeedback(BuildContext context) async{
    //show loading sign
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder:(ctx) => const Center(child: CircularProgressIndicator())
    );

    //first, take the datas gather them as packet
    final request = await datagatherer.prepareadviceRequest(widget.childId);

    String? advice;
    if(request != null){//if the gathering data as packet process is successful, then go to api service
      advice = await apiService.getAiAdvice(request);
    }

    if(context.mounted) Navigator.pop(context); //close the loading sign

    //show the advice , show the result
    if(advice != null && context.mounted){
      showDialog(
        context: context,
        builder: (context) {
          return AiFeedbackDialog(airesponse: advice!);
        },
      );
    }
    
  }


  @override
  Widget build(BuildContext context){
    double availableWidth = MediaQuery.of(context).size.width - 46;
    //take the screen width and remove the paddings (23+23=46) so that the horizontal scrollable cards fit perfectly
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Icon(Icons.monitor_heart_outlined, color: Colors.black,),
        centerTitle: true ,
        
      backgroundColor: Colors.transparent, 
       actions: [
        //View AI feedback button
        Padding(padding: const EdgeInsets.only(right: 30.0),
        child: AiFeedbackButton(//goes to ../widgets/ai_feedback_button.dart to draw button
          onPressed: () => handleAiFeedback(context), //this hadnleaifeedback function is above of this dart script
          )
        )
      ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(247, 241, 241, 241),
          boxShadow:[
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ]
        ),
        child: SafeArea(
          child: SizedBox( 
            width: double.infinity,
            height: 56,
                  //create treatment plan button
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 229, 142, 171).withOpacity(0.7),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),

                              onPressed:() {
                            
                               Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTreatmentPlan(childId: widget.childId,
 
                              
                              )));
                               
                              },

                              icon:  Icon(Icons.medical_information_outlined, size: 21, ),
                              label: Text('Create Treatment Plan', style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                              
                            ),
             )   ,        
        ),
      ),

      body: StreamBuilder<DocumentSnapshot> (
        stream: FirebaseFirestore.instance //this time, we get the specific child from firestore with childId that we get through home page
          .collection('children')
          .doc(widget.childId)
          .snapshots(),

        builder: (context, snapshot) {
          if(snapshot.hasError){
            return Center(child: Text('An error occured'),);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          Map <String, dynamic> childdata = snapshot.data!.data() as Map <String, dynamic>; 

          String name = childdata['fullName'];

          String temp = childdata['dateofBirth'];
          String age = calculateAge(temp);

          String caregiver = childdata['caregiverName'];
          String childidfromDB = childdata['childID'];
          String campblock = childdata['campBlock'];
          String gender = childdata['gender'];

          bool hasDisability = childdata['hasDisability'];
          String disabilityexplanation = '';

          if(hasDisability){
             disabilityexplanation = childdata['disabilityExplanation'];
          }

          // measurements StreamBuilder inside the child data StreamBuilder
          return StreamBuilder<QuerySnapshot>(
            //  Fetch once for both cards -latest measurement card and risk status card
            //also I need to pass the current latest weight to the nutrition summary card for daily need calc
            stream: FirebaseFirestore.instance
                .collection('children')
                .doc(widget.childId)
                .collection('measurements')
                .orderBy('recordedAt', descending: true)
                .limit(1)
                .snapshots(), // getting the last record

            builder: (context, measurementsSnapshot) {
              // error and loading checks for measurements
              if (measurementsSnapshot.hasError) {
                return Center(child: Text("Error loading measurements"));
              }
              if (measurementsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var docs = measurementsSnapshot.data?.docs ?? [];//get the data

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23.0),
                  child: ListView(
                    children: [ //lots of elements from top the down
                      //Header row : name of child + profile icon 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [ //there are two elements in this row
                          //name of the child
                          Expanded(child: Text(name, style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600 ),)),

                          //profile icon
                          Icon(Icons.person, size: 60, color: const Color.fromARGB(255, 110, 109, 109), ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      //child's personal information
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 155, 211, 237).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildinformationrow("Age", age ),
                            buildinformationrow("Gender", gender),
                            buildinformationrow("ID", childidfromDB),
                            buildinformationrow("Camp Block", campblock),
                            buildinformationrow("Caregiver", caregiver),
                            buildinformationrow("Has Disability", hasDisability ? "Yes" : "No"),

                            if(hasDisability)
                              buildinformationrow("Explanation " , disabilityexplanation),
                          
                          ],
                        ) ,
                      ),

                      if(docs.isEmpty)...[
                        buildCards("Risk Status: ", "No available data."), 
                        buildCards("Measurements", "No measurements yet."),
                        buildCards("Nutrition Summary","Add a measurement to see nutrition targets.",),

                      ]
                      else...[
                        const Divider(height: 20),
                      //horizontal scrollable area starts

                      SizedBox(
                        height: 420,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          //physics: PageScrollPhysics(),
                          children: [
                            //part 1 risk status card + latest measurement card alt alta
                            SizedBox(
                              width: availableWidth,
                              child: Column(
                                children: [
                                  //top card: risk
                                  //give the last data to card for showing the latest risk result
                                  RiskStatusCard(latestdoc: docs.first, childId: widget.childId),
                                
                                //give the last data to card for showing the latest measurement result
                                  LatestMeasurementCard(latestDoc: docs.first, childId: widget.childId),
                                
                                ],
                              ),
                            ),

                            const SizedBox(width: 15), //space btw two big columns

                            SizedBox(
                              width: availableWidth,
                              child: Column(
                                children: [
                                  //Nutrition summary info card
                                    NutritionSummaryCard(childID: widget.childId,dateofbirthString: temp,gender: gender,weightkg: docs.first['weight'],),
                                  
                                ],
                              ),
                            )

                          ],
                        ),
                      ),


                      //horizontal scrollable area ends hereeee
                      const Divider(),
                      ], //if-else line ends here

                     

                     
                      
                      //treatment plan info card
                     TreatmentPlanCard(childID: widget.childId),

                      const SizedBox(height: 20,),                    
                    ],
                  ),
                ),
              );
            },
          );

        },
        

        
        ),
    );


  }

}
