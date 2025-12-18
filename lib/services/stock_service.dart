import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';//for converting expiry date to string from datetime

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
    String formatteddate = DateFormat('dd/MM/yyyy').format(expirydate);//convert date to string

    QuerySnapshot? searchresult; //variable to store search result

    

      ///check if item exists in fb- find the document
      if(category == "RUTF"){

        searchresult = await stockreference.where('lotNumber', isEqualTo: lotnumber).limit(1).get();
        //look for the lot number bcs in rutf packages lotnumber is unique
      }
      else{
        //bcs supplements dont have lot num -> look for product name
        searchresult = await stockreference.where('productName', isEqualTo: productname)
          .where('category', isEqualTo: 'Supplement').limit(1).get();

      }

      ///decide what to do below: update or add
      if(searchresult.docs.isNotEmpty){
        //here-> if item found,lockit and update it with transaction

        DocumentReference documentReference = searchresult.docs.first.reference;

        //atomic transaction starts here
        await firestore.runTransaction((transaction) async {
          //read the document again inside the transaction to ensure get the latest data
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
        //bcs its a new item, there is no  race condition.

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