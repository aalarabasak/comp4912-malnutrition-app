import 'dart:math';//for min and max operations
import 'package:fl_chart/fl_chart.dart'; 


typedef Yresults = ({double miny, double maxy, double interval});

Yresults calculatedynamicYBounds(List<FlSpot> spots){
  //calculates y axis range and interval for set of spots and returns a record-miny, maxy,intervaly 

  if(spots.isEmpty){ //if the list is empty return default value to prevent crash-for insuracne
    return(miny:0, maxy : 1, interval:0.5 );
  }


  //find the min and max y values in the data, map> takes only y values, reduce-> finds min and max
  final originalminy = spots.map((e) => e.y).reduce(min);
  final originalmaxy = spots.map((e) => e.y).reduce(max);
  final range = originalmaxy-originalminy; //find the difference btw max and min

  double interval;
  //decide the interval size based on how big the range is
  if(range >= 20){
    interval = 5;//large 
  } 
  else if(range >= 10){
    interval = 2;//medium
  }
  else if(range >= 2){
    interval = 1; //small
  }
  else{
    interval = 0.5; //tiny
  }

  //Padding & Snapping
  //calculate minY and maxY with padding- formula: (Değer / Aralık).yuvarla() * Aralık
  var miny = ((originalminy - (interval * 0.5)) / interval).floor() * interval;
  var maxy = ((originalmaxy + (interval * 0.5)) / interval).ceil() * interval;
  //subtract -add half an interval so the line doesn't touch the edges, .floor rounds down, .ceil  rounds up to the grid lines

  if(miny < 0) miny = 0; //ensure miny is no negative

  if(miny == maxy){//gorce a range so the chart isn't a flat line in the middle of nowhere
    miny -= interval; // Extend down
    maxy += interval; // Extend up
    if (miny < 0) miny = 0; // Check negative again
  }


  return(miny:miny, maxy : maxy, interval:interval );



}

double calculatedynamicXInterval(int labelcount , {int targetlabelcount = 8}){
//calculates x axis interval, tries to keep roughly labels visible.
//labelcount->total number of data points, targetlabelcount->how many labels I want to see

//if no data return interval 1
  if (labelcount <= 0) return 1;

//if data count is small show all labels
  if (labelcount <= targetlabelcount) return 1;

//Calculate dynamic interval eg.> 100 days data / 5 target labels = label every 20 days
  return (labelcount / targetlabelcount).ceilToDouble();
}
