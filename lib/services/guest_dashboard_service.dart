import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/formatting_helpers.dart';
import 'package:intl/intl.dart';

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

  //trend line chart high risk
  Future <Map<String,dynamic>> gethighrisklinedata(String period) async{
    List<double> yspots=[];//y axis
    List<String>xlabels=[];//x axis

    try{
      //get only high risk ones
      QuerySnapshot highrisksnapshot= await firestore.collectionGroup('measurements').where('calculatedRiskStatus', isEqualTo: 'High Risk').get();
      
      //get the dates from the snapshot
      List<DateTime> dates =[];
      for(var doc in highrisksnapshot.docs){
        var data= doc.data() as Map<String, dynamic>;

        if(data.containsKey('dateofMeasurement')){
          DateTime stringtodatetime = parseDateString(data['dateofMeasurement']);
          dates.add(stringtodatetime);
        }
      }

      if(period == "week"){//if the filter is week
        for(int i =6; i>=0; i--){
          //x axis
          DateTime day =DateTime.now().subtract(Duration(days: i));
          String formatteddate = DateFormat('d MMM').format(day);
          xlabels.add(formatteddate);

          //y axis
          int dailycount= dates.where((date)=> 
            date.day == day.day && date.month ==day.month&& date.year==day.year
          ).length;
          yspots.add(dailycount.toDouble());
         
        }

      }
      else if(period == "month"){//if filter is month

        for(int i =3; i>=0; i--){
          //x axis
          DateTime weekstart =DateTime.now().subtract(Duration(days: (i*7)+6));
          DateTime weekend = DateTime.now().subtract(Duration(days: i*7));
          String formatteddate = DateFormat('d MMM').format(weekstart);
          xlabels.add(formatteddate);


          //y axis
          int weeklycount = dates.where((date)=> 
            date.isAfter(weekstart.subtract(Duration(seconds: 1)))&& date.isBefore(weekend.subtract(Duration(seconds: 1)))
          ).length;
          yspots.add(weeklycount.toDouble());

          


        }

      }

      else{//if the filter is all
        for(int i=5; i>=0; i--){
          DateTime month =DateTime(DateTime.now().year,DateTime.now().month - i );
          String formatteddate = DateFormat('MMM y').format(month);
          xlabels.add(formatteddate);

          int monthlycount = dates.where((date) => date.month== month.month&& date.year== month.year).length;
          yspots.add(monthlycount.toDouble());
        }

      }

      return {'spots': yspots, 'labels': xlabels};




    }catch(e){
      print("$e");
      return {'spots': [], 'labels': []};
    }

  }








}