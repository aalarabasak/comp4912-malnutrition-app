import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'meal_confirmation_screen_packaged.dart';
import 'dart:async'; //for timer




class ScanBarcodeScreen extends StatefulWidget{
  final String childId;
  const ScanBarcodeScreen({super.key, required this.childId});

  @override
  State<ScanBarcodeScreen> createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen>{

  Timer? _timer;

  //initialize the MobileScannerController 
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal, //speed of the barcode
    facing: CameraFacing.back, //use back camera
    formats: [BarcodeFormat.ean13, BarcodeFormat.upcA], //barcode types
  );

  //starts timer
  @override
  void initState(){
    super.initState();
    startTimer();
  }


  @override
  void dispose(){
    _timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  //runs when a barcode is detected
  void onDetect_barcode(BarcodeCapture barcodeCapture){
    final List<Barcode> barcodes = barcodeCapture.barcodes;

    if(!mounted) return; 

    if(barcodes.isNotEmpty){
      final String? barcode_value = barcodes.first.rawValue;
      if(barcode_value != null && barcode_value.isNotEmpty){ //looks at if the string has characters or not 
                                                           
        _timer?.cancel();
        debugPrint('DEBUG: Successfully Scanned ID: $barcode_value');
        controller.stop(); //stop the scanner 

        //navigate to the confirmation page
         Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => MealConfirmationScreenPackaged(barcodeId: barcode_value, childid: widget.childId,)));
      }
      else{
        showError(); //barcode not detected
      }

    }

  }
  //give a timeout error after 10 seconds
  void startTimer(){
    _timer = Timer(Duration(seconds: 10), () {
      if(mounted){
        showError();
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
      body: Stack( 
        children: [

          MobileScanner(// camera view widget
            controller: controller,
            onDetect: onDetect_barcode,
          ),

          Center( //
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8, 
              height: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white, 
                  width: 4.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),

            ),
          ),

         
          Positioned(
            bottom: 100, 
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
