import 'package:flutter/material.dart';
import 'package:malnutrition_app/widgets/helper-widgets/info_display_widgets.dart';
import 'package:malnutrition_app/services/treatment_service.dart';

import 'package:malnutrition_app/services/nutrition_data_gathererllm.dart'; 
import 'package:malnutrition_app/services/nutrition_datamodels.dart'; 

class CreateTreatmentPlan extends StatefulWidget{

  final String childId;

  const CreateTreatmentPlan({super.key,  required this.childId});

  @override
  State<CreateTreatmentPlan> createState() => CreateTreatmentPlanState();
}

class CreateTreatmentPlanState extends State<CreateTreatmentPlan>{

  DateTime? selecteddate;
  int? selectedRUTFindex; 
  int quantityperday = 0; 
  int durationweeks = 0;
  final Set<String> selectedsupplements ={};//supplemantary food choices multiple choices
  int supplementquantity = 0; 
  int supplementduration =0;
  bool isloading = false;
  final TreatmentService treatmentservice = TreatmentService();
  String? riskstatus; //keep rsikstatus

  //for getting rutfproducts name and details from firestore and for getting supp names
  List<Map<String,dynamic>> rutfproducts = [];
  List<Map<String, dynamic>> supplements = [];
  bool isfoodloading = true;

  @override
  void initState() {
    super.initState();
    loadriskstatus();
    loadfooddata();
  }

  Future<void> loadriskstatus() async {
  try {
    //call the service method
    final status = await treatmentservice.getcurrentriskstatus(widget.childId);    
    if (mounted) {
      setState(() {
        riskstatus = status;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        riskstatus = null;
      });
    }
  }

}

Future <void> loadfooddata() async{
  try{
    NutritionDataGathererllm datagatherer = NutritionDataGathererllm();

    List<FoodItem> rutfitems = await datagatherer.getfoodcollection('RUTF_products');
    List<FoodItem> suppitems = await datagatherer.getfoodcollection('unpackaged_foods');

    if (!mounted) return;

    setState(() {
      rutfproducts = rutfitems.map((item) {
        return {
          "name": item.name,
            "kcal": item.values.calories, 
            "prot": item.values.protein,  
            "carb": item.values.carbs,   
            "fat": item.values.fat,       
        };
      }).toList();

      supplements= suppitems.map((item) {
        return{
          "name" : item.name,
          "icon": geticonforsupplement(item.name),
        };
      }).toList();

      isfoodloading= false;

    });
  }
  catch(e){
    if (mounted) {
       setState(() {
         isfoodloading = false;
       });
      }
  }
}

  
 
 String geticonforsupplement(String name){
  name = name.toLowerCase();
  if(name.contains('banana')) return "🍌";
  if (name.contains('apple')) return "🍎";
  if (name.contains('carrot')) return "🥕";
  if (name.contains('orange')) return "🍊";
  return "";
 }



  Color getriskcolor(){
    switch(riskstatus){//returns a color based on risk status
      case "High Risk" : return Colors.red.shade100;
      case "Moderate Risk" : return Colors.orange.shade100;
      case "Healthy - No Risk" : return Colors.green.shade100;
      default: return Colors.grey.shade200;
    }
  }

  Color getrisktextcolor() {
    switch (riskstatus) {//returns a darker text color for readability
      case "High Risk": return Colors.red.shade900;
      case "Moderate Risk": return Colors.orange.shade900;
      case "Healthy - No Risk": return Colors.green.shade900;
      default: return Colors.black87;
    }
  }

  String getdiagnosis(){//converts risk status to diagnosis code sam,mam, normal
    switch(riskstatus){
      case "High Risk" : return "SAM";
      case "Moderate Risk" : return "MAM";
      default: return "Normal";
    }
  }
  

  
  Future <void> pickdateinFuture(BuildContext context) async{
    final DateTime? picked = await showDatePicker(//shows the date picker and waits for the result
      context: context, 
      firstDate: DateTime.now(),  
      lastDate: DateTime.now().add(const Duration(days: 95)), //make the last choosanable date to 3 moths later
    );

    if(picked != null && picked != selecteddate){
      setState(() {
        selecteddate = picked;
      });
    }
  }

