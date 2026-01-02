import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malnutrition_app/utils/formatting_helpers.dart';//used here for parseDateString


class DistributionService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //check if treatment plan has already been delivered 
  Future<bool> checkIfPlanDelivered({required String childId,required String treatmentPlanId }) async {

    try {
      //query distributions for the specific treatment plan
      final query = await firestore.collection('distributions').where('treatmentPlanId', isEqualTo: treatmentPlanId)
        .limit(1)//stop after finding just one match
        .get();

      //if we found any records->means plan is  delivered
      return query.docs.isNotEmpty;
    } catch (e) {
      //if error, return false 
      return false;
    }

    //returns true if there is at least one document, false if none.
  }

  //used in child_treatment_detailshelper
  Future<void> recorddistribution({required String childname,required String productName,required int quantity,
    required String treatmentPlanId,
  }) async{

    //find the product in stocks
    final stockquery = await firestore.collection('stocks')
      .where('productName', isEqualTo: productName)
      .get();//only filter by productName in firestore and handle the rest in memory with lisst

    
    //dont look stocks with quantity <= 0 in memory 
    List<QueryDocumentSnapshot> availableStocks = stockquery.docs
      .where((doc) => (doc['quantity'] as int) > 0)
      .toList();
    
    if (availableStocks.isEmpty) {
      
      throw Exception("$productName not found is out of stock!");
    }

    //find the most suitable lot - first in first out-use the one that expires first
     //list the documents and sort them by date
    List<QueryDocumentSnapshot> sortedstocks = availableStocks;

    sortedstocks.sort((a,b) {
      //convert dates from string to datetime object
      DateTime dateA = parseDateString(a['expirationDate']);
      DateTime dateB = parseDateString(b['expirationDate']);
      return dateA.compareTo(dateB);

    });

    DocumentSnapshot? targetstockdoc;//find the stock that is available to meet the need

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
    
    //reference pattern: https://firebase.google.com/docs/firestore/manage-data/transactions
    //!!!!!!___!!!!!!!!
    //start transaction
    await firestore.runTransaction((transaction) async {//ensures all reads/writes inside either all succeed together or fail together atomic

      //read the fresh snapshot of the stock
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
        currentlotNumber = null; //if the food is supplement(banana, etc)
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

      transaction.set(newDistributionRef, distributiondata); //end the transaction hereeee
    });
  }

  //used in child_treatment_detailshelper for undo
  Future <void> reversedistribution(String treatmentPlanId) async{

    //get data - query distributions OUTSIDE transaction
    final querydistribution = await firestore.collection('distributions').where('treatmentPlanId', isEqualTo: treatmentPlanId).get();
    
    if(querydistribution.docs.isEmpty){
      return; //nothing to reverse
    }

    //gather all stock references OUTSIDE the transaction to avoid transaction isolation issues
    //this map holds: distribution doc id -> stock document reference (if found)
    Map<String, DocumentReference?> stockReferencesMap = {};
    Map<String, int> quantitiesToRestore = {};

    for(var distributiondoc in querydistribution.docs){
      var distributiondata = distributiondoc.data();
      String productname = distributiondata['itemName'];
      int quantity = distributiondata['quantity'];
      String? lotnumber = distributiondata['lotNumber'];

      QuerySnapshot stocksnapshot;

      if(lotnumber != null){
        //if it's rutf find it by lot num
        stocksnapshot = await firestore.collection('stocks').where('productName', isEqualTo: productname)
          .where('lotNumber', isEqualTo: lotnumber).limit(1).get();
      }
      else{
        //if it is supplement find it by only name
        stocksnapshot = await firestore.collection('stocks').where('productName', isEqualTo: productname).limit(1).get();
      }

      if(stocksnapshot.docs.isNotEmpty){
        stockReferencesMap[distributiondoc.id] = stocksnapshot.docs.first.reference;
      } else {
        stockReferencesMap[distributiondoc.id] = null;
      }
      quantitiesToRestore[distributiondoc.id] = quantity;
    }

    //atomic process - now all reads are done, only writes inside transaction
    await firestore.runTransaction((transaction) async{

      //first, read all stock documents inside the transaction for consistency
      Map<String, DocumentSnapshot> stockSnapshots = {};
      for(var entry in stockReferencesMap.entries){
        if(entry.value != null){
          stockSnapshots[entry.key] = await transaction.get(entry.value!);
        }
      }

      //now perform all writes
      for(var distributiondoc in querydistribution.docs){
        String docId = distributiondoc.id;
        DocumentReference? stockRef = stockReferencesMap[docId];
        int quantity = quantitiesToRestore[docId] ?? 0;

        if(stockRef != null && stockSnapshots.containsKey(docId)){
          DocumentSnapshot lateststocksnap = stockSnapshots[docId]!;
          if(lateststocksnap.exists){
            int currentstockquantity = lateststocksnap['quantity'];
            transaction.update(stockRef, {'quantity': currentstockquantity + quantity});
          }
        }

        //delete the related distribution doc
        transaction.delete(distributiondoc.reference);
      }
    });
  }
}
