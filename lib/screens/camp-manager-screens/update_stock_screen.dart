import 'package:flutter/material.dart';

class UpdateStockScreen extends StatefulWidget{
  const UpdateStockScreen({super.key});

  @override
  State<UpdateStockScreen> createState() => UpdateStockScreenState();
}

class UpdateStockScreenState extends State<UpdateStockScreen>{

  final formkey = GlobalKey<FormState>(); //to control form state of each box

  // Controllers
  final TextEditingController productnamecontroller = TextEditingController();
  final TextEditingController lotnumbercontroller = TextEditingController();
  final TextEditingController quantitycontroller = TextEditingController();
  final TextEditingController expirydatecontroller = TextEditingController();

  @override
  void dispose() {
    productnamecontroller.dispose();
    lotnumbercontroller.dispose();
    quantitycontroller.dispose();
    expirydatecontroller.dispose();
    super.dispose();
  }

  //for date picker logic for expiration date field
  Future<void> pickexpirydate() async{

    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), 
      lastDate: DateTime.now().add(const Duration(days: 400)),
      
    );

    if (picked != null) {
      setState(() {
        expirydatecontroller.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }
  

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
      title: Icon(Icons.monitor_heart_outlined, color: Colors.black,),
        centerTitle: true,

      backgroundColor: Colors.transparent, 
      automaticallyImplyLeading: false, //avoid the presence of back button
    ),

    body: GestureDetector(
      onTap: () {
        //  to hide the keyboard
          // It removes focus from the currently active text field
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 50),
                //title
                Text('Please fill in the details below.',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold,)),

                const SizedBox(height: 40),

                //the big container
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                  ),

                  child: Column(
                    children: [

                      //1st input field-product name
                      TextFormField(
                        controller: productnamecontroller,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          labelStyle: TextStyle(fontSize: 14),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label_outline)
                        ),

                        validator: (value) => value!.isEmpty ? 'Required field.' : null,
                      ),

                      const SizedBox(height: 30),

                      //2nd lot number
                      TextFormField(
                        controller: productnamecontroller,
                        decoration: InputDecoration(
                          labelText: 'Lot Number',
                          labelStyle: TextStyle(fontSize: 14),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.qr_code)
                        ),

                        validator: (value) => value!.isEmpty ? 'Required field.' : null,
                      ),

                      const SizedBox(height: 30),

                      //3rd quantity
                      TextFormField(
                          controller: quantitycontroller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            labelStyle: TextStyle(fontSize: 14),
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.add_shopping_cart),
                          ),
                          validator: (value) {
                            //check control
                            if (value == null || value.isEmpty) return 'Required field.';
                            if (int.tryParse(value) == null) return 'Invalid number.';
                            return null;
                          },
                        ),

                      const SizedBox(height: 30),

                      //4th expiration date
                      TextFormField(
                        controller: expirydatecontroller,
                        readOnly: true,
                        onTap: pickexpirydate,
                        decoration: InputDecoration(
                          labelText: 'Expiration Date',
                          labelStyle: TextStyle(fontSize: 14),
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_month_outlined),
                            hintText: 'Tap to select date..',
                        ),
                        validator: (value) => value!.isEmpty ? 'Required field.' : null,
                      ),

                      
                    ],
                  ),
                ),

                const SizedBox(height: 50),

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
                          //will be updated!!1
                        }, 
                        child: const Text('Save')),
                      ),
                  ],
                )



              ],
            )
          ),
        )
      ),
    ),
    );
  }
}