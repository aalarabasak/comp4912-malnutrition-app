import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/nutrition_values_calculator.dart';

class NutritionHistoryService {
  //gets and processes nutrition data for last 5weeks
  static Future<List<Map<String,dynamic>> >getWeeklyNutritiondata(String childId) async{

    try{

      //get child data to get birthdate gender
      final DocumentSnapshot childdoc = await FirebaseFirestore.instance.collection('children').doc(childId).get();
      final Map<String,dynamic> childdata = childdoc.data() as Map<String,dynamic> ;//fill childdata map with firebase values
      final String birthdate = childdata['dateofBirth'];
      final String gender = childdata['gender'];

      //get latest measurement data to get weight
      final QuerySnapshot latestmeasurement = await FirebaseFirestore.instance
      .collection('children').doc(childId)
      .collection('measurements').orderBy('recordedAt', descending: true).limit(1).get();
      final Map<String,dynamic> measurementdata = latestmeasurement.docs.first.data() as Map<String,dynamic> ;//fill measurement data map with firebase values
      final double weight = measurementdata['weight'];

      //calculate weekly targets based on the data that I get above- weight. birthdate, gender     
      //what the child should eat in a week
      final Map<String,double> weeklytargets = NutritionValuesCalculator.calculateweeklytargets(weight, birthdate, gender);

      //get all mealintakes for child 
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('children').doc(childId)
        .collection('mealIntakes').orderBy('date',descending: true).get();
      
      final DateTime rawNow = DateTime.now();
      //set the time to 00:00:00 so  it covers the entire day no matter what time of day 
      final DateTime now = DateTime(rawNow.year, rawNow.month, rawNow.day);
      final DateTime fiveweeksago = now.subtract(const Duration(days: 35));//calculate the start of 5 weeks ago


      //1st group 5weeks- convert Firestore documents to a list of meal data
      final List<Map<String,dynamic>> allmeals = [];//create empty list
      for(var doc in snapshot.docs){
        final Map<String,dynamic> mealdata = doc.data() as Map<String, dynamic>;
        final DateTime mealdate = DateTime.parse(mealdata['date']);//get the date part from datetime attribute

        if(mealdate.isAfter(fiveweeksago)){//include meals from the last 5 weeks
          allmeals.add({
            'date': mealdate,
            'totalKcal': mealdata['totalKcal'],
            'totalProteinG': mealdata['totalProteinG'],
            'totalCarbsG': mealdata['totalCarbsG'],
            'totalFatG': mealdata['totalFatG'],
          });

        }
      }
      //------
      //2nd group meals by week -oldest to newest
      final List<Map<String,dynamic>> weeklydata = [];//create empty list
      //create 5 weeks starting from 5 weeks ago
      for(int weekindex =0; weekindex<5; weekindex++){
        //calculate grouping dates
        final DateTime weekstart = fiveweeksago.add(Duration(days: weekindex *7)); //calculate start day of week
        final DateTime weekend = weekstart.add(Duration(days: 6)); //calculate end day of week - 6 days later

        //select meals belong to this week
        final List<Map<String, dynamic>> weekmeals = allmeals.where((meal) {
          final DateTime mealDate = meal['date'];

          return mealDate.isAfter(weekstart.subtract(const Duration(seconds: 1))) &&//to include first day of week
            mealDate.isBefore(weekend.add(const Duration(days: 1)));//to include last day of week add 1 day
        }   ).toList();

        //sum up all nutrients for this week
        double weekkcal = 0;
        double weekprotein = 0;
        double weekcarbs = 0;
        double weekfat = 0;
        //calculate
        for(var meal in weekmeals){
          weekkcal+= meal['totalKcal'] ; 
          weekprotein += meal['totalProteinG'] ;
          weekcarbs += meal['totalCarbsG'] ;
          weekfat += meal['totalFatG'] ;

        }

        //calculate percentage of target met
        double calpercentage =0;
        double proteinpercentage=0;
        double carbspercentage = 0;
        double fatpercentage = 0;

        if(weeklytargets['kcal']! >0){
          calpercentage = (weekkcal/weeklytargets['kcal']!).clamp(0.0, 1.2);
        }//to prevent overflow used clamp func
        if(weeklytargets['protein']! >0){
          proteinpercentage = (weekprotein/weeklytargets['protein']!).clamp(0.0, 1.2);
        }//to prevent overflow used clamp func
        if(weeklytargets['carbs']! >0){
          carbspercentage = (weekcarbs/weeklytargets['carbs']!).clamp(0.0, 1.2);
        }//to prevent overflow used clamp func
        if(weeklytargets['fat']! >0){
          fatpercentage = (weekfat/weeklytargets['fat']!).clamp(0.0, 1.2);
        }//to prevent overflow used clamp func

        final String daterangestring = formatdaterange(weekstart,weekend);
        //---
        //Add this week's data to our list
        weeklydata.add({
          'week': 'Week ${weekindex + 1}',
          'dateRange': daterangestring, //for x axis labels for line chart
          'calPercent': calpercentage,
          'proPercent': proteinpercentage,
          'carbPercent': carbspercentage,
          'fatPercent': fatpercentage,
          'cal': weekkcal,
          'pro': weekprotein,
          'carb': weekcarbs,
          'fat': weekfat,
        });

      }

      return weeklydata;//return the list oldest week first- newest last



    }catch(error){
      print('Error fetching nutrition history: $error');
      return [];//return empty list if there's an error
    }
  }
//helper func to format date range 
  static String formatdaterange(DateTime start, DateTime end){
    if(start.month == end.month){
      return '${start.day}-${end.day} ${getmonthAbvn(end.month)}'; //format: 20-26 Oct
    }
    else{
      return '${start.day} ${getmonthAbvn(start.month)}-${end.day} ${getmonthAbvn(end.month)}'; //format: 28 Oct - 3 Nov
    }
  }

  //func to get month abbreviation
  static String getmonthAbvn(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}