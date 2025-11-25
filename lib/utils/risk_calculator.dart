import 'package:flutter/material.dart';

class RiskCalculator {

  static Map<String, dynamic> calculateRisk(double muac, String edema){
    if(edema == 'Yes'){//if edema is present, it is always high risk
      return {
        'textStatus':'High Risk',//need for uı and for database
        'statusColor':Colors.red,
        'reason': 'Edema detected',
        'gaugevalue':2.5, //for needle pointer of gauge chart
      };
    }
    if(muac < 115){//MUAC less than 115mm shows high malnutrition
      return{
        'textStatus':'High Risk',//need for uı and for database
        'statusColor':Colors.red,
        'reason': 'MUAC: $muac mm (<115)',
        'gaugevalue':2.5, //for needle pointer of gauge chart
      };
    }

    if(muac >= 115 && muac < 125){// MUAC between 115 and 125 shows moderate malnutrition
      return{
        'textStatus':'Moderate Risk',//need for uı and for database
        'statusColor':const Color.fromARGB(255, 157, 125, 29),
        'reason': 'MUAC: $muac mm',
        'gaugevalue':1.5, //for needle pointer of gauge chart
      };
    }

    return{//the child is healthy-no risk normal
      'textStatus':'Healthy - No Risk',//need for uı and for database
      'statusColor':Colors.green,
      'reason': 'Measurements are stable',
      'gaugevalue':0.5, //for needle pointer of gauge chart
    };
  }
}