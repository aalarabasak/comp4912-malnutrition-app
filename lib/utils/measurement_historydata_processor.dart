import 'package:fl_chart/fl_chart.dart';//charts
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';//date formatting
import 'package:malnutrition_app/utils/formatting_helpers.dart';

class ProcessedMeasurementData {//// Class to store all the final data needed for the charts and ui
  
  //lists of points for the charts
  final List<FlSpot> muacSpots;
  final List<FlSpot> weightSpots;
  final List<FlSpot> heightSpots; 
  //list of date strings for x axis->
  final List<String> dateLabels;
  //for statistic cards for each measurement-> muac weight and height
  final MuacStatistics muacStats;
  final WeightStatistics weightStats;
  final HeightStatistics heightStats;

  ProcessedMeasurementData({//constructor
    required this.muacSpots,
    required this.weightSpots,
    required this.heightSpots,
    required this.dateLabels,
    required this.muacStats,
    required this.weightStats,
    required this.heightStats,

  });
}

// Simple class to hold  strings for muac stats
class MuacStatistics {
  final String current;
  final String average;
  final String min;
  final String max;

  MuacStatistics({
    required this.current,
    required this.average,
    required this.min,
    required this.max,
  });
}

class WeightStatistics {//Simple class to hold  strings for weight stats
  final String current;
  final String change;//// Difference between first and last measurement
  final String min;
  final String max;

  WeightStatistics({
    required this.current,
    required this.change,
    required this.min,
    required this.max,
  });
}


class HeightStatistics {///simple class to hold  strings for weight stats
  final String current;
  final String totalGrowth;
  final String avgGrowthRate;
  final String max;

  HeightStatistics({
    required this.current,
    required this.totalGrowth,
    required this.avgGrowthRate,
    required this.max,
  });
}

// type definiton for stat calculation results 
typedef StatCalculationResults = ({double min,double max,double current,double average,double change});


class MeasurementDataProcessor {
  
  //converts Firebase documents into chart data
  static ProcessedMeasurementData processMeasurements(List<QueryDocumentSnapshot> docs) {

    List<Map<String, dynamic>> processedData = [];//create a empty list to store formatted  data

    for (var doc in docs) {//loop through each document from Firebase

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;//get data as a Map
      DateTime measurementDate = parseDateString(data['dateofMeasurement']);//convert the string date to a DateTime
      //save the parsed date back into the map for sorting
      data['parseddate'] = measurementDate;
      processedData.add(data);
    }

    //sort date from old to new
    processedData.sort((a, b) => (a['parseddate'] as DateTime).compareTo(b['parseddate'] as DateTime));

   //lists to hold the points for drawing charts
    List<FlSpot> muacSpots = [];
    List<FlSpot> weightSpots = [];
    List<FlSpot> heightSpots = [];
    List<String> dateLabels = [];

    for (int i = 0; i < processedData.length; i++) {//loop through sorted data to create chart points
      var data = processedData[i];

      // Format date label -e.g. Nov 26
      String label = DateFormat("MMM d").format(data['parseddate']);
      dateLabels.add(label);

      //extract and convert measurement values to doubles
      double muacVal = double.tryParse(data['muac'].toString()) ?? 0;
      double weightVal = double.tryParse(data['weight'].toString()) ?? 0;
      double heightVal = double.tryParse(data['height'].toString()) ?? 0;
      //create spots- x is the index  y is the value
      muacSpots.add(FlSpot(i.toDouble(), muacVal));
      weightSpots.add(FlSpot(i.toDouble(), weightVal));
      heightSpots.add(FlSpot(i.toDouble(), heightVal));
    }

    //calculate statistics for each  type
    MuacStatistics muacStats = _calculateMuacStatistics(muacSpots);
    WeightStatistics weightStats = _calculateWeightStatistics(weightSpots);
    HeightStatistics heightStats =_calculateHeightStatistics(heightSpots, processedData);

    return ProcessedMeasurementData(//return thr result
      muacSpots: muacSpots,
      weightSpots: weightSpots,
      heightSpots: heightSpots,
      dateLabels: dateLabels,
      muacStats: muacStats,
      weightStats: weightStats,
      heightStats: heightStats,
    );
  }