  //saving treatment plan to firebase
  Future<void> handlesave() async{
    if(selecteddate == null){//warn if date not selected
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Please select a next visit date!') , backgroundColor: Colors.red,));
      return;
     
    }

    if(selectedsupplements.isNotEmpty &&(supplementquantity == 0 || supplementduration == 0) ){
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Please enter fields for supplements!'), backgroundColor: Colors.red));
       return;
    }

    if(selectedRUTFindex != null && (quantityperday == 0 || durationweeks == 0)){
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter fields for RUTF!'), backgroundColor: Colors.red));
       return;
    }

    setState(() => isloading = true);

    try{
      Map<String, dynamic>? rutfdata;
      if(selectedRUTFindex != null){
        final product = rutfproducts[selectedRUTFindex!];

        rutfdata={
          'productName': product['name'],
          'dailyQuantity': quantityperday,
          'durationWeeks': durationweeks,
          'totalTarget': quantityperday*7*durationweeks,//total quantity

        };
      }

      Map<String, dynamic>? supplementdata;
      if(selectedsupplements.isNotEmpty){
       

        supplementdata={
          'selecteditems': selectedsupplements.toList(),
          'dailyQuantity': supplementquantity,
          'durationWeeks': supplementduration,

        };
      }

      await treatmentservice.savetreatmentplan(
        childid: widget.childId, 
        diagnosis: getdiagnosis(), 
        nextvisitdate: selecteddate!,
        prescribedRUTF: rutfdata, 
        supplements: supplementdata,
        );

        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan saved successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }




    }catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }finally {
      //in every situation stop the loading
      if (mounted) {
        setState(() => isloading = false);}
    }

    
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Icon(Icons.monitor_heart_outlined, color: Colors.black,),
        centerTitle: true ,
        automaticallyImplyLeading: false, //avoid the presence of back button
        backgroundColor: Colors.transparent, 
      ),

      body: isfoodloading ? Center(child: CircularProgressIndicator())
      :SingleChildScrollView(//makes the content scrollable
       padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              color: getriskcolor(),
              child: Column(
                children: [
                  Text("Diagnosis Status", style: TextStyle(color: getrisktextcolor(), fontSize: 12, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 5),
                  Text(getdiagnosis(), style: TextStyle(color: getrisktextcolor(), fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.5),)
                ],
              ),

            ),

            const SizedBox(height: 20),

        
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Next Visit Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  InkWell(//makes the container clickable 
                    onTap: () => pickdateinFuture(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.black54),
                          const SizedBox(width: 10),
                          Text(
                            selecteddate == null ? "Tap to select a date..." : "${selecteddate!.day}/${selecteddate!.month}/${selecteddate!.year}",
                            
                            style: TextStyle(color: selecteddate == null ? Colors.grey : Colors.black87,fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 40),

                  
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: const Text("Therapeutic Food (RUTF)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),

                  const SizedBox(height: 10),
                
                  SizedBox(
                    height: 160,

                    child: ListView.builder(//horizontal scrollable list 
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: rutfproducts.length,
                      itemBuilder:(context, index) {
                        final product = rutfproducts[index];
                        final isselected = selectedRUTFindex == index;
                      

                        return GestureDetector(
                          onTap: () {
                            setState(() {

                              //if already selected deselect otherwise select
                              if(isselected){
                                 selectedRUTFindex = null;
                              }
                              else{
                                selectedRUTFindex = index;
                              }
                            });
                          },

                          child: AnimatedContainer(//container that animates changes
                            duration: const Duration(milliseconds: 200),
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              color: isselected ? Colors.blue.shade50 : Colors.white,
                              //if there is a selection make it blue othervise white
                              border: Border.all(
                                color: isselected ? Colors.blue : Colors.grey.shade300,
                                width: isselected ? 2 : 1,),
                                //if there is a selection make color blue and width 2 otherwise make them white and 1
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isselected
                                  ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]//make a box shadow
                                  : [], 
                            ),
                            
                            //inside of the container textes etc->>
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text( product['name'],style: TextStyle(fontWeight: FontWeight.bold,color:  Colors.black87,),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const Spacer(),//line
                                //uses info display widget .dart
                                buildnutrientrow("Kcal", "${product['kcal']}"),
                                buildnutrientrow("Prot", "${product['prot']}g"),
                                buildnutrientrow("Carb", "${product['carb']}g"),
                                buildnutrientrow("Fat", "${product['fat']}g"),


                              ],
                            ),
                          ),
                          
                        );
                      },
                    ),
                  ),

                
                  if(selectedRUTFindex != null) ...[
                    //shows the list if rutf is selected
                    const SizedBox(height: 20,),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),

                      child: Column(
                        children: [
                          buildcounterrow("Quantity per day", "Packets", quantityperday, 
                          (val) {setState(() => quantityperday = val);
                          }
                          ),
                          //counter row with a callback to update state
                          const Divider(),
                          buildcounterrow("Duration", "Weeks", durationweeks, 
                          (val) {setState(() => durationweeks = val);
                          }
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Divider(height: 40),
                
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: const Text("Dietary Supplements", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      //arranges items horizontally and moves to the next line if there is no space
                      spacing: 10,
                      runSpacing: 10,

                      //go through every item in the supplements list
                      children: supplements.map((item) {//maps each supplement to a widget 
                        final isselected = selectedsupplements.contains(item['name']);
                        return FilterChip(
                          label: Text("${item['icon']}  ${item['name']}"), 

                          selected: isselected,
                          onSelected:(bool selected) {
                            setState(() {
                              if(selected){
                                selectedsupplements.add(item['name']!);
                                //if tapped to select -> add to the list
                              }
                              else{
                                selectedsupplements.remove(item['name']!);
                                //if tapped to deselect -> remove from the list
                              }
                            });
                          },
                          backgroundColor:Colors.grey.shade100, 
                          selectedColor: Colors.green.shade100,
                          checkmarkColor: Colors.green,
                          labelStyle: TextStyle(color: isselected ? Colors.green.shade900 : Colors.black87,),//conditional styling for selected unselected states.
                          //dark green text if selected,black if not

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), 
                            side: BorderSide(color: isselected ? Colors.green.shade200 : Colors.grey.shade300,)),
                                //green border if selected grey if not
                        );
                      }).toList(),
                      

                    ),

                    
                  ),

                  //show this card if  supplement is selected
                  if(selectedsupplements.isNotEmpty)...[

                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50.withOpacity(0.5), 
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade100),
                      ),

                      child: Column(
                        children: [
                          
                          buildcounterrow("Quantity per day", "Items", supplementquantity, (val) {
                            setState(() => supplementquantity = val);
                          }),
                          const Divider(),
                          
                          buildcounterrow("Duration", "Weeks", supplementduration, (val) {
                            setState(() => supplementduration = val);
                          }),
                        ],
                      ),
                    )
                  ]

                    

                ],
                
                
                
              ),
            ),

            

            
            

          ],
        ),
      ),


      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(247, 241, 241, 241),
          boxShadow:[
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ]
        ),
        child: SafeArea(
          child: Row(
            children: [
                
                  Expanded(
                              child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                 backgroundColor: const Color.fromARGB(255, 176, 174, 174),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                              ),
                              onPressed:() {
                                Navigator.of(context).pop();
                              }, 
                              child: Text('Cancel')
                            )
                          ),

                          const SizedBox(width: 20),

                        //save button
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                              ),
                              onPressed:isloading ? null:() {
                                handlesave();//Lloading? yes -> lock the button null. no -> run the funct
                              }, 
                              child: Text('Save'),
                            )
                          ),
                        ], 
          ),
        ),
      ),

    );
  }
}