import 'package:flutter/material.dart';

class DistributionList extends StatefulWidget{

  const DistributionList({super.key});

  @override
  State<DistributionList> createState() => DistributionListState();
}

class DistributionListState extends State<DistributionList>{

  final searchcontroller = TextEditingController();//a controller to read and manage the text in the search textfield
  String searchquery = "";//variable to store the current search query entered by the user

  @override
  void dispose(){
    searchcontroller.dispose();
    super.dispose();

  }


  //dummy data, this will be removed later!!!!1
  final List<Map<String, String>> dummyDistributions = [
    {
      "childName": "Mehmet Ali",
      "product": "RUTF",
      "amount": "2 pkts",
      "date": "12 Dec",
    },
    {
      "childName": "Ayşe Yılmaz",
      "product": "Amoxicillin",
      "amount": "1 box",
      "date": "12 Dec",
    },
    {
      "childName": "Selin Kaya",
      "product": "RUTF",
      "amount": "1 pkt",
      "date": "11 Dec",
    },
  ];


  @override
  Widget build(BuildContext context){
    //search bar logic
    final filteredlist = dummyDistributions.where((item) {
      final name = item["childName"]!.toLowerCase();
      return name.contains(searchquery);
    }).toList(); 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //title
          const Text('Distribution History', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),

          const SizedBox(height: 20),

          //search bar
          TextFormField(
            controller: searchcontroller,
            decoration: InputDecoration(
              labelText: 'Search by Child Name',
              labelStyle: TextStyle(fontSize: 14),
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

         const Row(//list titles (or name of the columns)
          children: [//expanded-> it takes up the remaininng horizontal space
           //flex-> shows how the space can be shared
            Expanded( flex: 3,child: Text('Child', style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(flex: 2, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
         ),

         const Divider(thickness: 1, color: Colors.black87,), //horizontal line that separates titles from datas

         //child list datas
         Expanded(
          child: filteredlist.isEmpty ? const Center(child: Text("No records found."))
            : ListView.separated(
              
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
              itemCount: filteredlist.length,
              itemBuilder:(context, index) {
                
                var data = filteredlist[index];

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      //child name
                      Expanded(flex: 3,child: Text(data["childName"]!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),

                      //product name
                      Expanded(flex: 2,child: Text(data["product"]!, style: const TextStyle(fontSize: 14))),

                      //quantity given
                      Expanded(flex: 2,child: Text(data["amount"]!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)) ),

                      //date of issue
                      Expanded(flex: 2,child: Text(data["date"]!, style: const TextStyle(fontSize: 13, color: Colors.grey))),
                    ],
                  ),
                  onTap: () {
                    //for now, there is nothing happen when the child is pressed
                  },
                );
              },
            )
            
        )
        ],
      ),
    );
  }
}