
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

  //controlling barcode id and getting product data to the app from firebase
  Future <void> getProductData() async{
    
      //getdocument by barcode id 
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
      if(newCount >= 1.0){
        portioncount = newCount;
        portionerror = null;
      }
      else if(newCount < 1.0){
        portionerror = 'Portion must be at least 1.0';
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

    //create a map of meal data to record
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
      //add a new document to the child's  subcollection as mealintakes
      await FirebaseFirestore.instance
        .collection('children')
        .doc(widget.childid)
        .collection('mealIntakes')
        .add(mealdata);
      
      //add new acitivity to user's subcollection
      await UserService().addactivity(childId: widget.childid, activitytype: "Meal", description: "${data['name']} added");

      if(!context.mounted)return;
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Meal added successfully.'),
        backgroundColor: Colors.green,));

      Navigator.of(context).pop(); 
      
                                 
    }catch(error){
      debugPrint("Firebase Registration Error: $error");

      if(!context.mounted)return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save data.'),
          backgroundColor: Colors.red,));
      
    }


  }


  @override
  Widget build(BuildContext context) {
 
    if(isloading){
      return Scaffold(
        body: Center(child: CircularProgressIndicator(),),
      );
    }


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
                  buildinformationrow("Brand", '${productdata!['brand']}'),
                ],
              ),
            ),

            const SizedBox(height: 35,),

     
            Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 234, 184, 110).withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text('Nutritional Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 5,),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Energy: ${productdata!['kcal']} kcal'),
                      Text('Protein: ${productdata!['proteinG']} g'),
                    ],
                  ),
        
                  const SizedBox(height: 5),
                  Row( 
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

            
            Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 209, 185, 177).withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  const Text('Portion Size ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10),

                  //portion size increse(+), decrease(-) arangement buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                    
                      IconButton(
                        onPressed:() => updateportion(-1.0), 
                        icon: Icon(Icons.remove_circle_outline, size: 40, color: Colors.grey,)),


                
                      Text('${portioncount.toStringAsFixed(1)} packets', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),


                
                      IconButton(onPressed:() => updateportion(1.0), 
                      icon: Icon(Icons.add_circle, size: 40, color: Colors.green.shade400,)),
                    ],
                  ),

            
                  if(portionerror != null)
                    Center(
                      child: Text(portionerror!, style: TextStyle(color: Colors.red),),
                    ),
                    
                   ],
              ),
            ),


                  const SizedBox(height: 50),

       
                  Row(
                    children: [
              
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