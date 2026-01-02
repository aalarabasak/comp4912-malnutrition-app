import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../screens/field-worker-screens/meal_confirmation_unpackaged.dart';

class FoodCameraHelper {

  final ApiService apiservice = ApiService();
  final ImagePicker picker = ImagePicker();
  

  Future<void> captureandAnalyze(BuildContext context, String childId)async{
    try{
      final XFile? photo = await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);
      //open the camera and open the back camera of the phone

      if(photo == null) return; 

      if(!context.mounted) return;
      showDialog(context: context, 
        barrierDismissible: false,
        builder: (ctx) => Center(child: CircularProgressIndicator(),));

      File imagefile = File(photo.path); //send to the api (to the m3 mac pc)
      var result = await apiservice.detectFood(imagefile);

      if(!context.mounted) return;
      Navigator.pop(context); 

      if(result != null){//navigate to confirmation page
        if(!context.mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => MealConfirmationUnpackaged(image: imagefile, fooddata: result, childid: childId)));
      }
      else{
        if(context.mounted){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("The food was not recognized. Try again"), backgroundColor: Colors.red,));
        }

      }


    }catch(e){
      if(context.mounted){
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Something is wrong $e"), backgroundColor: Colors.red,));
      }
    }
  }











}