import 'package:malnutrition_app/services/nutrition_datamodels.dart';
import 'package:malnutrition_app/utils/nutrition_values_calculator.dart';
import 'package:malnutrition_app/utils/formatting_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionDataGathererllm {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<FullAdviceRequest?> prepareadviceRequest(String childid) async{

    try{

      final results = await Future.wait([ //get the data from firebase at the same time in order to earn time
        //get child profile
        firestore.collection('children').doc(childid).get(), //0. child profile

         //get latest measurement
        firestore.collection('children').doc(childid)
        .collection('measurements').orderBy('recordedAt', descending: true).limit(1).get(), //1.measurements

        firestore.collection('children').doc(childid)
        .collection('mealIntakes').orderBy('date', descending: true).get(), //2.mealintakes


        getfoodcollection('RUTF_products'), //3. rutf types

        getfoodcollection('unpackaged_foods'), //4.supplement types

      ]);

      DocumentSnapshot childdoc = results[0] as DocumentSnapshot;
      QuerySnapshot measurementsnapshot = results[1] as QuerySnapshot;
      QuerySnapshot intake = results[2] as QuerySnapshot;
      List<FoodItem> rutflist = results[3] as List<FoodItem>;
      List<FoodItem> supplementlist = results[4] as List<FoodItem>;

      if (!childdoc.exists || measurementsnapshot.docs.isEmpty) return null;

      Map <String, dynamic> childdata = childdoc.data() as Map <String, dynamic> ;
      var measurementdata = measurementsnapshot.docs.first.data() as Map<String, dynamic>;

      //get age field
      String birthDate = childdata['dateofBirth'];
      String age = calculateAge(birthDate);
      //get weight
      double weight = (measurementdata['weight'] as num).toDouble();

      ChildProfile profile = ChildProfile(
        age: age, 
        gender: childdata['gender'], 
        weight: weight, 
        riskStatus: childdata['currentRiskStatus'], 
        riskReason: measurementdata['riskReason'],
      );

      //calculate weekly target nutri values 
      Map<String,dynamic> weeklytargets = NutritionValuesCalculator.calculateweeklytargets(weight, birthDate, childdata['gender']);

      NutritionValues targetvalues = NutritionValues(
        calories: (weeklytargets['kcal'] ?? 0),
        protein: (weeklytargets['protein'] ?? 0),
        fat: (weeklytargets['fat'] ?? 0),
        carbs: (weeklytargets['carbs'] ?? 0),
      );

      //---
      //get the consumed mealintakes last 7 days
      double totalkcal = 0;
      double totalprotein = 0;
      double totalfat = 0;
      double totalcarbs = 0;

      DateTime now = DateTime.now();
      DateTime sevendaysago = now.subtract(const Duration(days: 7));

      for(var doc in intake.docs){
        var data = doc.data() as Map<String, dynamic>;
        DateTime mealdate = DateTime.parse(data['date']);

        if (mealdate.isAfter(sevendaysago)) {
          totalkcal += data['totalKcal'];
          totalprotein += data['totalProteinG'];
          totalfat += data['totalFatG'];
          totalcarbs += data['totalCarbsG'];
        }
      }

      NutritionValues consumedvalues = NutritionValues(
        calories: totalkcal,
        protein: totalprotein,
        fat: totalfat,
        carbs: totalcarbs);


      //prepare request packaged that will go to with LLM api
      return FullAdviceRequest(
        child: profile, 
        targetvalues: targetvalues, 
        consumedvalues: consumedvalues, 
        rutfinventory: rutflist, 
        supplements: supplementlist,
      );

    } catch(e){
      print("Data Gather Error: $e");
      return null;
    }
  }


  Future <List<FoodItem>> getfoodcollection(String collectionname) async{

    QuerySnapshot snapshot = await firestore.collection(collectionname).get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;

      return FoodItem(
        name: data['name'],
        values: NutritionValues(
          calories: (data['kcal'] as num).toDouble(),
          protein: (data['proteinG'] as num).toDouble(),
          fat: (data['fatG'] as num).toDouble(),
          carbs: (data['carbsG'] as num).toDouble(),
        ),
      );
    }).toList();

  }









}