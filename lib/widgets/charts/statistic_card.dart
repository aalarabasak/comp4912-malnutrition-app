import 'package:flutter/material.dart';

class StatisticCard extends StatelessWidget{
  final String title;
  final String value;
  final IconData icon;
  final Color themecolor;

  const StatisticCard({
    super.key, 
    required this.title,
    required this.icon,
    required this.themecolor,
    required this.value
    });
  
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            spreadRadius: 4,
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ]
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(//icon container
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: themecolor.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 25, color: themecolor),
          ),

          Column(//title and value
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w600),),

              const SizedBox(height: 4,),

              Text(value, style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),)
            ],
          )

        ],

      ),
    );
  }

}