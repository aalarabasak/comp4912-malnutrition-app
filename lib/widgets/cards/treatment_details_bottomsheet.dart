import 'package:flutter/material.dart';

class TreatmentDetailsSheet extends StatelessWidget{
  final String diagnosis;
  final String? productname;
  final int? dailyquantity;
  final int? durationweeks;
  final int? totaltarget;
  final DateTime nextvisitdate;
  final List<String>supplements;

  final Widget? footeraction; //this is for field worker to rich this class with a button function 

  const TreatmentDetailsSheet({super.key, required this.diagnosis, this.productname, this.dailyquantity, this.durationweeks,
  this.totaltarget,required this.nextvisitdate, this.supplements =const[], this.footeraction,
  });//constructor of class

  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(24),
      //padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),//bu field worker için (buton ekleyeceği için alta)duruma göre sil
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,//take up as much space as the content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //üst tutamaç- small grey thing
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

          //title and diagnosis
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //title
              Text("Treatment Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),


              //diagnosis 
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
            //I calculated this field in create_treatment_plan.drt --'totalTarget': quantityperday*7*durationweeks,//total quantity
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
            //title
            Text("Supplements", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),

            Wrap(
              //widget arranges items horizontally and moves to the next line if there is no space
              spacing: 2,//no horizontal gap between chips

              children: supplements.map((s) => Chip(//loop through the supplements list and convert each item into a chip widget
                label: Text(s),//showthe supplement name inside the chip
                backgroundColor: Colors.green.shade50,
                labelStyle: TextStyle(color: Colors.green.shade900) )).toList(),//convert the map result back to a list of widgets
            ),

            const SizedBox(height: 20),


        ],

        //next visit date
            Text("Schedule", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            builddetailrow(Icons.calendar_month, "Next Visit", "${nextvisitdate.day}/${nextvisitdate.month}/${nextvisitdate.year}"),
            const SizedBox(height: 30),


            //this is only for field worker roleee!!!!!1
            if(footeraction != null)...[
              const Divider(),
              const SizedBox(height: 10),
              footeraction!,//show that it is not null with an ünlem bcs it is inside an if
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

  //Icon + label + value
  Widget builddetailrow(IconData icon, String label, String value){
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          //icon
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),

          //label
          Text("$label: ", style: TextStyle(color: Colors.grey.shade600)),

          //value
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),

        ],
      ),
    );
  }
}