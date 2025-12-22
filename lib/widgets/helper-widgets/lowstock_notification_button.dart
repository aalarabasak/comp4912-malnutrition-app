import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LowstockNotificationButton extends StatelessWidget{
  const LowstockNotificationButton({super.key});

  //helper function to specify status column in list
  String getstockstatus(int quantity){
    
    if(quantity <50) return "Low";
    if (quantity < 200) return "Medium";
    return "Normal";
  } 

  @override
  Widget build(BuildContext context){
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('stocks').where('quantity', isGreaterThan: 0).snapshots(),

      builder:(context, snapshot) {
        
        if(!snapshot.hasData){
          return const Icon(Icons.notifications_outlined, color: Colors.grey);

        }

        var docs = snapshot.data!.docs;

        final lowstockitems = docs.where((doc) {
          var data = doc.data();
          int amount = data['quantity'];
          return getstockstatus(amount) == "Low";
        }).toList();

        int lowstockcount= lowstockitems.length;

        return IconButton(
          onPressed:() {
            showlowstockalert(context, lowstockitems);
          }, 
          icon: Badge(//used badge class https://api.flutter.dev/flutter/material/Badge-class.html
            isLabelVisible: lowstockcount>0,
            label: Text("$lowstockcount"),//above badge number shows how many items in low stock
            backgroundColor: Colors.red,
            child: const Icon(Icons.notifications_outlined, color: Colors.black, size: 28,),
          )
        );
      },
    );
  }

  void showlowstockalert(BuildContext context, List<QueryDocumentSnapshot> lowstockitems){

    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(

          title: Row(
            //warning icon and title
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text("Low Stock Alert"),
            ],
          ),

          content: SizedBox(
            width: double.maxFinite,

            child: lowstockitems.isEmpty 
            ?  Text("All stocks are at normal levels.")
            : ListView.builder(
              shrinkWrap: true,
              itemCount: lowstockitems.length,
              itemBuilder:(context, index) {
                var data = lowstockitems[index].data() as Map<String,dynamic>;

                String name= data['productName'];
                String category= data['category'];
                int quantity = data['quantity'];
                String lot ="";
                if(category == "Supplement"){
                  lot = "-";
                }
                else{
                  lot= data['lotNumber'];
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.circle, size: 10, color: Colors.red),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text("Lot: $lot  |  Quantity: $quantity"),
                );

                
              },
            )
          ),
          //ok cancel button
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}