import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'update_stock_screen.dart';

class StockListScreen extends StatefulWidget{

  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => StockListScreenState();
}

class StockListScreenState extends State<StockListScreen>{

  final searchcontroller = TextEditingController();//read the text in  search field
  String searchquery = "";//store the current search query 
  late Stream<QuerySnapshot> stocksstream;

  @override
  void initState() {
    super.initState();
    stocksstream = FirebaseFirestore.instance.collection('stocks') .where('quantity', isGreaterThan: 0).snapshots();
  }

  @override
  void dispose(){
    searchcontroller.dispose();
    super.dispose();
  }
  //specify status column in list
  String getstockstatus(int quantity){
    
    if(quantity <50) return "Low";
    if (quantity < 200) return "Medium";
    return "Normal";
  } 

  //get status color
  Color getstatuscolor(String status){
    switch(status){
      case "Low": return Colors.red.shade800;
      case "Medium": return Colors.orange.shade800;
      case "Normal": return Colors.green.shade800;
      default: return Colors.black;
    }
  }

  void sortStocks(List <QueryDocumentSnapshot> stocks){//sort as lowest to highes stock

    stocks.sort((a,b) {

      var dataA = a.data() as Map<String, dynamic>;
      var dataB = b.data() as Map<String, dynamic>;

      int quantitya = dataA['quantity'];
      int quantityb = dataB['quantity'];

      String statusa =getstockstatus(quantitya);
      bool islowA = false;
      if(statusa == "Low"){
        islowA = true;
      }

      String statusb =getstockstatus(quantityb);
      bool islowB = false;
      if(statusb == "Low"){
        islowB = true;
      }

      //lower one always comes out on top
      if(islowA && !islowB){
        return -1;
      }
      //lower one always comes out on top
      if(!islowA && islowB){
        return 1;
      }

      return quantitya.compareTo(quantityb);
    });
  }

  @override
  Widget build(BuildContext context){


    return StreamBuilder(
            stream: stocksstream,
            builder:(context, snapshot) {
              
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading data."));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var docs = snapshot.data!.docs;//data ready

              ///getting ready for summary card---
              int totalitems = docs.length; 

              int lowstockcount = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>?;
                int amount = (data?['quantity'] ?? 0) as int;
                return getstockstatus(amount) == "Low";
              }).length; 
              //----

              //search logic
              final filteredstocks = docs.where((doc) {

                final data = doc.data() as Map<String, dynamic>?;
                if (data == null) return false;
                final productname = (data['productName'] ?? "").toString().toLowerCase();
                final lotnumber = (data['lotNumber'] ?? "").toString().toLowerCase();

                return productname.contains(searchquery) || lotnumber.contains(searchquery);
              }).toList();

              sortStocks(filteredstocks);//call ordering function

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 

                  children: [
                 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, //put space btw child list title and add child button
                      children: [
                        
                        const Text('Current Stocks', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),

                   
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
                    
             
                  Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueGrey.shade700),
                      ),
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          //total number of items
                          Row(
                            children: [
                              Text("Total Items: ", style: TextStyle(color: Colors.black87)),
                              Text("$totalitems", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),

                          
                          Row(
                            children: [
                              Text("Low Stock Items: ", style: TextStyle(color: Colors.red)),
                              Text("$lowstockcount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    
                    const SizedBox(height: 10),
               
                    TextFormField(
                      controller: searchcontroller,
                      decoration: InputDecoration(
                        labelText: 'Search by Lot No or Product Name',
                        labelStyle: TextStyle(fontSize: 13),
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                    ),
                                
                      onChanged: (value) { //runs when search query changed.
                        setState(() {
                          searchquery = value.toLowerCase();//store in lowercase 
                        });
                      },

                  ),

                  
                  const SizedBox(height: 17),

                  //name of the columns
                  const Row(
                      children: [
                        Expanded(flex: 3, child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('Lot No', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),

                  const Divider(thickness: 1, color: Colors.black87,), 

                  //stock list
                  Expanded(
                    child: filteredstocks.isEmpty 
                    ? const Center(child: Text("No product found."))
                    : ListView.separated(
                          
                          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                          itemCount: filteredstocks.length,
                          itemBuilder:(context, index) {
                            
                            var data = filteredstocks[index].data() as Map<String, dynamic>?;//get data
                            if (data == null) {
                              return const SizedBox.shrink(); //skip if data is null
                            }

   
                            int quantity = (data['quantity'] ?? 0) as int;
                            String status = getstockstatus(quantity);
                            Color statuscolor = getstatuscolor(status);

                            //for get lot number need to look at category
                            String category = (data['category'] ?? "").toString();
                            String lot = "";
                            if(category != "Supplement"){
                              lot = (data['lotNumber'] ?? "").toString();
                            }

                            return ListTile(
                              contentPadding: EdgeInsets.zero,

                              title: Row(
                                children: [
                                  //product name
                                  Expanded(flex: 3,child: Text((data["productName"] ?? "").toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,),
                                    ),
                                  
                                  //lot number
                                  Expanded(flex: 2,child: Text(lot, style: const TextStyle(fontSize: 12),overflow: TextOverflow.ellipsis,)),

                                  //quantity
                                  Expanded(flex: 2,child: Text("$quantity", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),

                                  //stock status
                                  Expanded(flex: 2,child: Text( status,style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: statuscolor,
                                  ),))

                                ],
                              ),
                            );

                            

                          },
                        ),
                      
                  )





                  ],
                ),
              );

              
            },
          );
    
  
  }
}