import 'dart:math';//for min and max operations
import 'package:fl_chart/fl_chart.dart'; 


typedef Yresults = ({double miny, double maxy, double interval});

Yresults calculatedynamicYBounds(List<FlSpot> spots){
  //calculates y axis range and interval 

  if(spots.isEmpty){ 
    return(miny:0, maxy : 1, interval:0.5 );
  }


  //find the min and max y values in the data, map> takes only y values, reduce-> finds min and max
  final originalminy = spots.map((e) => e.y).reduce(min);
  final originalmaxy = spots.map((e) => e.y).reduce(max);
  final range = originalmaxy-originalminy; 

  double interval;
  //decide the interval size 
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

  
  //calculate minY and maxY 
  var miny = ((originalminy - (interval * 0.5)) / interval).floor() * interval;
  var maxy = ((originalmaxy + (interval * 0.5)) / interval).ceil() * interval;
 

  if(miny < 0) miny = 0; //ensure miny is no negative

  if(miny == maxy){
    miny -= interval; // Extend down
    maxy += interval; // Extend up
    if (miny < 0) miny = 0; 
  }


  return(miny:miny, maxy : maxy, interval:interval );



}

double calculatedynamicXInterval(int labelcount , {int targetlabelcount = 8}){
//calculates x axis interval


//if no data return interval 1
  if (labelcount <= 0) return 1;

//if data count is small show all labels
  if (labelcount <= targetlabelcount) return 1;

//return with calculate
  return (labelcount / targetlabelcount).ceilToDouble();
}
