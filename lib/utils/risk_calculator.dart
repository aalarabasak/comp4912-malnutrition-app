import 'package:flutter/material.dart';

class RiskCalculator {

  static Map<String, dynamic> calculateRisk(double muac, String edema, {bool weightLossDetected = false}){
    
    String textStatus;
    Color statusColor;
    String reason;
    double gaugevalue;
    
    //1st rule- if edema yes, it is directly high risk
    if(edema == 'Yes'){//if edema is present, it is always high risk
      return {
        'textStatus':'High Risk',//need for uı and for database
        'statusColor':Colors.red,
        'reason': 'Edema detected',
        'gaugevalue':2.5, //for needle pointer of gauge chart
      };
    }
    
    //2nd rule- MUAC control
    if(muac < 115){//MUAC less than 115mm shows high malnutrition  
      textStatus ='High Risk';//need for uı and for database
      statusColor = Colors.red;
      reason = 'MUAC: $muac mm (<115)';
      gaugevalue = 2.5; //for needle pointer of gauge chart
    }
    else if(muac >= 115 && muac < 125){// MUAC between 115 and 125 shows moderate malnutrition
      textStatus = 'Moderate Risk';//need for uı and for database
      statusColor = const Color.fromARGB(255, 157, 125, 29);
      reason = 'MUAC: $muac mm';
      gaugevalue = 1.5; //for needle pointer of gauge chart
    }
    else{//the child is healhty, normal. no risk
      textStatus = 'Healthy - No Risk';
      statusColor = Colors.green;
      reason = 'Measurements are stable';
      gaugevalue = 0.5;
    }


    //3rd rule weight loss detection duration 4 week
    if(weightLossDetected){
      if(textStatus == 'Healthy - No Risk'){
        textStatus = 'Moderate Risk'; //bump risk from green to yellow
        statusColor = const Color.fromARGB(255, 157, 125, 29);
        reason = 'Weight loss detected (>5%)'; //update the reason
        gaugevalue = 1.5;
      }
      else if(textStatus == 'Moderate Risk'){
        textStatus = 'High Risk'; //bump risk from yellow to red
        statusColor = Colors.red;
        reason += '+ Weight loss >5%'; //update the reason
        gaugevalue = 2.5;
      }


    }

    return{
      'textStatus': textStatus,
      'statusColor': statusColor,
      'reason': reason,
      'gaugevalue': gaugevalue, //for needle pointer of gauge chart
    };
  }
}