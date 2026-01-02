import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StockService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addorUpdatestock({
    required String category,// "RUTF" or "Supplement"
    required String productname,
    required int quantity,
    String? lotnumber,// nullable bcs supplements dont have 
    required DateTime expirydate,
  }) async{

    CollectionReference stockreference = firestore.collection('stocks');//reference to the stock collection in fb
    String formatteddate = DateFormat('dd/MM/yyyy').format(expirydate);

    QuerySnapshot? searchresult; //store search result

    

      ///check if item exists 
      if(category == "RUTF"){

        searchresult = await stockreference.where('lotNumber', isEqualTo: lotnumber).limit(1).get();
        
      }
      else{
        
        searchresult = await stockreference.where('productName', isEqualTo: productname)
          .where('category', isEqualTo: 'Supplement').limit(1).get();

      }

      ///decide what to do below: update or add
      if(searchresult.docs.isNotEmpty){
        //item found,lockit and update it with transaction

        DocumentReference documentReference = searchresult.docs.first.reference;

        //atomic 
        await firestore.runTransaction((transaction) async {
          
          DocumentSnapshot latestsnapshot = await transaction.get(documentReference);//lock the document

          if(!latestsnapshot.exists){
            throw Exception("Document does not exist");
          }

          //get the current quantity from the locked doc
          int currentquantity = latestsnapshot['quantity'];
          int newquantity = currentquantity + quantity;

          //Write
          transaction.update(documentReference, {
            'quantity': newquantity,
            'expirationDate': formatteddate, 
            'updatedAt': FieldValue.serverTimestamp(),
            });
        });
        

      }
      else{
        //item does not exist -> creatte new
      

        await stockreference.add({
        'category': category,
        'productName': productname,
        'quantity': quantity,
        'lotNumber': lotnumber,
        'expirationDate': formatteddate,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      }
      
    








  }

}