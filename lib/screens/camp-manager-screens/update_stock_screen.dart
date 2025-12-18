import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Stockcategory {rutf, supplement} //for segmented button widget

class UpdateStockScreen extends StatefulWidget{
  const UpdateStockScreen({super.key});

  @override
  State<UpdateStockScreen> createState() => UpdateStockScreenState();
}

class UpdateStockScreenState extends State<UpdateStockScreen>{

  Set<Stockcategory> selectedview = {Stockcategory.rutf}; //by default it is arranged as rutf

  // Controllers
  final TextEditingController supplementnamecontroller = TextEditingController();
  final TextEditingController lotnumbercontroller = TextEditingController();
  final TextEditingController quantitycontroller = TextEditingController();
  final TextEditingController expirydatecontroller = TextEditingController();

  //will be deleted later, needs to be get from firebase
  final List<String> rutfOptions = [
    "Plumpy'Nut",
    "Valid P-RUTF",
    "eeZeePaste NUT",
  ];

  String? selectedrutfname; //chosen from dropdown menu
  DateTime? selecteddate;//chosen expiry date for rutf

  @override
  void dispose() {
    supplementnamecontroller.dispose();
    lotnumbercontroller.dispose();
    quantitycontroller.dispose();
    expirydatecontroller.dispose();
    super.dispose();
  }

  //for date picker logic for expiration date field for only RUTF 
  Future<void> pickexpirydate(BuildContext context) async{

    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), 
      lastDate: DateTime.now().add(const Duration(days: 400)),
      
    );

    if (picked != null) {
      setState(() {
        selecteddate = picked;
        expirydatecontroller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }
  
  void savestock(){


  }

  @override
  Widget build(BuildContext context){

    bool isrutfmode = false;
    if(selectedview.first == Stockcategory.rutf){
      isrutfmode = true;
    }

    return Scaffold(
      appBar: AppBar(
      title: Icon(Icons.monitor_heart_outlined, color: Colors.black,),
        centerTitle: true,

      backgroundColor: Colors.transparent, 
      automaticallyImplyLeading: false, //avoid the presence of back button
    ),

    body: GestureDetector(
      onTap: () {
        //If click on an empty space on the screen close the keyboard
        FocusScope.of(context).unfocus();
      },
    child:SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
            
            child: Column(
              

              children: [

                
                const SizedBox(height: 8),

                //segmented buttonn
                SizedBox(
                  width: double.infinity,
                  //I got the segmentenbutton code from below link:
                  //https://api.flutter.dev/flutter/material/SegmentedButton-class.html
                  child: SegmentedButton<Stockcategory>(
                    showSelectedIcon: false,
                    multiSelectionEnabled: false,
                    emptySelectionAllowed: false,
                    segments: const <ButtonSegment<Stockcategory>>[
                      ButtonSegment<Stockcategory>(
                        value: Stockcategory.rutf,
                        label: Text("RUTF Items"),
                        icon: Icon(Icons.medical_services_outlined),
                      ),
                      ButtonSegment<Stockcategory>(
                        value: Stockcategory.supplement,
                        label: Text("Supplements"),
                        icon: Icon(Icons.apple, color: Color.fromARGB(255, 84, 84, 84),),
                      ),
                    ],

                    selected: selectedview,
                    onSelectionChanged: (Set<Stockcategory> newselection) {
                      setState(() {
                        selectedview = newselection;
                        lotnumbercontroller.clear();
                        expirydatecontroller.clear();
                        supplementnamecontroller.clear();
                        quantitycontroller.clear();
                        selectedrutfname = null;
                      });
                    },

                    style: ButtonStyle(
                      //I got the below code from below link for changing background of selection color
                      //https://stackoverflow.com/questions/75271399/how-to-control-selected-and-unselected-background-color-for-the-segmentedbutton
                      backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return const Color.fromARGB(255, 229, 142, 171).withOpacity(0.5); //pink theme color
                      }
                      return null;//if it is not selected, then default one
                    }),
                    ),
                  ),
                ),
               
                
                const SizedBox(height: 30),
                
                //dynamic form
                Container(
                  padding:const EdgeInsets.all(20) ,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5)
                      )
                    ]
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,


                    children: [
                      //title of the container based on segmented button selection
                      Text(
                        isrutfmode ? "RUTF Details" : "Supplement Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                    const Divider(),
                    const SizedBox(height: 15),

                    //product name
                    if(isrutfmode)...[
                      DropdownButtonFormField<String>(
                        value: selectedrutfname,
                        decoration: inputdecoration("Select RUTF Product", Icons.medical_services),
                        items: rutfOptions.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                        onChanged:(value) {
                          setState(() {
                            selectedrutfname = value;
                          });
                        },
                      )
                    ]
                    else...[
                      TextFormField(
                        controller: supplementnamecontroller,
                        decoration: inputdecoration("Supplement Name", Icons.fastfood),
                      )
                    ],

                    const SizedBox(height: 20),

                    //quantity -same in both selections
                    TextFormField(
                      controller: quantitycontroller,
                      keyboardType: TextInputType.number,
                      decoration: inputdecoration("Quantity", Icons.layers),
                    ),

                    const SizedBox(height: 20),

                    //conditional field
                    if(isrutfmode)...[
                      //lot nuumber field
                      TextFormField(
                        controller: lotnumbercontroller,
                        decoration: inputdecoration("Lot Number", Icons.qr_code),
                      ),
                      const SizedBox(height: 20),

                      //expiration date
                      TextFormField(
                        controller: expirydatecontroller,
                        readOnly: true,
                        onTap: () => pickexpirydate(context),
                        decoration: inputdecoration("Expiration Date", Icons.calendar_today),
                      )
                    ],


                    ],
                  ),
                ),

                const SizedBox(height: 30),

                //buttons row
                Row(
                  children: [
                    //cancel button
                    Expanded(child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 176, 174, 174),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        )
                      ),
                      onPressed:() {
                        Navigator.of(context).pop(); //closes the current screen and returns  to the previous screen.
                      }, 
                      child: const Text('Cancel')),
                      ),

                      const SizedBox(width: 20),

                      //save button
                      Expanded(child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 229, 142, 171).withOpacity(0.8), // Pink Theme
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )
                        ),
                        onPressed:() {
                          savestock();
                        }, 
                        child: const Text("Save")),
                      ),
                  ],
                )



              ],
            )
          
        )
        )
     
    );
  }

  InputDecoration inputdecoration(String label, IconData icon){
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade600,),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey.shade50,

    );
  }
}