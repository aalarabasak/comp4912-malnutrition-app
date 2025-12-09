

class NutritionValuesCalculator {

  static int calculateageinmonths(String birthdatestring){

    final parts = birthdatestring.split('/');//split the string by slash
    final int day = int.parse(parts[0]); //take the day part
    final int month = int.parse(parts[1]);//take the month part
    final int year = int.parse(parts[2]);//take the year part

    final DateTime birthdate = DateTime(year, month, day);//merge it to real dat type
    final DateTime currentDate = DateTime.now();
    int ageinmonths = (currentDate.year-birthdate.year)*12 + (currentDate.month-birthdate.month); //apply difference formula

    if(currentDate.day<birthdate.day){
      ageinmonths--;//if the day of the month hasnt reached yet -> decrease 1 unit
    }

    return ageinmonths < 0 ? 0 : ageinmonths;//prevent ageinmonths being negative


  }

  static Map<String,dynamic> calculatedailyneed(double weightkg, String birthdatestring, String gender){
    //daily need calculation based on gender-https://www.fao.org/4/y5686e/y5686e06.htm#TopOfPage

    int ageinmonths = calculateageinmonths(birthdatestring);
    bool isgirl=false;
    if(gender.toLowerCase().trim() == "female"){
      isgirl = true;
    }

    double targetkcalperkg;
    double targetproteinperkg;

    if(ageinmonths <=12){//baby 0-1 age
      if(isgirl){
        targetkcalperkg = 98.0;
      }
      else{
        targetkcalperkg =103.0;
      }
      targetproteinperkg = 1.5;
    }
    else if(ageinmonths>12 && ageinmonths <= 36){//1-3 age
       if(isgirl){
        targetkcalperkg = 80.0;
      }
      else{
        targetkcalperkg =82.0;
      }
      targetproteinperkg = 1.15;

    }
    else{ //3-5 age interval
       if(isgirl){
        targetkcalperkg = 75.0;
      }
      else{
        targetkcalperkg =78.0;
      }
      targetproteinperkg = 1.0;
    }

    //total daily need calculation
    double totaltargetkcal = weightkg* targetkcalperkg; //total need kcal
    double totaltargetprotein = weightkg* targetproteinperkg;//total protein 

    // Pediatric Standard: 55% Carbs 30% Fat
    // 1g Carbs = 4 kcal- 1g Fat = 9 kcal
    double totaltargetcarbs = (totaltargetkcal* 0.55) / 4;
    double totaltargetfat= (totaltargetkcal* 0.30) / 9;

    return {
      'kcal': totaltargetkcal,
      'protein' : totaltargetprotein,
      'carbs' : totaltargetcarbs,
      'fat':totaltargetfat,
    };


  }

  //calculation of weekly needs- use this in nutri sum card
  static Map<String,double>calculateweeklytargets(double weightkg, String birthdatestring, String gender){
    final dailyneed = calculatedailyneed(weightkg, birthdatestring, gender);
    return{
      'kcal': dailyneed['kcal']*7,
      'protein' : dailyneed['protein']*7,
      'carbs' : dailyneed['carbs']*7,
      'fat':dailyneed['fat']*7,
    };
  }
















}
