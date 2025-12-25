import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/stock_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Stockcategory {rutf, supplement} //for segmented button widget

class UpdateStockScreen extends StatefulWidget{
  const UpdateStockScreen({super.key});

  @override
  State<UpdateStockScreen> createState() => UpdateStockScreenState();
}

class UpdateStockScreenState extends State<UpdateStockScreen>{

  final StockService stockservice = StockService();//call the service 

  Set<Stockcategory> selectedview = {Stockcategory.rutf}; //by default it is arranged as rutf

  // Controllers
  final TextEditingController supplementnamecontroller = TextEditingController();
  final TextEditingController lotnumbercontroller = TextEditingController();
  final TextEditingController quantitycontroller = TextEditingController();
  final TextEditingController expirydatecontroller = TextEditingController();

  List<String> rutfoptions =[];


  
  String? selectedrutfname; //chosen from dropdown menu
  DateTime? selecteddate;//chosen expiry date for rutf

  @override
  void initState(){
    super.initState();
    getrutfnames();
  }

  Future<void> getrutfnames() async{
   
   QuerySnapshot snapshot =await FirebaseFirestore.instance.collection('RUTF_products').get();

   //get inside to every document in the snapshot and get only name fields and make it a list
   List<String> names = snapshot.docs.map((doc) {
    return doc['name'] as String;
   }).toList();

   if(mounted){
    setState(() {
      rutfoptions = names;
    });
   }
  }

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

  Future <void> savestock() async{

    if(quantitycontroller.text.isEmpty){//control
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter quantity!")));
      return;
    }

    //prepare datas
    Stockcategory currentcategory = selectedview.first;
    String categorystring;
    String productname;
    String? lotnumber;
    DateTime expirydate;

    if (currentcategory == Stockcategory.rutf) {

      if (selectedrutfname == null || lotnumbercontroller.text.isEmpty || selecteddate == null) {//if the are empty
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all RUTF fields!")));
         //show warning message
         return;
      }

      categorystring = "RUTF";
      productname = selectedrutfname!;
      lotnumber = lotnumbercontroller.text;
      expirydate = selecteddate!;

    } 
    else {
      //supplement part
      if (supplementnamecontroller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter supplement name!")));
        return;
      }

      categorystring = "Supplement";
      productname = supplementnamecontroller.text;
      lotnumber = null;
      expirydate = DateTime.now().add(const Duration(days: 14)); 
    }


    //saving to firestore part by using stock_service.dart
    try{
      int quantity = int.parse(quantitycontroller.text);

      //send to  service
      await stockservice.addorUpdatestock(
        category: categorystring, 
        productname: productname, 
        quantity: quantity, 
        expirydate: expirydate,
        lotnumber: lotnumber,
      );

      if (mounted) {
        //give success feedback
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Saved $productname!"),
          backgroundColor: Colors.green,
        ));
    
        Navigator.pop(context); //close the screen
      }
    } catch (e) {

      //if there is a error show failed message
      if (mounted) {


        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Something is wrong "),
          backgroundColor: Colors.red,
        ));
      }
    }
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
                      ),
                      ButtonSegment<Stockcategory>(
                        value: Stockcategory.supplement,
                        label: Text("Supplements"),
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
                        items: rutfoptions.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
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
                          borderRadius: BorderRadius.circular(20),
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
                            borderRadius: BorderRadius.circular(20),
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