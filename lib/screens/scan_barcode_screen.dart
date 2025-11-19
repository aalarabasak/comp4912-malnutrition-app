import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanBarcodeScreen extends StatefulWidget{
  const ScanBarcodeScreen({super.key});

  @override
  State<ScanBarcodeScreen> createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen>{

  // Initialize the MobileScannerController to manage the camera and scanning process.
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal, //speed of the barcode
    facing: CameraFacing.back, //use back camera
    formats: [BarcodeFormat.ean13, BarcodeFormat.upcA], //barcode types
  );

  // This method is called when the widget is removed from the widget tree.
  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  // A callback function executed when a barcode is successfully detected.
  void _onDetect_barcode(BarcodeCapture barcodeCapture){
    //will be updated!!!!1
    final barcodeValue = barcodeCapture.barcodes.isNotEmpty 
        ? barcodeCapture.barcodes.first.rawValue 
        : 'None';
    print("Barkod Algılandı: $barcodeValue. 20 Kasım'da işlenecek.");
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
            onDetect: _onDetect_barcode,
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