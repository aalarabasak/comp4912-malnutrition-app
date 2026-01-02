import 'package:flutter/material.dart';


class AiFeedbackDialog extends StatelessWidget{
  final String airesponse;

  const AiFeedbackDialog({
    super.key,
    required this.airesponse,
  });

  @override
  Widget build(BuildContext context){
    final themecolor = const Color.fromARGB(255, 229, 142, 171);
    final bordercolor = const Color.fromARGB(255, 229, 142, 171);

    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          const Text("NutriAI Analysis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),),

          //gif link: https://tr.pinterest.com/pin/1055599906171556/
          Image.asset(
            "assets/images/gifs/bot_icon.gif",
            height: 115,
            width: 115,
          ),

          //speech bubble
          Stack(
            clipBehavior: Clip.none,
            children: [
            
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white, //inside color of container
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: bordercolor, width: 2), 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),

                child: Text(airesponse, style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87, fontWeight: FontWeight.w500),),
              ),

              Positioned(//the tail of the baloon- made it from a square container
                top: -8,
                left: 48,
                child: Transform.rotate(
                  angle: 0.785, //rotate the square 45 derece
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,//white inside remove the edge of the box
                      border: Border(
                        top: BorderSide(color: bordercolor, width: 2),
                        left: BorderSide(color: bordercolor, width: 2),
                      )

                    ),
                  ),
                )
              )
            ],
          ),
          

          const SizedBox(height: 25,),

        
          Divider(thickness: 1, color:Colors.grey),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("",style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic), ),
              Text(DateTime.now().toString().split(" ")[0], style: TextStyle(fontSize: 11, color: Colors.grey),),
            ],

          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed:() {
                Navigator.of(context).pop();
              }, 
              style: TextButton.styleFrom(
                foregroundColor: themecolor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
                backgroundColor: themecolor.withOpacity(0.1),
              ),
              label: Text("Close", style: TextStyle(fontWeight: FontWeight.bold),),
              icon: Icon(Icons.close, size: 20,),
            ),
          )
        ],
      ),
    );
  }
}