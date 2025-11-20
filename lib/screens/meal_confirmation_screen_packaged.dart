
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
      ),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(
          child: Column(
            children: [
              Text('Meal Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),

              const SizedBox(height: 50,),

              Text('Product name: ${productdata!['name']}', style: TextStyle(fontSize: 18),),
            ],
          )
        ),
        )
        ),
    );













    
  }
}