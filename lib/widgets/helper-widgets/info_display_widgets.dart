import 'package:flutter/material.dart';


// creates a simple row widget with a bold label and a normal value
  Widget buildinformationrow(String label, String value){

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0), //Add vertical spacing between rows
      child: Row(
        children: [

          Text('$label: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87 ),),

 
          Expanded( //Take remaining space, wrap if long
            child: Text(value, style: TextStyle(fontSize: 15, color: Colors.black87),))
        ],

      ),
      );
  }

  //creates the basic structure for information cards 
  Widget buildCards(String title, String text){

    return Container(
      width: double.infinity,//covers the full width of the screen
      margin: EdgeInsets.only(top: 15.0), //put space above card
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.orangeAccent.withOpacity(0.2), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,// Align content to the left.
        children: [
          
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

          const SizedBox(height: 10),

        
          Text(text, style: TextStyle(fontSize: 15, color: Colors.black54),)
        ],
      ),
    );
  }

  // creates  line of text by combining a label a value and a suffix like kg
  Widget buildRichText(String label, String value, {String suffix = ''}) {
    return Text.rich(//uses Text.rich two different styles in one widget
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

// create small color box plus text
Widget buildlegend(Color color, String text){
  return Row(
    children: [
      Container(
        width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.rectangle),
      ),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),) 
    ],
  );
}
//used in guest user screens stock pie chart - risk pie chart
Widget buildlegendwithvalue(Color color, String text, int value){
  return Row(
    children: [
      Container(
        width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.rectangle),
      ),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),) ,//text
      Text("$value", style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),), //value
    ],
  );
}

//small nutrition value line in rutf containers in create treatment plan screen
Widget buildnutrientrow(String label, String value){
  return Padding(padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
}

Widget buildcounterrow(String title, String unit, int value, Function(int) onChanged){
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("$value $unit", style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
        ],

        
      ),

      Row(
        children: [
          IconButton(
            onPressed:() {
              if(value>0){
                onChanged(value-1);
              }
              else{
                return;
              }
            },
            icon: const Icon(Icons.remove_circle_outline),
            color: Colors.grey,
          ),
          IconButton(
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add_circle),
            color: Colors.blue,
            iconSize: 32,
          )
        ],
      )
    ],
  );
}