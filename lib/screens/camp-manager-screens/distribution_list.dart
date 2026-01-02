import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:intl/intl.dart';

class DistributionList extends StatefulWidget{

  const DistributionList({super.key});

  @override
  State<DistributionList> createState() => DistributionListState();
}

class DistributionListState extends State<DistributionList>{

  final searchcontroller = TextEditingController();//read the text in the search field
  String searchquery = "";//store the current search query 

  @override
  void dispose(){
    searchcontroller.dispose();
    super.dispose();

  }

  String formatdate(Timestamp timestamp){//timestamp to string using intl package
    DateTime date = timestamp.toDate();

    return DateFormat('dd/MM/yyyy').format(date); 
  }


  @override
  Widget build(BuildContext context){
    

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
     
          const Text('Distribution History', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),

          const SizedBox(height: 20),

         
          TextFormField(
            controller: searchcontroller,
            decoration: InputDecoration(
              labelText: 'Search by Child Name',
              labelStyle: TextStyle(fontSize: 14),
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
          ),
                      
            onChanged: (value) { //runs when search query changed.
              setState(() {
                searchquery = value.toLowerCase();//store the query in lowercase 
              });
            },

         ),

         const SizedBox(height: 20),

         const Row(//name of the columns
          children: [

            Expanded( flex: 2,child: Text('Child', style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
         ),

         const Divider(thickness: 1, color: Colors.black87,), 

        //child list datas
         Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('distributions').orderBy('distributedAt', descending: true).snapshots(),
            builder:(context, snapshot) {
              
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading data."));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var docs = snapshot.data!.docs;

              final filteredlist = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final childName = data['childName'].toString().toLowerCase();
                return childName.contains(searchquery);
              }).toList();

              if (filteredlist.isEmpty) {
                return const Center(child: Text("No records found."));
              }

              return ListView.separated(
                
                separatorBuilder:  (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                itemCount: filteredlist.length,
                itemBuilder: (context, index) {
                  
                  var data = filteredlist[index].data() as Map<String, dynamic>;

                  String date = formatdate(data['distributedAt']);

                  return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
            
                      Expanded(flex: 2,child: Text(data["childName"], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),

             
                      Expanded(flex: 3,child: Text(data["itemName"], style: const TextStyle(fontSize: 14))),

              
                      Expanded(flex: 2,child: Text(data["quantity"].toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)) ),

                      //date of issue
                      Expanded(flex: 2,child: Text(date, style: const TextStyle(fontSize: 13, color: Colors.grey))),
                    ],
                  ),
                );
                },
              );
            },
          )
        ),

        ],
      ),
    );
  }
}