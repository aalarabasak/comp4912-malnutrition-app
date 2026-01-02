//all children list connected to field worker home screen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_child_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'child_profile_screen.dart';
import '../../utils/formatting_helpers.dart';

class ScreeningAllChildrenList extends StatefulWidget{
  const ScreeningAllChildrenList({super.key});

  @override
  State<ScreeningAllChildrenList> createState() => _ScreeningAllChildrenListState();

}

class _ScreeningAllChildrenListState extends State<ScreeningAllChildrenList>{

  final searchcontroller = TextEditingController(); //read  text in the search field

  String searchquery ="";//store the current search query 

  @override
  void dispose(){
    searchcontroller.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context){

    final String currentuserid= FirebaseAuth.instance.currentUser!.uid;
    
    
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, //put space btw child list title and add child button
            children: [
             
              const Text('Child List', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),),

            
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 229, 142, 171).withOpacity(0.8),
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
 
          const SizedBox(height: 20),

          
          TextFormField(
            controller: searchcontroller,
            decoration: InputDecoration(
              labelText: 'Search Child by Name',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) { //rebuild the screen search query changed.
              setState(() {
                searchquery = value.toLowerCase();//store the query in lowercase 
              });
            },

          ),

          const SizedBox(height: 20),

          // name of the columns
          const Row(
            children: [ 
            //flex-> shows how the space can be shared
              Expanded( flex: 3 ,child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold),)),
              Expanded( flex: 2 ,child: Text('Age', style: TextStyle(fontWeight: FontWeight.bold),)),
              Expanded( flex: 2 ,child: Text('Risk Status', style: TextStyle(fontWeight: FontWeight.bold),)),             
            ],
          ),

          const Divider(thickness: 1, color: Colors.black87,), 

          //child list datas
          Expanded(
             child: StreamBuilder <QuerySnapshot>(
              stream: FirebaseFirestore.instance
                .collection('children')
                .where('registeredBy', isEqualTo: currentuserid)
                .orderBy('createdAt', descending: true)
                .snapshots(), //provides live streaming

              builder: (context, snapshot) {
                if(snapshot.hasError){
                  return Center(
                    child: Text('an error occured.'),
                  );
                }

                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                }

                final allchildren = snapshot.data!.docs; //get all documents from the snapshot

                final List<DocumentSnapshot> filteredlist; //prepare a empty list for now

                if(searchquery.isEmpty){
                  filteredlist = allchildren; //show the all children as a list
                } 
                else{
                  filteredlist = allchildren.where((doc){
                    Map<String, dynamic> childdata = doc.data() as Map<String, dynamic>;

                    String fullName = childdata['fullName'];//get fullname 

                    //check if name  starts with the search query
                    bool namematches = fullName.toLowerCase().startsWith(searchquery); //case-sensitive logic

                    return namematches;//add to list if it is matched
                  }).toList(); 
                }

                if (filteredlist.isEmpty){
                  return const Center(child: Text("No children found."));

                }
              


                return ListView.separated( 
                  separatorBuilder:(context, index) => Divider(height: 1, color: Colors.grey.shade200),
        
                  itemCount: filteredlist.length,

       
                  itemBuilder: (context, index) {

                    
                    var childdoc= filteredlist[index];//get child from list
                    //converts the data to usable format
                    Map<String, dynamic> childData = childdoc.data() as Map<String, dynamic>;

                    String name = childData['fullName'];

                    String temp = childData['dateofBirth'];
                    String age = calculateAge(temp);

                    String riskstatus = childData['currentRiskStatus'] ?? "";//get current status 
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
                    else if(riskstatus.contains('Healthy - No Risk')){
                      risk = "Healthy";
                      riskcolor = Colors.green.shade600;
                    }
                    else{
                      risk = "No data";
                      riskcolor = Colors.grey;
                    }


                    return ListTile(
            
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

                        debugPrint("selected child: $name");
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
      );
      
      
       
    

  }
}