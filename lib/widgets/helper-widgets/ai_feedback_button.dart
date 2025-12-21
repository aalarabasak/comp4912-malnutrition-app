//this widget class is used in field worker's and Nutrition Officer's child profile page 
import 'package:flutter/material.dart';
import 'dart:async';

class AiFeedbackButton extends StatefulWidget{

  final VoidCallback onPressed; // will get what happens when clicked from outside of the class

  const AiFeedbackButton({super.key, required this.onPressed});//constructor of the class

  @override
  State <AiFeedbackButton> createState() => AiFeedbackButtonState();
}

class AiFeedbackButtonState extends State<AiFeedbackButton>{
  
  bool isexpanded = false; //Holds the value of whether the button is fully open or closed
  Timer? closeWritingTimer;

  void _handleTap(){
    if(isexpanded){//2nd situation- if the button is open, then navigate to the screen
      widget.onPressed();
    }
    else{
      setState(() {
        isexpanded = true;//if the button is closed, then just expand it
      });
      
      startCloseWritingTimer(); //if the user does nothing minimize the button automatic after 4 seconds
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
      child: AnimatedContainer(duration: const Duration(milliseconds: 300),//animation takes 0.3 seconds to complete
        curve: Curves.easeInOut,

        width: isexpanded ? 170.0: 48.0,// if open, it will be wide, if closed, it will be only as wide as the icon.
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
            //icon part
            Icon(Icons.psychology, color: Colors.black87, size: 24,),

            //writing part of the icon
            //used Flexible and Overflow so that there is no overflow error during the animation.
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