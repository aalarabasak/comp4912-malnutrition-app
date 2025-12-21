import 'package:flutter/material.dart';

import 'child_profile_screen.dart';
import 'package:malnutrition_app/services/treatment_service.dart';//to get latest treatment plan from Firestore
import 'package:malnutrition_app/services/distribution_service.dart';//to record distributions and update stock
import 'package:malnutrition_app/widgets/cards/treatment_details_bottomsheet.dart';
import 'package:malnutrition_app/widgets/helper-widgets/info_display_widgets.dart';//used for buildCards

class ChildTreatmentDetailsHelper extends StatefulWidget {
  final String childId;
  final String childName;

  const ChildTreatmentDetailsHelper({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<ChildTreatmentDetailsHelper> createState() => _ChildTreatmentDetailsHelperState();
}

class _ChildTreatmentDetailsHelperState extends State<ChildTreatmentDetailsHelper> {
  bool isdelivered = false;//tracks if this treatment plan has just been marked as delivered in the current UI session 
  //used to disable the “Mark as Delivered” button and change its color.

  bool isprocessing = false;//tracks if the app is currently making Firestore calls to record distributions
  //when true:show loading spinner ,disable the button to prevent multiple taps

  Future<void> handledelivery({
    required String? productname,
    required List<String> supplements,
    required int? totaltarget,
    required int? supplementduration,
    required int? supplementquantity,
    required String currentPlanId,
  }) async {
    //process is starting-> lock the button
    setState(() {
      isprocessing = true;
    });

    try {
      final distributionservice = DistributionService();
      bool itemdistributed = false;

      //rutf distribution if any
      if (productname != null) {
        int rutfquantity = totaltarget ?? 1;

        await distributionservice.recorddistribution(
          childname: widget.childName,
          productName: productname,
          quantity: rutfquantity,
          treatmentPlanId: currentPlanId,
        );
        itemdistributed = true;
      }

      //supplements distribution if any
      if (supplements.isNotEmpty) {
        int duration = supplementduration ?? 1;
        int daily = supplementquantity ?? 1;
        int calculatedsuppqty = daily * 7 * duration;

        // Process supplements sequentially to avoid transaction conflicts
        for (String suppname in supplements) {
          await distributionservice.recorddistribution(
            childname: widget.childName,
            productName: suppname,
            quantity: calculatedsuppqty,
            treatmentPlanId: currentPlanId,
          );
        }
        itemdistributed = true;
      }

      //result
      if (mounted) {
        if (itemdistributed) {
          setState(() {
            isprocessing = false;//turn off isprocessing because işlem bitti
            isdelivered = true; //to make the button grey-disabled
          });
        } else {
          setState(() {
            isprocessing = false;
          });
        }
      }
    } catch (errorr) {
      //if there s an error
      if (mounted) {
        setState(() {
          isprocessing = false;//turn off isprocessing because işlem bitti
        }); //to make the button green again

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${errorr.toString().replaceAll('Exception:', '')}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  //used for undo operation
  Future <void> handlerestore(String currentPlanId) async{
    setState(() {
      isprocessing = true;
    });

    try {
      final distributionservice = DistributionService();//call the service
      await distributionservice.reversedistribution(currentPlanId); //call the function 

      if (mounted) {
        setState(() {
          isprocessing = false;
          isdelivered = false; //becomes undelivered reversed
        });
        
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          isprocessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Undo failed: "), backgroundColor: Colors.red),);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: TreatmentService().getlatestTreatmentPlan(widget.childId),//returns latest treatment plan for this child
      builder: (context, snapshot) {
        if (snapshot.hasError) return const SizedBox(); //if there s error no showing
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {//if there is no data
          return buildCards("Treatment Plan", "No available data.");
        }

        //get the treatment plan document id
        String currentPlanId = snapshot.data!.docs.first.id;
        var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;//parse the data

        var rutfmap = data['prescribed_RUTF'] as Map<String, dynamic>?;
        String? productname = rutfmap?['productName'];
        int? dailyquantity = rutfmap?['dailyQuantity'];

        //supplements – same the structure used in treatment_plan_card.dart
        List<String> supplements = [];
        int? supplementquantity; //quantity per item
        int? supplementduration; //duration in weeks

        var supplementmap = data['supplements'] as Map<String, dynamic>?;

        if (supplementmap != null) {
          if (supplementmap['selecteditems'] != null) {
            supplements = List<String>.from(supplementmap['selecteditems']);
          }
          supplementquantity = supplementmap['dailyQuantity'];
          supplementduration = supplementmap['durationWeeks'];
        }

        //String -> DateTime
        DateTime nextVisitDate = DateTime.parse(data['nextvisitdate']);

        int? durationweeks = rutfmap?['durationWeeks'];
        int? totaltarget =rutfmap?['totalTarget'];
        String diagnosis = data['diagnosis'];

        return TreatmentDetailsSheet(
          diagnosis: diagnosis, 
          productname: productname,
          dailyquantity: dailyquantity,
          durationweeks: durationweeks,
          supplements: supplements,
          suppquantity: supplementquantity,
          suppduration: supplementduration,
          nextvisitdate: nextVisitDate,
          totaltarget: totaltarget,

          //special buttons for field worker
          
          footeraction: FutureBuilder<bool>(//use futurebuilder to check if plan already delivered before by using distributionservice
            future: DistributionService().checkIfPlanDelivered(childId: widget.childId,treatmentPlanId: currentPlanId,), 

            builder: (context, distributionSnapshot) {
              //check if still loading
              bool isloading = distributionSnapshot.connectionState == ConnectionState.waiting;
              
              //senkronizasyon
              bool dbdeliveredornot; //whats the sitation in firestore
              if(distributionSnapshot.data != null){

                dbdeliveredornot = distributionSnapshot.data!;
              }
              else{
                dbdeliveredornot = false;
              }

              //whats the last decision
              bool isfinallydelivered;
              if (dbdeliveredornot == true) {
                
                //if db says delivered, its deliverd
                isfinallydelivered = true;
              } 
              else if (isdelivered == true) {
                
                //if db says no delivery, but user clicks the button delivery
                isfinallydelivered = true;
              } 
              else {
                //if both says no delivery
                isfinallydelivered = false;
              }

              bool nothingtodeliver;
              if (productname == null && supplements.isEmpty) {
                nothingtodeliver = true;
              } 
              else {
                nothingtodeliver = false;
              }

              //get the functions
              void deliver() => handledelivery(//for distribution
                productname: productname,
                supplements: supplements,
                totaltarget: totaltarget,
                supplementduration: supplementduration,
                supplementquantity: supplementquantity,
                currentPlanId: currentPlanId,
              );

              void restore () => handlerestore(currentPlanId);//for undo

             final buttonproperties = getbuttonproperty(
              isprocessing: isprocessing, 
              isloading: isloading, 
              nothingtodeliver: 
              nothingtodeliver, 
              isfinallydeliver: isfinallydelivered, 
              deliver: deliver, 
              restore: restore);

              return Row(
                children: [
                  
                  Expanded(//mark as delivered button
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundBuilder: buttonproperties['color'],
                        disabledBackgroundColor: Colors.grey,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      
                      icon: (isprocessing || isloading)

                        ? const SizedBox(width: 20, height: 20,child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),)
                        : Icon(buttonproperties['icon']),

                      label: Text(buttonproperties['text']),//text on it
                      onPressed: buttonproperties['action'],//tap thing
                    )
                  ),

                  const SizedBox(width: 15),//space between two buttons

                  Expanded(//profile buttonnn
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed:() {
                        Navigator.pop(context); //close the bottom sheet

                        Navigator.push(context, MaterialPageRoute(builder: (context) => ChildProfileScreen(childId: widget.childId)));
                        //then, go to the full profile for the specific child
                      }, 
                      child: const Text("View Profile"),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  //button properties
    Map<String, dynamic> getbuttonproperty({required bool isprocessing,required bool isloading,required bool nothingtodeliver,required bool isfinallydeliver,
      required VoidCallback deliver, //deliver task
      required VoidCallback restore, //undo task
    }) {
      
      if (isprocessing || isloading) {//loading situations
        return {
          'color': Colors.grey,
          'text': "Processing...",
          'icon': Icons.hourglass_empty,
          'action': null, //cant be clicked
        };
      }    
     //there is nothing deliver
      if (nothingtodeliver) {
        return {
          'color': Colors.grey.shade400,
          'text': "No Items to Deliver",
          'icon': Icons.block,
          'action': null, //cant be clicked
        };
      }     
      //undo the delivered item
      if (isfinallydeliver) {
        return {
          'color': Colors.orange.shade300,
          'text': "Undo Delivery",
          'icon': Icons.undo,
          'action': restore,//call the undo func
        };
      }
      //deliver mode
      return {
        'color': Colors.green.withOpacity(0.5),
        'text': "Mark as Delivered",
        'icon': Icons.check_circle_outline,
        'action': deliver, //call the deliver func
      };




    }



}


