import 'package:flutter/material.dart';
import 'package:malnutrition_app/utils/formatting_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiskCalculator {

  static Map<String, dynamic> calculateGaugeValueandColor(String textStatus){
    Color statusColor;
    double gaugevalue;

    if(textStatus == "High Risk"){
      statusColor = Colors.red;
      gaugevalue = 2.5;//for needle pointer of gauge chart
    }
    else if(textStatus == "Moderate Risk"){
      statusColor = const Color.fromARGB(255, 157, 125, 29);
      gaugevalue = 1.5;//for needle pointer of gauge chart
    }
    else{
      statusColor = Colors.green;
      gaugevalue = 0.5;//for needle pointer of gauge chart
    }
    return{
      'statusColor': statusColor,
      'gaugevalue':gaugevalue,
    };
  }
  static Map<String, dynamic> calculateRisk(double muac, String edema, {bool weightLossDetected = false, String? preRiskstatus}){
    
    String textStatus;
    String reason;
    
    //1st rule- if edema yes, it is directly high risk
    if(edema == 'Yes'){//if edema is present, it is always high risk
      return {
        'textStatus':'High Risk',//need for uı and for database
        'reason': 'Edema detected',
      };
    }
    
    //2nd rule- MUAC control
    if(muac < 115){//MUAC less than 115mm shows high malnutrition  
      textStatus ='High Risk';//need for uı and for database
      reason = 'MUAC: $muac mm (<115)';
    }
    else if(muac >= 115 && muac < 125){// MUAC between 115 and 125 shows moderate malnutrition
      textStatus = 'Moderate Risk';//need for uı and for database
      reason = 'MUAC: $muac mm';
    }
    else{//the child is healhty, normal. no risk
      textStatus = 'Healthy - No Risk';
      reason = 'Measurements are stable';
    }


    //3rd rule weight loss detection duration 4 week
    if(weightLossDetected){
      if(textStatus == 'Healthy - No Risk'){
        if(preRiskstatus == 'Moderate Risk'){
          //if new MUAC results says healthy but the child was already at Moderate risk,  a bump to High.
          textStatus = 'High Risk'; //bump risk from yellow to red
          reason = ' Weight loss detected (>5%)'; //update the reason
        }
        else{
          textStatus = 'Moderate Risk'; //bump risk from green to yellow
          reason = 'Weight loss detected (>5%)'; //update the reason
        }
      }
      else if(textStatus == 'Moderate Risk'){
        textStatus = 'High Risk'; //bump risk from yellow to red
        reason += '+Weight loss >5%'; //update the reason
      }
    }

    return{
      'textStatus': textStatus,
      'reason': reason,
    };
  }

  static bool checkWeightLoss(List<QueryDocumentSnapshot> docs, DateTime latestdate, double currentweight){

    if (currentweight <= 0) return false; 

    double? pastweight;

    for(var doc in docs){
      var data = doc.data() as Map<String, dynamic>;

      //takes the data of measurement from list docs
      String datestring = data['dateofMeasurement'].toString();
      
      DateTime testdate = parseDateString(datestring);
      int daysdiff = latestdate.difference(testdate).inDays;//// Find the difference in days between two dates

      if(daysdiff >= 21 && daysdiff <= 35){//Search 21 to 35 days about 1 month
        pastweight = double.tryParse(data['weight'].toString());

        if(pastweight != null && pastweight >0){
          //If the weight was entered on that date -> use it as a reference and finish t
          break;
        }

      }

    }
    //If past weight is found check the 5% rule
    if(pastweight != null && pastweight>0){
      double percentage = (pastweight-currentweight)/pastweight; //apply formula
      if(percentage >= 0.05){//if it is 0.05 or greater , make it true
        return true;// Risk detected
      }
    }
    return false;//no risk
  }
}