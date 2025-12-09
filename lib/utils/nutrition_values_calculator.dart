

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
    // references
    //  Kcal: FAO 2004 Report, Table 3.2 & Table 4.5
    // Protein : WHO TRS 935, Table 33a
    // fat: FAO FNP 91 (2010), Table 2.2

    int ageinmonths = calculateageinmonths(birthdatestring);
    bool isgirl=false;
    if(gender.toLowerCase().trim() == "female"){
      isgirl = true;
    }

    double targetkcalperkg;
    double targetproteinperkg;
    double fatpercentage;

    if(ageinmonths <=6){//baby 0- 6 months 
      if(isgirl){
        targetkcalperkg = 92.0;
      }
      else{
        targetkcalperkg =93.0;
      }
      targetproteinperkg = 1.5;
      fatpercentage = 0.45;
    }
    else if(ageinmonths>6 && ageinmonths <= 12){//6months - 1 age
       if(isgirl){
        targetkcalperkg = 79.0;
      }
      else{
        targetkcalperkg =80.0;
      }
      targetproteinperkg = 1.30;
      fatpercentage = 0.40;

    }
    else if(ageinmonths>12 && ageinmonths <= 24){//1-2 age
       if(isgirl){
        targetkcalperkg = 80.0;
      }
      else{
        targetkcalperkg =82.0;
      }
      targetproteinperkg = 1.14;
      fatpercentage = 0.35;
    }
    else if(ageinmonths>24 && ageinmonths <= 36){//2-3 age
       if(isgirl){
        targetkcalperkg = 81.0;
      }
      else{
        targetkcalperkg =84.0;
      }
      targetproteinperkg = 0.97;
      fatpercentage = 0.35;
    }
    else if(ageinmonths>36 && ageinmonths <= 48){//3-4 age
       if(isgirl){
        targetkcalperkg = 77.0;
      }
      else{
        targetkcalperkg =80.0;
      }
      targetproteinperkg = 0.90;
      fatpercentage = 0.30;
    }
    else{ //4-5 age interval
       if(isgirl){
        targetkcalperkg = 74.0;
      }
      else{
        targetkcalperkg =77.0;
      }
      targetproteinperkg = 0.86;
      fatpercentage = 0.30;
    }

    //total daily need calculation
    double totaltargetkcal = weightkg* targetkcalperkg; //total need kcal

    double totaltargetprotein = weightkg* targetproteinperkg;//total protein 
    double kcalfromprotein = totaltargetprotein *4.0;


    // 1g Carbs = 4 kcal, 1g Fat = 9 kcal
    //total fat gram-  X% of Total Calories / 9
    double kcalfromfat = totaltargetkcal*fatpercentage;
    double totaltargetfat = kcalfromfat/9;

    //carb gram - (Rest cal / 4)
    double kcalfromcarbs = totaltargetkcal - (kcalfromprotein + kcalfromfat);

    if(kcalfromcarbs<0) kcalfromcarbs = 0;
    double totaltargetcarbs = kcalfromcarbs/4.0;

    return {
      'kcal': totaltargetkcal.round(),
      'protein' : totaltargetprotein.round(),
      'carbs' : totaltargetcarbs.round(),
      'fat':totaltargetfat.round(),
    };


  }

  //calculation of weekly needs- use this in nutri sum card
  static Map<String,double>calculateweeklytargets(double weightkg, String birthdatestring, String gender){
    final dailyneed = calculatedailyneed(weightkg, birthdatestring, gender);

    double kcal = (dailyneed['kcal'] as num).toDouble();
    double protein = (dailyneed['protein'] as num).toDouble();
    double carbs = (dailyneed['carbs'] as num).toDouble();
    double fat =(dailyneed['fat'] as num).toDouble();

    return{
      'kcal': kcal*7,
      'protein' : protein*7,
      'carbs' : carbs*7,
      'fat':fat*7,
    };
  }
















}
