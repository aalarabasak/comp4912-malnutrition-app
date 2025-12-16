import 'package:flutter/material.dart';
import 'update_stock_screen.dart';

class StockListScreen extends StatefulWidget{

  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => StockListScreenState();
}

class StockListScreenState extends State<StockListScreen>{

  final searchcontroller = TextEditingController();//a controller to read and manage the text in the search textfield
  String searchquery = "";//variable to store the current search query entered by the user

  //dummy data, will be changed later!!!!!
  // Dummy data
  final List<Map<String, dynamic>> dummyStocks = [
    {
      "productName": "RUTF (Peanut Paste)",
      "lotNumber": "PN-2309",
      "quantity": 500,
      "expiryDate": "2026-03-12",
      "status": "Good"
    },
    {
      "productName": "Amoxicillin",
      "lotNumber": "AM-1102",
      "quantity": 45, 
      "expiryDate": "2025-08-20",
      "status": "Low"
    },
    {
      "productName": "Vitamin A",
      "lotNumber": "VA-9901",
      "quantity": 200,
      "expiryDate": "2027-01-01",
      "status": "Good"
    },
    {
      "productName": "Paracetamol",
      "lotNumber": "PA-5500",
      "quantity": 1000,
      "expiryDate": "2026-11-01",
      "status": "Good"
    },
  ];

  @override
  Widget build(BuildContext context){
    //this is for search bar logic, looks at lot number or product name
    final filteredstocks = dummyStocks.where((item) {
      final product = item['productName'].toString().toLowerCase();
      final lot = item['lotNumber'].toString().toLowerCase();
      final query = searchquery.toLowerCase();

      return product.contains(query) || lot.contains(query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns all children horizontally to the left side.

        children: [
          //top part - title and button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, //put space btw child list title and add child button
            children: [
              //first row 
              ////1st element - title
              const Text('Current Stocks', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),

              ////2nd element - update stock + button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 229, 142, 171).withOpacity(0.8),
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdateStockScreen()));
                },
                icon: const Icon(Icons.edit_note, size: 18,),
                label: const Text('Update Stock'),
               
              ) 

            ],
          ),

          const SizedBox(height: 18),
          
          //stock status summary card is here
         Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueGrey.shade700),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //total number of items
                Row(
                  children: [
                    Text("Total Items: ", style: TextStyle(color: Colors.black87)),
                    Text("4", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),

                //how many items is in a low condition
                Row(
                  children: [
                    Text("Low Stock Items: ", style: TextStyle(color: Colors.red)),
                    Text("1", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ],
            ),
          ),

          
          const SizedBox(height: 10),
          //search bar
          TextFormField(
            controller: searchcontroller,
            decoration: InputDecoration(
              labelText: 'Search by Lot No or Product Name',
              labelStyle: TextStyle(fontSize: 13),
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
          ),
                      
            onChanged: (value) { //tells Flutter to rebuild the screen because our search query changed.
              setState(() {
                searchquery = value.toLowerCase();// Store the query in lowercase for easier matching
              });
            },

         ),

         
         const SizedBox(height: 17),

        //list titles (or name of the columns)
        const Row(
            children: [//expanded-> it takes up the remaininng horizontal space
            //flex-> shows how the space can be shared
              Expanded(flex: 3, child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Lot No', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),

        const Divider(thickness: 1, color: Colors.black87,), //horizontal line that separates titles from datas

        //stock list
        Expanded(
          child: filteredstocks.isEmpty ? const Center(child: Text("No product found."))
          : ListView.separated(
            
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
            itemCount: filteredstocks.length,
            itemBuilder: (context, index) {
              var data = filteredstocks[index];
              bool islow =false;
              if(data['status'] == "Low"){
                islow = true;
              }

              return ListTile(
                contentPadding: EdgeInsets.zero,//This ensures that the row's content aligns perfectly with the headings above.

                title: Row(
                  children: [
                    //product name
                    Expanded(flex: 3,child: Text(data["productName"], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,),
                      ),
                    
                    //lot number
                    Expanded(flex: 2,child: Text(data["lotNumber"], style: const TextStyle(fontSize: 14))),

                    //quantity
                    Expanded(flex: 2,child: Text("${data["quantity"]}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),

                    //stock status
                    Expanded(flex: 2,child: Text(data['status'], style: TextStyle(
                      fontSize: 12, 
                              fontWeight: FontWeight.bold,
                              color: islow ? Colors.red.shade800 : Colors.green.shade800
                    ),))

                  ],
                ),

              );
            },
          )
        ),

        ],
      ),
    );
  }
}