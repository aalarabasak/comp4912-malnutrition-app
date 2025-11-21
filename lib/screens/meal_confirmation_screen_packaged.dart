
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealConfirmationScreenPackaged extends StatefulWidget {

  final String barcodeId; //takes barcode id as a parameter  
  const MealConfirmationScreenPackaged({super.key, required this.barcodeId});

  @override
  State<MealConfirmationScreenPackaged> createState() => _MealConfirmationPackagedState();
}

class _MealConfirmationPackagedState  extends State<MealConfirmationScreenPackaged>{

  bool isloading =true;
  Map <String, dynamic>? productdata;
  String? error_message;
  double portion_count = 1.0;
  String? portion_error;

  @override
  void initState(){
    super.initState();
    getProductData();
  }

  //this method is for controlling barcode id and getting product data to the app from firebase
  Future <void> getProductData() async{
    
      //fetch document by barcode id from RUTF_products collection from firebase
      final snapshot = await FirebaseFirestore.instance.collection('RUTF_products').doc(widget.barcodeId).get();

      if(snapshot.exists){
        setState(() {
          productdata= snapshot.data(); //load data to empty product data map
          isloading = false;
        });
      }
      else{
        setState(() {
          error_message = "Product not found.";
          isloading = false;
        });
      }
  }

  void update_portion(double change){
    setState(() {
      final newCount = portion_count + change;
      if(newCount >= 0.1){
        portion_count = newCount;
        portion_error = null;
      }
      else if(newCount < 0.1){
        portion_error = 'Portion must be at least 0.5';
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    //if it is still in loading phase
    if(isloading){
      return Scaffold(
        body: Center(child: CircularProgressIndicator(),),
      );
    }

    //if there is a error
    if(error_message != null){
      return Scaffold(
        appBar: AppBar(title: Text('Error!'),),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(error_message!, style: TextStyle(color: Colors.red),),
          ),
        ),
      );
    }

    //if this is  successfull
    return Scaffold(
      appBar: AppBar(
        title: Icon(Icons.monitor_heart_outlined, color: Colors.black,),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, //avoid the presence of back button
      ),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Meal Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),

            const SizedBox(height: 45,),

            //Product Details card
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 140, 193, 142),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 5,),
                  build_information_row("Name", '${productdata!['name']}'),
                  build_information_row("Lot No", '${productdata!['lotNo']}'),
                  build_information_row("Expiry Date", '${productdata!['expiryDate']}'),
                ],
              ),
            ),

            const SizedBox(height: 35,),

            //nutritional information card
            Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 234, 184, 110),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //title of the card
                  Text('Nutritional Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 5,),
                  
                  Row(//1st row of nutritional contents
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Energy: ${productdata!['kcal']} kcal'),
                      Text('Protein: ${productdata!['proteinG']} g'),
                    ],
                  ),
        
                  const SizedBox(height: 5),
                  Row( //2nd row of nutritional content
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Carbs: ${productdata!['carbsG']} g'),
                      Text('Fat: ${productdata!['fatG']} g'),
                    ],

                  ),

                ],
              ),
            ),

            const SizedBox(height: 35,),

            //portion size titler
            Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 209, 185, 177),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //title of the selection
                  const Text('Portion Size ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10),

                  //portion size increse(+), decrease(-) arangement buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      //- portion size button
                      IconButton(
                        onPressed:() => update_portion(-0.5), 
                        icon: Icon(Icons.remove_circle, size: 40, color: Colors.red,)),


                      //number of packets that is selected by the user
                      Text('${portion_count.toStringAsFixed(1)} packets', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),


                      //+ portion size button
                      IconButton(onPressed:() => update_portion(0.5), 
                      icon: Icon(Icons.add_circle, size: 40, color: Colors.green,)),
                    ],
                  ),

                  //error message
                  if(portion_error != null)
                    Center(
                      child: Text(portion_error!, style: TextStyle(color: Colors.red),),
                    ),
                    
                   ],
              ),
            ),


                  const SizedBox(height: 50),

                  //buttons Cancel - Save Meal
                  Row(
                    children: [
                      //cancel button
                      Expanded(child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 176, 174, 174),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 25),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed:() {
                          Navigator.of(context).pop();//closes the current screen and returns  to the previous screen.
                        }, 
                        child: const Text('Cancel'))),

                        const SizedBox(width: 20),

                        //SAVE meal button
                        Expanded(child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          onPressed:() {
                            //will be updated!!!!!
                          }, 
                          child: Text('Save Meal') )),
                    ],
                  ),
          ],
        ),
        )
        ),
    );













    
  }
}