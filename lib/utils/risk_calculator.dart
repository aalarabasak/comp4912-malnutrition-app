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
      gaugevalue = 1.5;
    }
    else{
      statusColor = Colors.green;
      gaugevalue = 0.5;
    }
    return{
      'statusColor': statusColor,
      'gaugevalue':gaugevalue,
    };
  }
  static Map<String, dynamic> calculateRisk(double muac, String edema, {bool weightLossDetected = false, String? preRiskstatus}){
    
    String textStatus;
    String reason;
    
    //if edema yes, it is directly high risk
    if(edema == 'Yes'){
      return {
        'textStatus':'High Risk',
        'reason': 'Edema detected',
      };
    }
    
    //MUAC control
    if(muac < 115){
      textStatus ='High Risk';
      reason = 'MUAC: $muac mm (<115)';
    }
    else if(muac >= 115 && muac < 125){
      textStatus = 'Moderate Risk';
      reason = 'MUAC: $muac mm';
    }
    else{//the child is healhty, normal. no risk
      textStatus = 'Healthy - No Risk';
      reason = 'Measurements are stable';
    }


    //weight loss detection duration 4 week
    if(weightLossDetected){
      if(textStatus == 'Healthy - No Risk'){
        if(preRiskstatus == 'Moderate Risk'){
          
          textStatus = 'High Risk'; //bump risk from yellow to red
          reason = ' Weight loss detected (>5%)'; //update the reason
        }
        else{
          textStatus = 'Moderate Risk'; //bump risk from green to yellow
          reason = 'Weight loss detected (>5%)'; 
        }
      }
      else if(textStatus == 'Moderate Risk'){
        textStatus = 'High Risk'; //bump risk from yellow to red
        reason += '+Weight loss >5%'; 
      }
      else if(textStatus == 'High Risk'){
        reason += '+Weight loss >5%';
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
      int daysdiff = latestdate.difference(testdate).inDays;

      if(daysdiff >= 21 && daysdiff <= 35){//Search 
        pastweight = double.tryParse(data['weight'].toString());

        if(pastweight != null && pastweight >0){
          
          break;
        }

      }

    }
    //If past weight is found check the 5% rule
    if(pastweight != null && pastweight>0){
      double percentage = (pastweight-currentweight)/pastweight; 
      if(percentage >= 0.05){
        return true;// Risk detected
      }
    }
    return false;
  }
}