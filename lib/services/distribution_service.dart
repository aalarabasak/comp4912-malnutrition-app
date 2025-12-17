import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malnutrition_app/utils/formatting_helpers.dart';


class DistributionService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> recorddistribution({
    required String childId,
    required String childname,
    required String productName,
    required int quantity,
  }) async{

    //find the product in stocks
    //query only by productName to avoid needing composite index, filter quantity in memory
    final stockquery = await firestore.collection('stocks')
      .where('productName', isEqualTo: productName)
      .get();
    
    //filter out stocks with quantity <= 0 in memory (avoids needing composite index)
    List<QueryDocumentSnapshot> availableStocks = stockquery.docs
      .where((doc) => (doc['quantity'] as int) > 0)
      .toList();
    
    if (availableStocks.isEmpty) {
      
      throw Exception("$productName not found is out of stock!");
    }

    //find the most suitable lot (FIFO - First In First Out)
     //list the documents and sort them by date
    List<QueryDocumentSnapshot> sortedstocks = availableStocks;

    sortedstocks.sort((a,b) {
      //convert dates from string to datetime object
      DateTime dateA = parseDateString(a['expirationDate']);
      DateTime dateB = parseDateString(b['expirationDate']);
      return dateA.compareTo(dateB);

    });

    DocumentSnapshot? targetstockdoc;//Find the stock that is available to meet the need

    for(var doc in sortedstocks){
      int currentStock = doc['quantity'];
      //if the stock in this batch is more than or equal to what is needed-> use it.
      if (currentStock >= quantity) {
        targetstockdoc = doc;
        break; // found it, exit loop!!!!
      }

    }

    if (targetstockdoc == null) {
      // if there is not sufficient stock in any lot
      throw Exception("Insufficient Stock in single batch! Required: $quantity for $productName");
    }
    
    //!!!!!!___!!!!!!!!
    //start transaction
    await firestore.runTransaction((transaction) async {

      //read the fresh snapshot of the stock
      DocumentSnapshot stocksnapshot = await transaction.get(targetstockdoc!.reference);

      if(!stocksnapshot.exists){
        throw Exception("Product has been removed from the database");
      }

      //get data
      int currentquantity = stocksnapshot['quantity'];
      String category = stocksnapshot['category'];
      String? currentlotNumber;

      if(category == "RUTF"){
        currentlotNumber = stocksnapshot['lotNumber'];

      }else{
        currentlotNumber = null; //if the food is supplement(banana, etc)
      }

      //check if enough stock exists - guard code
      if (currentquantity < quantity) {
        throw Exception("Insufficient stock!");
      }

      //decrease from stock
      transaction.update(stocksnapshot.reference, {'quantity': currentquantity-quantity});

      //create distribution record -distribution history
      DocumentReference newDistributionRef=firestore.collection('distributions').doc();

      Map<String, dynamic> distributiondata ={
        'childdocId': childId,
        'childName': childname,
        'itemName': productName,
        'category': category, 
        'quantity': quantity,
        'distributedAt': FieldValue.serverTimestamp(),
        'status': 'Delivered'
      };

      if(currentlotNumber != null){ //if it rutf, then save the lot number too
        distributiondata['lotNumber'] = currentlotNumber;
      }

      transaction.set(newDistributionRef, distributiondata); //end the transaction hereeee
    });
  }
}
