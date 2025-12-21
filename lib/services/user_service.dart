import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth= FirebaseAuth.instance;

  Future<void>addactivity({required String childId, required String activitytype, required String description})async{
    User? currentuser = auth.currentUser;

    if(currentuser != null){

      try{
        await firestore.collection('users').doc(currentuser.uid)
        .collection('recentActivities').add({
          'childId': childId, //for determine which child activity performed for
          'type': activitytype,
          'description': description,
          'timestamp': FieldValue.serverTimestamp(), 
        });
      }
      catch (e) {
        print("$e");
      }
    }

  }
}