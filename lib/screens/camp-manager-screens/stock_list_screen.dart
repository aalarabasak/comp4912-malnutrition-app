import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void dispose(){
    searchcontroller.dispose();
    super.dispose();
  }
  //helper function to specify status column in list
  String getstockstatus(int quantity){
    
    if(quantity <50) return "Low";
    if (quantity < 200) return "Medium";
    return "Normal";
  } 

  //helper function to get status color
  Color getstatuscolor(String status){
    switch(status){
      case "Low": return Colors.red.shade800;
      case "Medium": return Colors.orange.shade800;
      case "Normal": return Colors.green.shade800;
      default: return Colors.black;
    }
  }

  void sortStocks(List <QueryDocumentSnapshot> stocks){

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
            stream: FirebaseFirestore.instance.collection('stocks').where('quantity', isGreaterThan: 0).snapshots(),
            builder:(context, snapshot) {
              
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading data."));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var docs = snapshot.data!.docs;//data ready

              ///getting ready for summary card----
              int totalitems = docs.length; //total items count for summary card

              int lowstockcount = docs.where((doc) {
                int amount = doc.data()['quantity'];
                return getstockstatus(amount) == "Low";
              }).length; //count the low ones for summary card
              //----

              //search logic
              final filteredstocks = docs.where((doc) {

                final data = doc.data();
                final productname = data['productName'].toString().toLowerCase();
                final lotnumber = (data['lotNumber'] ?? "").toString().toLowerCase();

                return productname.contains(searchquery) || lotnumber.contains(searchquery);
              }).toList();

              sortStocks(filteredstocks);//call ordering function

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13.0),
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

                          //how many items is in a low condition
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
                    child: filteredstocks.isEmpty 
                    ? const Center(child: Text("No product found."))
                    : ListView.separated(
                          
                          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                          itemCount: filteredstocks.length,
                          itemBuilder:(context, index) {
                            
                            var data = filteredstocks[index].data(); //get data

                            //get necessary data
                            int quantity = data['quantity'];
                            String status = getstockstatus(quantity);
                            Color statuscolor = getstatuscolor(status);

                            //to get lot number need to look at category
                            String category = data['category'];
                            String lot = "";
                            if(category != "Supplement"){
                              lot = data['lotNumber'];
                            }

                            return ListTile(
                              contentPadding: EdgeInsets.zero,//This ensures that the row's content aligns perfectly with the headings above.

                              title: Row(
                                children: [
                                  //product name
                                  Expanded(flex: 3,child: Text(data["productName"], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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