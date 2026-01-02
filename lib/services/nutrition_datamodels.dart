//sending llm datas in a correct way

class NutritionValues{
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  NutritionValues({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  //convert it to json
  Map<String,dynamic> tojson(){
    return{
      'calories': calories,
      'protein': protein,
      'fat' : fat,
      'carbs':carbs,
    };
  }

}

class FoodItem {//rutf or supplement
  final String name;
  final NutritionValues values;

  FoodItem({required this.name, required this.values});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'values': values.tojson(), 
    };
  }
}

class ChildProfile {
  final String age;
  final String gender;
  final double weight;
  final String riskStatus;
  final String riskReason;

  ChildProfile({
    required this.age,
    required this.gender,
    required this.weight,
    required this.riskStatus,
    required this.riskReason,
  });


  Map<String, dynamic> tojson() {
    return {
      'age': age,
      'gender': gender,
      'weight': weight,
      'risk_status': riskStatus,
      'risk_reason': riskReason,
    };
  }
}

class FullAdviceRequest{
  final ChildProfile child;
  final NutritionValues targetvalues;
  final NutritionValues consumedvalues;
  final List<FoodItem> rutfinventory;
  final List<FoodItem> supplements;

  FullAdviceRequest({
    required this.child,
    required this.targetvalues,
    required this.consumedvalues,
    required this.rutfinventory,
    required this.supplements,
  });

  Map<String, dynamic> tojson(){
    return{
      'child': child.tojson(),
      'target_values': targetvalues.tojson(),
      'consumed_values':consumedvalues.tojson(),
      'rutf_inventory': rutfinventory.map((x)=> x.toJson()).toList(),
      'supplements': supplements.map((x) => x.toJson()).toList(),
    };
  }
}

