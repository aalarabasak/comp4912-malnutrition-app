import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'meal_confirmation_screen_packaged.dart';
import 'dart:async'; //for timer

//// Uses mobile_scanner package: https://pub.dev/packages/mobile_scanner
///https://stackoverflow.com/questions/78805452/how-to-create-a-barcode-scanner-in-flutter-that-displays-a-sticky-square-around


class ScanBarcodeScreen extends StatefulWidget{
  const ScanBarcodeScreen({super.key});

  @override
  State<ScanBarcodeScreen> createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen>{

  Timer? _timer;

  // Initialize the MobileScannerController to manage the camera and scanning process.
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal, //speed of the barcode
    facing: CameraFacing.back, //use back camera
    formats: [BarcodeFormat.ean13, BarcodeFormat.upcA], //barcode types
  );

  //this method is for starting timer
  @override
  void initState(){
    super.initState();
    startTimer();
  }

  // This method is called when the widget is removed from the widget tree.
  @override
  void dispose(){
    _timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  // A callback function executed when a barcode is successfully detected.
  void onDetect_barcode(BarcodeCapture barcodeCapture){
    final List<Barcode> barcodes = barcodeCapture.barcodes;

    if(!mounted) return; //check if the widget is still on the screen

    if(barcodes.isNotEmpty){
      final String? barcode_value = barcodes.first.rawValue;
      if(barcode_value != null && barcode_value.isNotEmpty){ //isnotempty looks at if the string has characters or not 
                                                            // if it is like this " " , this cannot be accepted.
        _timer?.cancel();
        print('DEBUG: Successfully Scanned ID: $barcode_value');
        controller.stop(); //stop the scanner because barcode is detected

        //navigate to the confirmation page
         Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => MealConfirmationScreenPackaged(barcodeId: barcode_value)));
      }
      else{
        showError(); //show error because barcode could not be recognized. 
      }

    }

  }
  //It will give a timeout error after 10 seconds.
  void startTimer(){
    _timer = Timer(Duration(seconds: 10), () {
      if(mounted){
        showError();//show the error because of time is up.
      }
    });
  }


  void showError(){
    controller.stop(); //stop camera
    showDialog( //show feedback
          context: context, 
          builder: (BuildContext dialogcontext){
            return AlertDialog(
              title: Text('Scan Failed'),
              content: Text('Please try again.'),
              actions: <Widget>[
                TextButton(
                  onPressed:() {
                    Navigator.of(dialogcontext).pop(); //close the dialog
                    startTimer(); //set timer again
                    controller.start(); //start the scanner again
                  }, 
                  child: Text('Scan Again'))
              ],
            );
          });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Barcode'),
        backgroundColor: Colors.redAccent,
      ),
      body: Stack( // The body uses a Stack to layer widgets on top of each other.
        children: [

          MobileScanner(// This is the camera view widget
            controller: controller,
            onDetect: onDetect_barcode,
          ),

          Center( // Center the scanning frame on the screen.
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8, //this is the width of the square
              height: MediaQuery.of(context).size.width * 0.4,//this is the height of the square
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white, //this is the frame line color
                  width: 4.0,//this is the thickness of the line
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),

            ),
          ),

          //this is for bottom text -help text to user-
          Positioned(
            bottom: 100, // Position 100 pixels from the bottom edge.
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Position the barcode within the frame', 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
