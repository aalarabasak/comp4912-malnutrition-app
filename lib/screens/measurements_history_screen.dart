import 'package:flutter/material.dart';

enum MeasurementType {muac, weight, height, edema }//a simple enum to manage measurement types

class MeasurementsHistoryScreen extends StatefulWidget{
  final String childid;
  const MeasurementsHistoryScreen({super.key, required this.childid});

  @override
  State <MeasurementsHistoryScreen> createState() => MeasurementsHistoryScreenState();
}

class MeasurementsHistoryScreenState extends State <MeasurementsHistoryScreen>{
  
  MeasurementType selectedtype = MeasurementType.muac;//initial selection is muac

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('History & Analysis', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 19),),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              //I got the segmentenbutton code from below link (segments, selected, onselectionchanged):
              //https://api.flutter.dev/flutter/material/SegmentedButton-class.html
              SegmentedButton <MeasurementType>(
                showSelectedIcon: false, //remove selection icon
                segments:  <ButtonSegment<MeasurementType>>[
                  ButtonSegment<MeasurementType>(
                    value: MeasurementType.muac,
                    label: Text('MUAC'),
                  ),
                  ButtonSegment<MeasurementType>(
                    value: MeasurementType.weight,
                    label: Text('Weight'),
                  ),
                  ButtonSegment<MeasurementType>(
                    value: MeasurementType.height,
                    label: Text('Height'),
                  ),
                  ButtonSegment<MeasurementType>(
                    value: MeasurementType.edema,
                    label: Text('Edema'),
                  )
                  
                ],
                selected: <MeasurementType> {selectedtype}, //which one is chosen now

                //what happen if change happen
                onSelectionChanged:(Set<MeasurementType> newSelection) {
                  setState(() {//get the first and only element in the set
                    selectedtype = newSelection.first;
                  });
                  
                },

                //I got the below code from below link for changing background of selection color
                //https://stackoverflow.com/questions/75271399/how-to-control-selected-and-unselected-background-color-for-the-segmentedbutton
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return const Color.fromARGB(255, 229, 142, 171);
                    }
                    return Colors.white; 
                  },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 80, color: Colors.grey.withOpacity(0.3)),
                      const SizedBox(height: 10),
                      Text(

                        "${selectedtype.name.toUpperCase()} Chart Area",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.withOpacity(0.5),
                            fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        "(We will build this in Step 2)",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              )
            ],
          ),
          ),
      ),
    );
  }
}
