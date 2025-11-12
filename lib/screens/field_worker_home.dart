//field worker home screnn = Child List screen
import 'package:flutter/material.dart';
import 'add_child_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';

class FieldWorkerHome extends StatefulWidget{
  const FieldWorkerHome({super.key});

  @override
  State<FieldWorkerHome> createState() => _FieldWorkerHomeState();

}

class _FieldWorkerHomeState extends State<FieldWorkerHome>{

  String calculateAge(String birthdatestring){

      final parts = birthdatestring.split('/');
      

      final int day = int.parse(parts[0]);
      final int month = int.parse(parts[1]);
      final int year = int.parse(parts[2]);

      final DateTime birthDate = DateTime(year, month, day);

      //I got this piece of code from the link below:
      //https://viveky259259.medium.com/age-calculator-in-flutter-97853dc8486f
      final DateTime currentDate = DateTime.now();
      int age = currentDate.year - birthDate.year;
      int month1 = currentDate.month;
      int month2 = birthDate.month;

      if (month2 > month1) {
        age--;
      } else if (month1 == month2) {
        int day1 = currentDate.day;
        int day2 = birthDate.day;
        if (day2 > day1) {
          age--;
        }
      }

      return "$age yrs";
    } 
  

  

  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(
      title: Icon(Icons.monitor_heart_outlined, color: Colors.black),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      actions: [
        //Padding(padding: const EdgeInsets.symmetric(horizontal: 40.0)),
        Padding(padding: const EdgeInsets.only(right: 40.0),
         child:ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 203, 202, 202),
            foregroundColor: Colors.black87,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          onPressed: () async{
            
            await FirebaseAuth.instance.signOut();

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
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 40.0),
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
            decoration: InputDecoration(
              labelText: 'Search Child by Name of ID',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          //list titles (or name of the columns)
          const Row(
            children: [
              Expanded( flex: 3 ,child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold),)),
              Expanded( flex: 2 ,child: Text('Age', style: TextStyle(fontWeight: FontWeight.bold),)),
              Expanded( flex: 2 ,child: Text('Risk Status', style: TextStyle(fontWeight: FontWeight.bold),)),             
            ],
          ),

          const Divider(thickness: 1, color: Colors.black87,),

          //child list datas
          Expanded(//It takes up all the remaining vertical space.
             child: StreamBuilder <QuerySnapshot>(
              stream: FirebaseFirestore.instance
                .collection('children')
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

                return ListView.builder(

                  itemCount: snapshot.data!.docs.length,

                  itemBuilder: (context, index) {
                    var childdoc= snapshot.data!.docs[index];
                    Map<String, dynamic> childData = childdoc.data() as Map<String, dynamic>;

                    String name = childData['fullName'];

                    String temp = childData['dateofBirth'];
                    String age = calculateAge(temp);

                    String risk = "-";//will be updated later!!!!!!!

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        
                        children: [
                          Expanded( flex: 3,child:Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                          Expanded( flex: 2,child: Text(age, style: TextStyle(fontSize: 14),),),
                          Expanded( flex: 2,child:Text(risk, style: TextStyle(fontSize: 14),) ),
                          
                        ],
                      ),
                      onTap: () {
                        //will be added later
                        print("Tıklanan çocuk: $name");
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