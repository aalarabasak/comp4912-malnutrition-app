import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../helper-widgets/info_display_widgets.dart';

class RecentActivitiesCard extends StatelessWidget{
  final String childid;
  const RecentActivitiesCard({super.key, required this.childid});

  @override
  Widget build(BuildContext context){

    final String? userid= FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userid)
      .collection('recentActivities').where('childId', isEqualTo: childid)
      .orderBy('timestamp', descending: true)
      .limit(3).snapshots(),

      builder:(context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildCards("Recent Activities", "Loading...");
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return buildCards("Recent Activities", "No recent activity.");
          
        }


        List<Map<String,String>> activitiesdata= snapshot.data!.docs.map((doc){
          var data= doc.data() as Map<String,dynamic>;
          String description =data['description'] ?? '';
          
          Timestamp? timestamp = data['timestamp'] as Timestamp?;
          String datestring ="";
          if (timestamp != null) {
            DateTime timestamptodate = timestamp.toDate();
            datestring = DateFormat('yyyy-MM-dd').format(timestamptodate);
          } 

          return{
            'date': datestring,
            'description':description
          };
        }).toList();

       

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withOpacity(0.2), 
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              //title
              const Text("Recent Activities", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),),

              const SizedBox(height: 8),

              for(var activity in activitiesdata)
                Padding(padding:const EdgeInsets.only(bottom: 4.0),
                child: Text("• ${activity['date']} - ${activity['description']}", style: TextStyle(
                  fontSize: 14,color: Colors.black87,fontWeight: FontWeight.w500,
                ),),
               )
            ],
          ),
        );
      },
    );
  }

}