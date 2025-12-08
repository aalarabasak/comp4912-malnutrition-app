import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String?> getcurrentriskstatus(String childId) async {
  
    final DocumentSnapshot childDoc = await firestore.collection('children').doc(childId) .get();
    
    if (childDoc.exists) {
      final Map<String, dynamic> childData = childDoc.data() as Map<String, dynamic>;
      return childData['currentRiskStatus'] as String?;
    }
    return null;
}

  Future <void> savetreatmentplan({
    required String childid,
    required String diagnosis,
    required DateTime nextvisitdate,
    required Map<String, dynamic>? prescribedRUTF,//if there is no selection, it shoulf be null
    required List<String>? supplements,//if there is no selection, it shoulf be null
  }) async{

    WriteBatch batch = firestore.batch();//batch start to combine two processes

    try{

      DocumentReference planref = firestore.collection('children').doc(childid).collection('treatmentPlans').doc();
      //save plan as a subcollection of children

      final plandata = {
        'createdAt': FieldValue.serverTimestamp(),
        'diagnosis': diagnosis,
        'nextvisitdate': Timestamp.fromDate(nextvisitdate),
        'prescribed_RUTF': prescribedRUTF,
        'supplements': supplements,
      };

      batch.set(planref, plandata);

      DocumentReference childref = firestore.collection('children').doc(childid);
      batch.update(childref, {
        'treatmentStatus': 'Active',   //filtering will be done according to this attribute in the FW list
        'lastPlanDate': FieldValue.serverTimestamp(),
      });

      await batch.commit(); //finish the processes

    }catch(e){
      throw Exception('Error occurred while saving plan: $e');
    }
  }
}