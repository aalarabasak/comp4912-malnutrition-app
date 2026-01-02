import 'package:flutter/material.dart';

class DeficitRateCard extends StatelessWidget{
  final String title;
  final double achievementpercent;


  const DeficitRateCard({super.key, required this.title, required this.achievementpercent});

  @override
  Widget build(BuildContext context){

    double deficit = 1.0 -achievementpercent; //calculate deficit rate
    if(deficit <0) deficit=0;//insurance-prevent negative resulr
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
         boxShadow: [BoxShadow(
          color: Colors.grey.withOpacity(0.06),
            spreadRadius: 4,
            blurRadius: 15,
            offset: const Offset(0, 4),
        )],
      ),
      child: Column(
        children: [
    
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
          const SizedBox(height: 8),
        
          Text("${(deficit*100).round()}%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)

        ],
      ),
    );

  }
}