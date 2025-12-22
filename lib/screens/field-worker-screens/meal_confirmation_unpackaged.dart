
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/helper-widgets/info_display_widgets.dart';
import 'dart:io';
import '../../services/user_service.dart';

class MealConfirmationUnpackaged extends StatefulWidget {

  final File image;
  final Map<String,dynamic> fooddata;
  final String childid;

  const MealConfirmationUnpackaged({
    super.key,  
    required this.image,
    required this.fooddata,//data comes from the backend
    required this.childid
    });

  @override
  State<MealConfirmationUnpackaged> createState() => _MealConfirmationUnpackagedState();
}

class _MealConfirmationUnpackagedState  extends State<MealConfirmationUnpackaged>{

  bool isloading =true;
  Map <String, dynamic>? nutritiondata;
  String? errorMessage;
  double portioncount = 1.0;
  String? portionerror;

  @override
  void initState(){
    super.initState();
    getProductData();
  }

  //this method is  and getting product data to the app from firebase
  Future <void> getProductData() async{

      try{
        String detectedfood = widget.fooddata['class']?.toString() ?? '';//the name comes from api

        String docid = detectedfood.toLowerCase();//firebase id's are generally lower case

        //get document by detected food name from unpackaged_foods collection from firebase
        final snapshot = await FirebaseFirestore.instance.collection('unpackaged_foods').doc(docid).get();

        if(snapshot.exists){
          setState(() {
            nutritiondata= snapshot.data(); //load data to empty product data map
            isloading = false;
          });
        }
        else{
          setState(() {
            errorMessage = "Product not found.";
            isloading = false;
          });
        }
      }catch(e){
        setState(() {
          errorMessage = "Connection error : $e";
          isloading=false;
        });
      }
  }

  void updateportion(double change){
    setState(() {
      final newCount = portioncount + change;
      if(newCount >= 0.5){
        portioncount = newCount;
        portionerror = null;
      }
      else{
        portionerror = 'Portion must be at least 1.0';
      }
    });
  }

  Future <void> registerMealtoChild()async{
    final data = nutritiondata!;
    final portion = portioncount;

    //calculation of nutritional values based on the portion
    final totalKcal = data['kcal'] * portion;
    final totalProtein = data['proteinG'] * portion;
    final totalCarbs = data['carbsG'] * portion;
    final totalFat = data['fatG'] * portion;

    //Create a map of meal data to record
    final mealdata = {
      'date': DateTime.now().toIso8601String(),
      'productName': data['name'], //it is directly taken 
      'portionSize': portion,
      'totalKcal': totalKcal,
      'totalProteinG': totalProtein,
      'totalCarbsG': totalCarbs,
      'totalFatG': totalFat,
    };

    //firebase registration
    try{
      //Add a new document to the child's  subcollection as mealintakes
      await FirebaseFirestore.instance
        .collection('children')// go to main collection children
        .doc(widget.childid)//find the related child
        .collection('mealIntakes')//create subcollection
        .add(mealdata);// fill the data

      //add new acitivity to user's subcollection
      await UserService().addactivity(childId: widget.childid, activitytype: "Meal", description: "${data['name']} added");



      if(!context.mounted)return;
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Meal added successfully.'),
        backgroundColor: Colors.green,));

      Navigator.of(context).pop(); //closes this confirmation screen and backs to child's profile page
      
                                 
    }catch(error){
      debugPrint("Firebase Registration Error: $error");

      if(!context.mounted)return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save data.'),
          backgroundColor: Colors.red,));
      
    }


  }


  @override
  Widget build(BuildContext context) {

    double confidence = widget.fooddata['confidence'] ?? 0.0;//confidence score that comes from api

    //if it is still in loading phase
    if(isloading){
      return Scaffold(
        body: Center(child: CircularProgressIndicator(),),
      );
    }

    //if there is a error
    if(errorMessage != null){
      return Scaffold(
        appBar: AppBar(title: Text('Error!'),),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(errorMessage!, style: TextStyle(color: Colors.red),),
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
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //title
            Text('Meal Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            const SizedBox(height: 15),
            //image
            ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.file(
                    widget.image,
                    height: 234,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
            const SizedBox(height: 15),
            

            //detected food's details card
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 140, 193, 142).withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildinformationrow("Detected Food", nutritiondata!['name']),
                  buildinformationrow("Confidence Score", confidence.toStringAsFixed(2)),
                ],
              ),
            ),

            const SizedBox(height: 15,),

            //nutritional information card
            Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 234, 184, 110).withOpacity(0.5),
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
                      Text('Energy: ${nutritiondata!['kcal']} kcal'),
                      Text('Protein: ${nutritiondata!['proteinG']} g'),
                    ],
                  ),
        
                  const SizedBox(height: 5),
                  Row( //2nd row of nutritional content
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Carbs: ${nutritiondata!['carbsG']} g'),
                      Text('Fat: ${nutritiondata!['fatG']} g'),
                    ],

                  ),

                ],
              ),
            ),

            const SizedBox(height: 15,),

            //portion size titler
            Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 209, 185, 177).withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //title of the selection
                  const Text('Quantity: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 5),

                  //portion size increse(+), decrease(-) arangement buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      //- portion size button
                      IconButton(
                        onPressed:() => updateportion(-1.0), 
                        icon: Icon(Icons.remove_circle, size: 40, color: Colors.red.shade400,)),


                      //number of packets that is selected by the user
                      Text('${portioncount.toStringAsFixed(1)} ', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),


                      //+ portion size button
                      IconButton(onPressed:() => updateportion(1.0), 
                      icon: Icon(Icons.add_circle, size: 40, color: Colors.green.shade400,)),
                    ],
                  ),

                  //error message
                  if(portionerror != null)
                    Center(
                      child: Text(portionerror!, style: TextStyle(color: Colors.red),),
                    ),
                    
                   ],
              ),
            ),


                  const SizedBox(height: 20),

                  //buttons Cancel - Save Meal
                  Row(
                    children: [
                      //cancel button
                      Expanded(child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 176, 174, 174).withOpacity(0.5),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                        ),
                        onPressed:() {
                          Navigator.of(context).pop();//closes the current screen and returns  to the previous screen.
                        }, 
                        child: const Text('Cancel'))),

                        const SizedBox(width: 20),

                        //SAVE meal button
                        Expanded(child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 229, 142, 171).withOpacity(0.7),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                          ),
                          onPressed:() => registerMealtoChild(), 
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