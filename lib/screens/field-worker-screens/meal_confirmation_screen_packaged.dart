
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/helper-widgets/info_display_widgets.dart';
import '../../services/user_service.dart';

class MealConfirmationScreenPackaged extends StatefulWidget {

  final String barcodeId; //takes barcode id as a parameter  
  final String childid;
  const MealConfirmationScreenPackaged({super.key, required this.barcodeId, required this.childid});

  @override
  State<MealConfirmationScreenPackaged> createState() => _MealConfirmationPackagedState();
}

class _MealConfirmationPackagedState  extends State<MealConfirmationScreenPackaged>{

  bool isloading =true;
  Map <String, dynamic>? productdata;
  String? errorMessage;
  double portioncount = 1.0;
  String? portionerror;

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
          errorMessage = "Product not found.";
          isloading = false;
        });
      }
  }

  void updateportion(double change){
    setState(() {
      final newCount = portioncount + change;
      if(newCount >= 0.1){
        portioncount = newCount;
        portionerror = null;
      }
      else if(newCount < 0.1){
        portionerror = 'Portion must be at least 0.5';
      }
    });
  }

  Future <void> registerMealtoChild()async{
    final data = productdata!;
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
      'barcodeId': widget.barcodeId,
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
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Meal Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),

            const SizedBox(height: 45,),

            //Product Details card
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 140, 193, 142).withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 5,),
                  buildinformationrow("Name", '${productdata!['name']}'),
                  buildinformationrow("Lot No", '${productdata!['lotNo']}'),
                  buildinformationrow("Expiry Date", '${productdata!['expiryDate']}'),
                ],
              ),
            ),

            const SizedBox(height: 35,),

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
                color: const Color.fromARGB(255, 209, 185, 177).withOpacity(0.5),
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
                        onPressed:() => updateportion(-0.5), 
                        icon: Icon(Icons.remove_circle, size: 40, color: Colors.red.shade400,)),


                      //number of packets that is selected by the user
                      Text('${portioncount.toStringAsFixed(1)} packets', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),


                      //+ portion size button
                      IconButton(onPressed:() => updateportion(0.5), 
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


                  const SizedBox(height: 50),

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
                            backgroundColor: const Color.fromARGB(255, 229, 142, 171).withOpacity(0.8),
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