  //core statistics calculation- min,max,current,average, change
  static StatCalculationResults _calculateStats(List<FlSpot> spots) {

    if (spots.isEmpty) {
      //return zeros if empty-control
      return (min: 0.0, max: 0.0, current: 0.0, average: 0.0, change: 0.0);
    }

    List<double> values = [];//create empty list to fill later in for below block
    for (var spot in spots) {//extract just the y values
      values.add(spot.y);
    }

    double currentVal = values.last; //last data
    double firstVal = values.first;//first measuremnt data
    double changeInTotal = currentVal - firstVal;//difference bte the last and first mesurement

    values.sort();//sort values to easily find min and max
    double minVal = values.first;
    double maxVal = values.last;

    // Calculate average- 1st find sum
    double sum = 0;
    for (var value in values) {
      sum += value;
    }
    //2nd later divide by length for avg calc.
    double avg = sum / values.length;

    return (min: minVal,max: maxVal,current: currentVal,average: avg,change: changeInTotal
    );
  }

  //calculation statistics for muac 
  static MuacStatistics _calculateMuacStatistics(List<FlSpot> spots) {
    if (spots.isEmpty) {
      return MuacStatistics(
        current: "-",
        average: "-",
        min: "-",
        max: "-",
      );
    }

    var stats = _calculateStats(spots);//calculate statistic metrics
  
    return MuacStatistics(
      current: "${stats.current.toStringAsFixed(1)} mm",
      min: "${stats.min.toStringAsFixed(1)} mm",
      max: "${stats.max.toStringAsFixed(1)} mm",
      average: "${stats.average.toStringAsFixed(1)} mm",

    );
  }

  // formating change value with + or - sign and unit
  static String _formatChange(double change, String unit) {
    if (change >= 0) {
      return "+${change.toStringAsFixed(1)} $unit";
    } 
    else {
      return "${change.toStringAsFixed(1)} $unit";
    }
  }

  //calculate wight stats
  static WeightStatistics _calculateWeightStatistics(List<FlSpot> spots) {
    if (spots.isEmpty) {
      return WeightStatistics(
        current: "-",
        change: "-",
        min: "-",
        max: "-",
      );
    }

    var stats = _calculateStats(spots);
    String change = _formatChange(stats.change, "kg");//format the change as +.. or -..

    return WeightStatistics(
      current: "${stats.current.toStringAsFixed(1)} kg",
      min: "${stats.min.toStringAsFixed(1)} kg",
      max: "${stats.max.toStringAsFixed(1)} kg",
      change: change,

    );
  }



  //calculation height  statistics 
  static HeightStatistics _calculateHeightStatistics(List<FlSpot> spots, List<Map<String, dynamic>> processedData) {
    if (spots.isEmpty) {
      return HeightStatistics(
        current: "-",
        totalGrowth: "-",
        avgGrowthRate: "-",
        max: "-",
      );
    }

    var stats = _calculateStats(spots);//get metrics

    String totalGrowth = _formatChange(stats.change, "cm");
    String avgGrowthRate = _calculateAvgGrowthRate(stats.change, processedData); //calculate growth speed cm per month

    return HeightStatistics(

      current: "${stats.current.toStringAsFixed(1)} cm",
      max: "${stats.max.toStringAsFixed(1)} cm",
      totalGrowth: totalGrowth,
      avgGrowthRate: avgGrowthRate,
    );
  }



  //calculates average growth rate for height 
  static String _calculateAvgGrowthRate(double change, List<Map<String, dynamic>> processedData) {
    if (processedData.length < 2) {
      return "-";//need at least 2 data points to calculate rate
    }

    DateTime firstDate = processedData.first['parseddate'];
    DateTime lastDate = processedData.last['parseddate'];
    int daysDifference = lastDate.difference(firstDate).inDays;//get time difference btw first and last measurement

    if (daysDifference <= 0) {
      return "-";
    }
    //convert days to months->
    double monthsPassed = daysDifference / 30.0; // 30 days = 1 month
    double calculatedRate;

    if (monthsPassed < 1.0) {
      // If less than a month, display direct change to avoid misleading
      calculatedRate = change;
    } else {
      // Otherwise divide by months
      calculatedRate = change / monthsPassed;
    }

    return "+${calculatedRate.toStringAsFixed(1)} cm/mo";
  }
}

