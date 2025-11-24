import 'package:flutter/material.dart';

//this is for 1st information card of the child, it is a helper function - used in child profile screen etc.
// creates a simple row widget with a bold label and a normal value
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

  // this function creates the basic structure for informational cards risk status, nutrition summary, recent activities cards.
  Widget buildCards(String title, String text){

    return Container(
      width: double.infinity,//covers the full width of the screen
      margin: EdgeInsets.only(top: 15.0), //put space above card
      padding: EdgeInsets.all(10.0),//Internal padding around the content
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(10.0),
        color: const Color.fromARGB(255, 178, 190, 194)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,// Align content to the left.
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

  // This function creates a single line of text by combining a bold label a value and an optional suffix like kg
  //it is used to be able to write kg, cm etc in a combined text type structure
  Widget buildRichText(String label, String value, {String suffix = ''}) {
    return Text.rich(//uses Text.rich to apply two different styles in one widget.
      TextSpan(
        //1st part label -bold
        text: '$label: ',style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold),
        children: [
          TextSpan(//2nd part value and suffix
            text: '$value$suffix', style: TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }