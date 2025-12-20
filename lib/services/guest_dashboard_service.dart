import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/formatting_helpers.dart';

class GuestDashboardService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<int> getchildcount(String period) async{//used to get registered child count
    Query query = firestore.collection('children');

    AggregateQuerySnapshot snapshot = await query.count().get(); //this aggre just brings the number not the data content

    return snapshot.count ?? 0;

  }

  //risk status distribution card
  Future<Map<String,double>> getriskvalues(String period) async{

    int redcount =0;
    int greencount=0;
    int yellowcount =0;

    String highrisk = "High Risk";
    String moderaterisk = "Moderate Risk";
    String norisk = "Healthy - No Risk";

    try{
      if(period == "all"){//all filter month
      Query query = firestore.collection('children');
      var redquery = query.where('currentRiskStatus', isEqualTo: highrisk).count();
      var yellowquery = query.where('currentRiskStatus', isEqualTo: moderaterisk).count();
      var greenquery = query.where('currentRiskStatus', isEqualTo: norisk).count();

      final results= await Future.wait([
        redquery.get(),yellowquery.get(),greenquery.get(),
      ]);
      redcount =results[0].count ?? 0;
      yellowcount = results[1].count ??0;
      greencount=results[2].count?? 0;

    }
    else{//week or month filter part

      QuerySnapshot allmeasurements =await firestore.collectionGroup('measurements').get(); //look all the child's measurement subcollection

      DateTime date;
      if(period == 'week'){//week
        date = DateTime.now().subtract(const Duration(days: 7));
      }
      else{//month
        date = DateTime.now().subtract(const Duration(days: 30));
      }

      Map<String, Map<String, dynamic>> childreports = {}; //empty map , only store unique ones a child should only one report

      for(var doc in allmeasurements.docs){
        var data = doc.data() as Map<String, dynamic>;
        String datestring = data['dateofMeasurement'];
        String status = data['calculatedRiskStatus'];
        DateTime measurementdate = parseDateString(datestring); //to convert to datetime from string

        if(measurementdate.isAfter(date) || measurementdate.isAtSameMomentAs(date)){
          String childId = doc.reference.parent.parent!.id;//find the owner childdocid of this measurement

          
            if(!childreports.containsKey(childId)){//if child is npt in list
              childreports[childId] ={'date': measurementdate, 'status': status};
            }

            else{//if child is in list, compare the dates

              DateTime existingdate = childreports[childId]!['date'];
                if(measurementdate.isAfter(existingdate)){
                  childreports[childId] = {'date': measurementdate, 'status': status};
                }
            }
          
          
        }
        
      }

      for(var report in childreports.values){
        
        String finalstatus=report['status'];

          if(finalstatus == highrisk){
             redcount++;
          }
          else if(finalstatus == moderaterisk){
            yellowcount++;
          }
          else if(finalstatus == norisk){
            greencount++;
          }
        
      }

    

    }

    return {
        'red': redcount.toDouble(),
        'yellow': yellowcount.toDouble(),
        'green': greencount.toDouble(),
      };
    }catch(e){
      print("$e");
      return {'red': 0, 'yellow': 0, 'green': 0};
    }

  }


  //used for rutfstock levels card 
  Future <Map<String,double>> getstockvalues(String period) async{
    double remainingstock =0;
    double stockused=0;

    try{
      //stock remaining part
      QuerySnapshot stocksnapshot = await firestore.collection('stocks').where('category', isEqualTo: 'RUTF').get();

      for(var doc in stocksnapshot.docs){
        var data =doc.data() as Map<String, dynamic>;
        remainingstock += (data['quantity'] as num).toDouble();
      }

      Query distributionquery = await firestore.collection('distributions').where('category', isEqualTo: 'RUTF');

      if(period =="week"){
        DateTime lastweek = DateTime.now().subtract(Duration(days: 7));
        distributionquery = distributionquery.where('distributedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(lastweek));
      }
      else if(period=="month"){
        DateTime lastmonth = DateTime.now().subtract(Duration(days: 30));
        distributionquery = distributionquery.where('distributedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(lastmonth));
      }

      QuerySnapshot distributionsnapshot = await distributionquery.get();

      for(var doc in distributionsnapshot.docs){
        var data = doc.data() as Map<String,dynamic>;
        stockused += (data['quantity']as num).toDouble();
      }

      return {'remaining':remainingstock, 'used':stockused};


    }catch(e){
      print("$e");
      return {'remaining': 0, 'used': 0};
    }
  }









}