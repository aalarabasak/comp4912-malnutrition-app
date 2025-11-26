
//used in child_profile_screen.dart, 
String calculateAge(String birthdatestring){

      final parts = birthdatestring.split('/');
      

      final int day = int.parse(parts[0]);
      final int month = int.parse(parts[1]);
      final int year = int.parse(parts[2]);

      final DateTime birthDate = DateTime(year, month, day);

      //I got this piece of code from the link below:
      //https://viveky259259.medium.com/age-calculator-in-flutter-97853dc8486f
      final DateTime currentDate = DateTime.now();
      int age = currentDate.year - birthDate.year;
      int month1 = currentDate.month;
      int month2 = birthDate.month;

      if (month2 > month1) {
        age--;
      } else if (month1 == month2) {
        int day1 = currentDate.day;
        int day2 = birthDate.day;
        if (day2 > day1) {
          age--;
        }
      }

      return "$age years";
}

//used in risk_status_card.dart, risk_calculator.dart
DateTime parseDateString(String datestring){
    List <String> parts = datestring.split('/');

    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    return DateTime(year, month, day);
  
}

