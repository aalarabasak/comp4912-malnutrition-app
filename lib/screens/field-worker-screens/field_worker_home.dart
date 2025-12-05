//field worker home screnn = Child List screen
import 'package:flutter/material.dart';
import 'add_child_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login-related-screens/welcome_screen.dart';
import 'child_profile_screen.dart';
import '../../utils/formatting_helpers.dart';

class FieldWorkerHome extends StatefulWidget{
  const FieldWorkerHome({super.key});

  @override
  State<FieldWorkerHome> createState() => _FieldWorkerHomeState();

}

class _FieldWorkerHomeState extends State<FieldWorkerHome>{

  final searchcontroller = TextEditingController(); //A controller to read and manage the text in the search textfield

  String searchquery ="";//A  variable to store the current search query entered by the user.

  @override
  void dispose(){
    searchcontroller.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(
      title: Icon(Icons.monitor_heart_outlined, color: Colors.black),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false, //avoid the presence of back button
      actions: [
        Padding(padding: const EdgeInsets.only(right: 30.0),
         child:ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 203, 202, 202),
            foregroundColor: Colors.black87,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          onPressed: () async{ //it means it is a method needs waiting -> async
            
            await FirebaseAuth.instance.signOut(); //log out using firebase auth

            if(context.mounted){
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const WelcomeScreen()),
               (route) => false); //Erases ALL history 
            }
          
          },   
          icon: Icon(Icons.logout, size: 14,),
          label: const Text('Log Out'),               
          
       ), 
       ),
      ],
    ),
    
    body: SafeArea(
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns all children horizontally to the left side.
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, //put space btw child list title and add child button
            children: [
              //first row 
              ////1st element - child list title
              const Text('Child List', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),),

              ////2nd element - add child + button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddChildScreen()));
                },
                icon: const Icon(Icons.add, size: 18,),
                label: const Text('Add Child'),
               
              ) 

            ],
          ),
 
          const SizedBox(height: 20),//space between title row and search bar

          //search bar
          TextFormField(
            controller: searchcontroller,
            decoration: InputDecoration(
              labelText: 'Search Child by Name',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) { //tells Flutter to rebuild the screen because our search query changed.
              setState(() {
                searchquery = value.toLowerCase();// Store the query in lowercase for easier matching
              });
            },

          ),

          const SizedBox(height: 20),

          //list titles (or name of the columns)
          const Row(
            children: [ //expanded-> it takes up the remaininng horizontal space
            //flex-> shows how the space can be shared
              Expanded( flex: 3 ,child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold),)),
              Expanded( flex: 2 ,child: Text('Age', style: TextStyle(fontWeight: FontWeight.bold),)),
              Expanded( flex: 2 ,child: Text('Risk Status', style: TextStyle(fontWeight: FontWeight.bold),)),             
            ],
          ),

          const Divider(thickness: 1, color: Colors.black87,), //horizontal line that separates titles from datas

          //child list datas
          Expanded(//It takes up all the remaining vertical space.
             child: StreamBuilder <QuerySnapshot>(
              stream: FirebaseFirestore.instance
                .collection('children')
                .orderBy('createdAt', descending: true)
                .snapshots(), //provides live streaming, if new data comes to the firebase, immediately is shown in list screen.

              builder: (context, snapshot) {
                if(snapshot.hasError){
                  return Center(
                    child: Text('an error occured.'),
                  );
                }

                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                }

                final allchildren = snapshot.data!.docs; // Get all documents from the snapshot, firestore

                final List<DocumentSnapshot> filteredlist; //prepare a empty list for now

                if(searchquery.isEmpty){
                  filteredlist = allchildren; //show the all children as a list
                } 
                else{
                  filteredlist = allchildren.where((doc){
                    Map<String, dynamic> childdata = doc.data() as Map<String, dynamic>;

                    String fullName = childdata['fullName'];//get fullname 

                    // Check if name  starts with the search query
                    bool name_matches = fullName.toLowerCase().startsWith(searchquery); //case-sensitive logic

                    return name_matches;//Add to list if it is matched
                  }).toList(); //convert  filtered results as a list
                }



                return ListView.builder( //if the data comes successfullt, then execute below lines

                  //Tells the list to create rows based on the number of  documents of the filtered list
                  itemCount: filteredlist.length,

                  //it shows how the each row of the list will be drawn
                  itemBuilder: (context, index) {

                    
                    var childdoc= filteredlist[index];//get child from list
                    //this maps converts the data to usable format
                    Map<String, dynamic> childData = childdoc.data() as Map<String, dynamic>;

                    String name = childData['fullName'];

                    String temp = childData['dateofBirth'];
                    String age = calculateAge(temp);

                    String riskstatus = childData['currentRiskStatus'];//get current status from child's data firebase
                    String risk ="";
                    Color riskcolor;
                    if(riskstatus.contains('High Risk')){
                      risk = "High"; //status text
                      riskcolor = Colors.red.shade700;//status color
                    }
                    else if(riskstatus.contains('Moderate Risk')){
                      risk = "Moderate";
                      riskcolor = Colors.amber.shade700;
                    }
                    else{
                      risk = "Healthy";
                      riskcolor = Colors.green.shade600;
                    }


                    return ListTile(
                      //This ensures that the row's content aligns perfectly with the headings above.
                      contentPadding: EdgeInsets.zero, 
                      title: Row(
                        
                        children: [
                          Expanded( flex: 3,child:Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                          Expanded( flex: 2,child: Text(age, style: TextStyle(fontSize: 14),),),
                          Expanded( flex: 2,child:Text(risk, style: TextStyle(fontSize: 14, color: riskcolor, fontWeight: FontWeight.bold),) ),
                          
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=> ChildProfileScreen(childId: childdoc.id)));

                        debugPrint("Tıklanan çocuk: $name");
                      },
                    );
                 
                  },
                );




              },

                                     
              ),

                
          ),

          const SizedBox(height: 20),

        ],
      ),
      )
      
      )
       
    );

  }
}