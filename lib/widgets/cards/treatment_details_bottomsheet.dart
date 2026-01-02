import 'package:flutter/material.dart';

class TreatmentDetailsSheet extends StatelessWidget{
  final String diagnosis;
  final String? productname;
  final int? dailyquantity;
  final int? durationweeks;
  final int? totaltarget;
  final DateTime nextvisitdate;
  final List<String>supplements;
  final int? suppquantity;
  final int? suppduration;

  final Widget? footeraction; //for field worker's button function 

  const TreatmentDetailsSheet({super.key, required this.diagnosis, this.productname, this.dailyquantity, this.durationweeks,
  this.totaltarget,required this.nextvisitdate, this.supplements =const[], this.suppduration, this.suppquantity,this.footeraction,
  });

  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(24),
      
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

   
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
           
              Text("Treatment Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),


          
              builddiagnosiscontainer(diagnosis),
            ],
          ),

          const Divider(height: 30),//line

          //RUTF details if any
          if(productname != null)...[
            //first section title
            Text("RUTF Ration", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),

            builddetailrow(Icons.medication, "Product", productname!),
            builddetailrow(Icons.access_time, "Duration", "$durationweeks Weeks"),
            builddetailrow(Icons.onetwothree, "Daily Dose", "$dailyquantity packets / day"),

            //total requirement number of packets is in a container below
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
            //totaltarget calculated in createtreatment 
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text("Total Requirement: $totaltarget Packets",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                  ),
                ],
              ),
            ),
              const SizedBox(height: 20),
          ],

          //supplements if any
          if(supplements.isNotEmpty)...[
        
            Text("Supplements", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),

            Wrap(
             
              spacing: 2,

              children: supplements.map((s) => Chip(//loop through the supplements list and convert each item into a chip widget
                label: Text(s),
                backgroundColor: Colors.green.shade50,
                labelStyle: TextStyle(color: Colors.green.shade900) )).toList(),
            ),

            const SizedBox(height: 5),
           
              builddetailrow(Icons.access_time, "Duration", "$suppduration Weeks"),

      
              builddetailrow(Icons.onetwothree, "Daily Dose", "$suppquantity item(s) / type"),
            
           

            const SizedBox(height: 20),


        ],

        //next visit date
            Text("Schedule", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            builddetailrow(Icons.calendar_month, "Next Visit", "${nextvisitdate.day}/${nextvisitdate.month}/${nextvisitdate.year}"),
            const SizedBox(height: 30),


            // only for field worker roleee
            if(footeraction != null)...[
              const Divider(),
              const SizedBox(height: 10),
              footeraction!,
            ]
          ]
      ),
    );
  }

  //to build diagnosis container
  Widget builddiagnosiscontainer(String diagnosis){
    Color color;
    //find color accdg to diagnosis
    switch(diagnosis){
      case 'SAM': color = Colors.red; 
      case 'MAM': color = Colors.orange; 
      default: color = Colors.green;
    }

    return Container( //diagnosis text with specific color frame
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),

      child: Text(diagnosis, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }


  Widget builddetailrow(IconData icon, String label, String value){
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),

         
          Text("$label: ", style: TextStyle(color: Colors.grey.shade600)),

          
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),

        ],
      ),
    );
  }
}