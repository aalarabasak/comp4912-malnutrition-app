import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malnutrition_app/utils/formatting_helpers.dart';//used here for parseDateString


class DistributionService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //check if treatment plan has already been delivered 
  Future<bool> checkIfPlanDelivered({required String childId,required String treatmentPlanId }) async {

    try {
      
      final query = await firestore.collection('distributions').where('treatmentPlanId', isEqualTo: treatmentPlanId)
        .limit(1)
        .get();

      
      return query.docs.isNotEmpty;
    } catch (e) {
      
      return false;
    }

    //returns true if there is at least one document
  }

  //used in child_treatment_detailshelper
  Future<void> recorddistribution({required String childname,required String productName,required int quantity,
    required String treatmentPlanId,
  }) async{

    //find the product in stocks
    final stockquery = await firestore.collection('stocks')
      .where('productName', isEqualTo: productName)
      .get();

    
    //dont look stocks with quantity <= 0 in memory 
    List<QueryDocumentSnapshot> availableStocks = stockquery.docs
      .where((doc) => (doc['quantity'] as int) > 0)
      .toList();
    
    if (availableStocks.isEmpty) {
      
      throw Exception("$productName not found is out of stock!");
    }

    //find the most suitable lot-fifo
     //list the documents and sort them by date
    List<QueryDocumentSnapshot> sortedstocks = availableStocks;

    sortedstocks.sort((a,b) {
     
      DateTime dateA = parseDateString(a['expirationDate']);
      DateTime dateB = parseDateString(b['expirationDate']);
      return dateA.compareTo(dateB);

    });

    DocumentSnapshot? targetstockdoc;

    for(var doc in sortedstocks){
      int currentStock = doc['quantity'];
  
      if (currentStock >= quantity) {
        targetstockdoc = doc;
        break; // found the suitable stock
      }

    }

    if (targetstockdoc == null) {
  
      throw Exception("Insufficient Stock in single batch! Required: $quantity for $productName");
    }
    
    //reference pattern: https://firebase.google.com/docs/firestore/manage-data/transactions
   
    //start transaction
    await firestore.runTransaction((transaction) async {//atomic

      //read the snapshot of the stock
      DocumentSnapshot stocksnapshot = await transaction.get(targetstockdoc!.reference);

      if(!stocksnapshot.exists){//double check
        throw Exception("Product has been removed from the database");
      }

      //get data
      int currentquantity = stocksnapshot['quantity'];
      String category = stocksnapshot['category'];
      String? currentlotNumber;

      if(category == "RUTF"){
        currentlotNumber = stocksnapshot['lotNumber'];

      }else{
        currentlotNumber = null; //if the food is supplement
      }

      //check if enough stock exists - guard code
      if (currentquantity < quantity) {//double check
        throw Exception("Insufficient stock!");
      }

      //decrease from stock
      transaction.update(stocksnapshot.reference, {'quantity': currentquantity-quantity});

      //create distribution record -distribution history
      DocumentReference newDistributionRef=firestore.collection('distributions').doc();

      Map<String, dynamic> distributiondata ={
        'childName': childname,
        'itemName': productName,
        'category': category, 
        'quantity': quantity,
        'distributedAt': FieldValue.serverTimestamp(),
        'treatmentPlanId': treatmentPlanId,
      };

      if(currentlotNumber != null){ //if it rutf, then save the lot number too
        distributiondata['lotNumber'] = currentlotNumber;
      }

      transaction.set(newDistributionRef, distributiondata); //end the transaction 
    });
  }

  //used in child_treatment_detailshelper for undo
  Future <void> reversedistribution(String treatmentPlanId) async{

    //get data
    final querydistribution = await firestore.collection('distributions').where('treatmentPlanId', isEqualTo: treatmentPlanId).get();
    
    //atomic process 
    await firestore.runTransaction((transaction) async{

      for(var distributiondoc in querydistribution.docs){

        var distributiondata = distributiondoc.data();
        String productname = distributiondata['itemName'];
        int quantity= distributiondata['quantity'];
        String? lotnumber = distributiondata['lotNumber'];

        QuerySnapshot stocksnapshot;//to find the correct stock of restore

        if(lotnumber != null){
          //if it s rutf find it by lot num
          stocksnapshot = await firestore.collection('stocks').where('productName', isEqualTo: productname)
            .where('lotNumber', isEqualTo: lotnumber).limit(1).get();
        }
        else{
          //if it is supplement find it by only name
          stocksnapshot = await firestore.collection('stocks').where('productName', isEqualTo: productname).limit(1).get();
        }

        if(stocksnapshot.docs.isNotEmpty){//stock record is found and update it

          DocumentReference stockreference = stocksnapshot.docs.first.reference; 

          DocumentSnapshot lateststocksnap = await transaction.get(stockreference); //read the current stock value
          if(lateststocksnap.exists){
            int currentstockquantity = lateststocksnap['quantity'];
            transaction.update(stockreference, {'quantity': currentstockquantity + quantity});
          }
        }

        //delete the related distribution doc
        transaction.delete(distributiondoc.reference);
      }
    });



  }
}
