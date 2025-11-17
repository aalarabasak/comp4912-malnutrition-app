import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:malnutrition_app/screens/add_test_results_screen.dart';
import '../utils(helpers)/formatting_helpers.dart';

class ChildProfileScreen extends StatefulWidget{

  final String childId;

  const ChildProfileScreen({
    super.key,
    required this.childId
  });

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();


}
  
class _ChildProfileScreenState extends State<ChildProfileScreen> {

//this is for 1st information card of the child, it is a helper function
  Widget build_information_row(String label, String value){

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0), //Add vertical spacing between rows
      child: Row(
        children: [
          //e.g. "age: "
          Text('$label: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87 ),),

          //the value e.g. "3"
          Expanded( //Take remaining space, wrap if long
            child: Text(value, style: TextStyle(fontSize: 15, color: Colors.black87),))
        ],

      ),
      );
  }

//this is for risk status, measurements, nutrition summary, recent activities cards.
  Widget buildCards(String title, String text){

    return Container(
      width: double.infinity,//Cover the entire screen
      margin: EdgeInsets.only(top: 15.0), //put space btw cards
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(10.0),
        color: const Color.fromARGB(255, 178, 190, 194)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //title like risk status
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

          const SizedBox(height: 10),

          //contents
          Text(text, style: TextStyle(fontSize: 15, color: Colors.black54),)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Icon(Icons.monitor_heart_outlined, color: Colors.black,),
        centerTitle: true ,
        
      backgroundColor: Colors.transparent, 
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
          String childid_fromDB = childdata['childID'];
          String camp_block = childdata['campBlock'];
          String gender = childdata['gender'];

          bool hasDisability = childdata['hasDisability'];
          String disability_explanation = '';

          if(hasDisability){
             disability_explanation = childdata['disabilityExplanation'];
          }

          return SafeArea(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ListView(

              children: [ //lots of elements from top the down
                //Header row , Name of the child + icon 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [ //there are two elements in this row
                    //name of the child
                    Expanded(child: Text(name, style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600 ),)),

                    //ICON
                    Icon(Icons.person, size: 60, color: const Color.fromARGB(255, 110, 109, 109), ),
                  ],
                ),//End of header row

                const SizedBox(height: 5),

                //child's personal information
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 155, 211, 237),
                    borderRadius: BorderRadius.circular(10.0),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      build_information_row("Age", age ),
                      build_information_row("Gender", gender),
                      build_information_row("ID", childid_fromDB),
                      build_information_row("Camp Block", camp_block),
                      build_information_row("Caregiver", caregiver),
                      build_information_row("Has Disability", hasDisability ? "Yes" : "No"),

                      if(hasDisability)
                        build_information_row("Explanation " , disability_explanation),
                    
                    ],
                  ) ,
                ),

                //Risk status info card
                buildCards(
                  "Risk Status", 
                  "-",),
                
                //measurements info card
                buildCards(
                  "Measurements", 
                  "-"),

                //Nutrition summary info card
                buildCards(
                  "Nutrition Summary", 
                  "-"),

                //recent activities info card
                buildCards(
                  "Recent Activities", 
                  "-"),

                const SizedBox(height: 10,),

                Row(
                  children: [
                    //add test results button
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          textStyle: TextStyle(fontWeight: FontWeight.bold)),

                        onPressed:() {
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  AddTestResultsScreen(childid: widget.childId)));
                        },

                        icon:  Icon(Icons.text_snippet),
                        label: Text('Add Test Results'),
                        
                      )
                    ),

                    const SizedBox(width: 15), // Space between buttons

                  //add meal button
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          //will be updated!!!!!!!
                        },
                        label: Text('Add Meal'),
                        icon: Icon(Icons.medication_liquid_rounded),
                      ),
                    ),
                  ],                  
                ),
                
                const SizedBox(height: 10,),

                //View AI feedback button
                Center(
                child:ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed:() {
                    //will be updated !!!!!!!
                  },
                  label: Text('View AI Feedback'),
                  icon: Icon(Icons.search_sharp),
                )
              ),

             

             ],
            
            ),
            
            
            
            ),
            );

        },
        

        
        ),
    );


  }

}
