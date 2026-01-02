
import 'package:flutter/material.dart';
import 'dart:async';

class AiFeedbackButton extends StatefulWidget{

  final VoidCallback onPressed; 

  const AiFeedbackButton({super.key, required this.onPressed});

  @override
  State <AiFeedbackButton> createState() => AiFeedbackButtonState();
}

class AiFeedbackButtonState extends State<AiFeedbackButton>{
  
  bool isexpanded = false; //holds the value whether the button is open or closed
  Timer? closeWritingTimer;

  void _handleTap(){
    if(isexpanded){//navigate to the screenif the button is open
      widget.onPressed();
    }
    else{
      setState(() {
        isexpanded = true;//expand it if the button is closed
      });
      
      startCloseWritingTimer(); //close after 4 seconds
    }
  }

  void startCloseWritingTimer(){
    closeWritingTimer?.cancel(); //close the old timer

    closeWritingTimer = Timer(const Duration(seconds: 4), () {
      if(mounted){
        setState(() {
          isexpanded = false;
        });
      }
    });
  }

  @override
  void dispose(){
    closeWritingTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: () => _handleTap(),
      child: AnimatedContainer(duration: const Duration(milliseconds: 300),//takes 0.3 seconds to complete
        curve: Curves.easeInOut,

        width: isexpanded ? 170.0: 48.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: const Color(0xFF9FA8DA).withOpacity(0.5), 
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],          
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
         
            Icon(Icons.psychology, color: Colors.black87, size: 24,),

            
     
            if(isexpanded)
              Flexible(child: Padding(padding: EdgeInsets.only(left: 8.0),
                child: Text('View AI Feedback', maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),),

              )
              )
          ],
        ),
      ),
    );
  }
}