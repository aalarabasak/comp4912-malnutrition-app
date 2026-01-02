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
      final Map<String,dynamic> measurementdata = latestmeasurement.docs.first.data() as Map<String,dynamic> ;//fill measurement data map 
      final double weight = measurementdata['weight'];

      //calculate weekly targets based on the data that I get above- weight. birthdate, gender     
  
      final Map<String,double> weeklytargets = NutritionValuesCalculator.calculateweeklytargets(weight, birthdate, gender);

      //get all mealintakes for child 
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('children').doc(childId)
        .collection('mealIntakes').orderBy('date',descending: true).get();
      
      final DateTime rawNow = DateTime.now();
     
      final DateTime now = DateTime(rawNow.year, rawNow.month, rawNow.day);

      //find the Monday of the current week
      final DateTime currentweekmonday = now.subtract(Duration(days: now.weekday - 1));
      
      // 5 weeks total: 4 past weeks +current week
      final DateTime startdatechart = currentweekmonday.subtract(const Duration(days: 28));

      //group 5weeks- convert Firestore documents to a list of meal data
      final List<Map<String,dynamic>> allmeals = [];
      for(var doc in snapshot.docs){
        final Map<String,dynamic> mealdata = doc.data() as Map<String, dynamic>;
        final DateTime mealdate = DateTime.parse(mealdata['date']);

        if(mealdate.isAfter(startdatechart.subtract(const Duration(seconds: 1)))){//include meals from the last 5 weeks
      
         
          allmeals.add({
            'date': mealdate,
            'totalKcal': mealdata['totalKcal'],
            'totalProteinG': mealdata['totalProteinG'],
            'totalCarbsG': mealdata['totalCarbsG'],
            'totalFatG': mealdata['totalFatG'],
          });

        }
      }
  
      //2nd group meals by week -oldest to newest
      final List<Map<String,dynamic>> weeklydata = [];
      
      for(int i =0; i<5; i++){
        //calculate grouping dates
        final DateTime weekstart = startdatechart.add(Duration(days: i *7)); 
        final DateTime weekend = weekstart.add(Duration(days: 6)); 

        //for uncompleted weeks - their end date
        DateTime displayend = weekend;
        if(weekend.isAfter(now)){
          displayend =now;
        }

        //select meals belong to this week
        final List<Map<String, dynamic>> weekmeals = allmeals.where((meal) {
          final DateTime mealDate = meal['date'];

          return mealDate.isAfter(weekstart.subtract(const Duration(seconds: 1))) &&
            mealDate.isBefore(weekend.add(const Duration(days: 1)));
        }   ).toList();

        //sum up all nutrients for this week
        double weekkcal = 0;
        double weekprotein = 0;
        double weekcarbs = 0;
        double weekfat = 0;
    
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
          calpercentage = (weekkcal/weeklytargets['kcal']!);
        }//to prevent overflow used clamp func
        if(weeklytargets['protein']! >0){
          proteinpercentage = (weekprotein/weeklytargets['protein']!);
        }
        if(weeklytargets['carbs']! >0){
          carbspercentage = (weekcarbs/weeklytargets['carbs']!);
        }
        if(weeklytargets['fat']! >0){
          fatpercentage = (weekfat/weeklytargets['fat']!);
        }

        final String daterangestring = formatdaterange(weekstart, displayend);

        //add this week's data to our list
        weeklydata.add({
          'dateRange': daterangestring, 
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

      return weeklydata;



    }catch(error){
      print('Error fetching nutrition history: $error');
      return [];
    }
  }
//format date range 
  static String formatdaterange(DateTime start, DateTime end){
    if(start.month == end.month){
      return '${start.day}-${end.day} ${getmonthAbvn(end.month)}'; //format: 20-26 Oct same month
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