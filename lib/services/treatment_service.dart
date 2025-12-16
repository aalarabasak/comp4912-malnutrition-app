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
    required Map<String, dynamic>? supplements,//if there is no selection, it shoulf be null
  }) async{

    WriteBatch batch = firestore.batch();//batch start to combine two processes

    try{

      DocumentReference planref = firestore.collection('children').doc(childid).collection('treatmentPlans').doc();
      //save plan as a subcollection of children

      final plandata = {
        'createdAt': FieldValue.serverTimestamp(),
        'diagnosis': diagnosis,
        'nextvisitdate': nextvisitdate.toIso8601String(),
        'prescribed_RUTF': prescribedRUTF,
        'supplements': supplements,
      };

      batch.set(planref, plandata);

      DocumentReference childref = firestore.collection('children').doc(childid);
      batch.update(childref, {
        'treatmentStatus': 'Active',   //filtering will be done according to this attribute in the FW list
        'lastPlanDate': FieldValue.serverTimestamp(),
        'nextvisitdate':nextvisitdate.toIso8601String(),
      });

      await batch.commit(); //finish the processes

    }catch(e){
      throw Exception('Error occurred while saving plan: $e');
    }
  }

  //-------------
  //used in treatment plan card in profile page
  Stream <QuerySnapshot>getlatestTreatmentPlan(String childid){
    return firestore.collection('children').doc(childid)
      .collection('treatmentPlans').orderBy('createdAt',descending: true)//get the newest one
      .limit(1).snapshots(); //bring just oneeee
  }

  //used in treatment list screen to eliminate overdue visits and treatment plans
  Future<void> checkpastvisits() async {
    DateTime nowexact = DateTime.now(); //take the today's date
    DateTime todayStart = DateTime(nowexact.year, nowexact.month, nowexact.day); // made the time 00:00:00 

    var snapshot =await firestore.collection('children').where('treatmentStatus', isEqualTo: 'Active').get(); //get the active ones

    for(var doc in snapshot.docs){//enter the loop and check the date
      var data = doc.data(); 

      if(data['nextvisitdate'] != null){

        //String ->> datetime
        DateTime visitdate = DateTime.parse(data['nextvisitdate']);

        if(visitdate.isBefore(todayStart)){//if the date is older than today
          await doc.reference.update({'treatmentStatus' : 'Passive'});//make the status passive

        }
      }
    }
  }
}