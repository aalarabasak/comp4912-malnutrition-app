import 'package:flutter/material.dart';

//this is for 1st information card of the child, it is a helper function
  Widget buildinformationrow(String label, String value){

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0), //Add vertical spacing between rows
      child: Row(
        children: [
          //e.g. "age: "
          Text('$label: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87 ),),

          //the value e.g. "3"
          Expanded( //Take remaining space, wrap if long
            child: Text(value, style: TextStyle(fontSize: 15, color: Colors.black87),))
        ],

      ),
      );
  }

  //this is for risk status, nutrition summary, recent activities cards.
  Widget buildCards(String title, String text){

    return Container(
      width: double.infinity,//Cover the entire screen
      margin: EdgeInsets.only(top: 15.0), //put space btw cards
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(10.0),
        color: const Color.fromARGB(255, 178, 190, 194)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //title like risk status
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

          const SizedBox(height: 10),

          //contents
          Text(text, style: TextStyle(fontSize: 15, color: Colors.black54),)
        ],
      ),
    );
  }

  // Single line text generator with bold title and normal value, used in buildmeasuremetcard method
  //it is used to be able to write kg, cm etc in a combined text type structure
  Widget buildRichText(String label, String value, {String suffix = ''}) {
    return Text.rich(
      TextSpan(
        text: '$label: ',style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: '$value$suffix', style: TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }