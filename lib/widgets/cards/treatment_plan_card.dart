import 'package:flutter/material.dart';
import 'package:malnutrition_app/widgets/cards/treatment_details_bottomsheet.dart';
import 'package:malnutrition_app/widgets/helper-widgets/info_display_widgets.dart';
import 'package:malnutrition_app/services/treatment_service.dart';


class TreatmentPlanCard extends StatelessWidget{
  
  final String childID;

  const TreatmentPlanCard({
    super.key,
    required this.childID,
  });

  @override
  Widget build(BuildContext context){

    final TreatmentService treatmentService =TreatmentService(); 

    return StreamBuilder(
      stream: treatmentService.getlatestTreatmentPlan(childID), //go treatment_service.dart
      builder:(context, snapshot) {

        if (snapshot.hasError) return const SizedBox(); 
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
         return  buildCards("Treatment Plan", "No available data.");
        }

        var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;//parse the data

        var rutfmap = data['prescribed_RUTF'] as Map<String, dynamic>?;
        String? productname = rutfmap?['productName'];
        int? dailyquantity = rutfmap?['dailyQuantity'];
        int? durationweeks = rutfmap?['durationWeeks'];
        int? totaltarget =rutfmap?['totalTarget'];
        String diagnosis = data['diagnosis'];

        //String -> DateTime
        DateTime nextVisitDate = DateTime.parse(data['nextvisitdate']);

        
        
        List<String> supplements =[];
        int? supplementquantity;//holds quantity per item
        int? supplementduration;//holds duration in weeks

        var supplementmap = data['supplements'] as Map<String, dynamic>?;//get the supplements field as a Map

        if(supplementmap != null){
          //extract the list of selected food names 
          if (supplementmap['selecteditems'] != null) {
            supplements = List<String>.from(supplementmap['selecteditems']);
          }
          
          supplementquantity = supplementmap['dailyQuantity']; 
          supplementduration = supplementmap['durationWeeks'];
        }

      
        

    
        


    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context, 
          backgroundColor: Colors.transparent,
          isScrollControlled: true,//prevents overflow error
          builder:(context) => TreatmentDetailsSheet(
            diagnosis: diagnosis, 
            nextvisitdate: nextVisitDate,
            productname: productname,
            dailyquantity: dailyquantity,
            durationweeks: durationweeks,
            totaltarget: totaltarget,
            supplements: supplements,
            suppquantity: supplementquantity,
            suppduration: supplementduration,
          ),
        );
        
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 15.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),//rounded corners
          border: Border.all(color: Colors.grey.shade200),

        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //left side all infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //title 
 
                  Text("Treatment Plan: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 8),
                  //product name
                  if(productname !=null)...[
                    buildinformationrow("RUTF Name", productname),
                    const SizedBox(height: 4),
                  ],
                  
                  //quanttiy info
                  if(dailyquantity != null)...[
                    buildRichText("Quantity", "$dailyquantity", suffix: " packets / day"),
                    const SizedBox(height: 4),
                  ],
                  
                  
                  if(productname == null)const SizedBox(height: 4),
                  //if there is no RUTF, open the gap a little the date is not too close to the title.

                  //date last updated
                  buildinformationrow("Next Visit",_formatDate(nextVisitDate)),



                ],
              ),
            ),

            const SizedBox(width: 15),
            //icon part - right part
            Padding(padding: const EdgeInsets.only(top: 20.0), child: buildiconbox(),),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400],),
          ],
        )
        
        
        
        
        
        
        
      ),
    );
    }
    );
  }

  Widget buildiconbox() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: Colors.orange.shade50, 
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.medication_liquid_rounded, 
          color: Colors.orange.shade800,
          size: 48,
        ),
      ),
    );
  }
  //datetime-> string
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}