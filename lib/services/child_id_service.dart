import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nanoid/nanoid.dart';

class ChildIdService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String _generaterawid(){
    return customAlphabet('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', 14);
  }

  Future <String> getuniqueid() async{

    String id= _generaterawid();
    bool isunique = false;

    while(!isunique){

      final QuerySnapshot result = await firestore.collection('children').where('childID', isEqualTo: id).limit(1).get();

      if(result.docs.isEmpty){
        isunique =true;
      }
      else{
        id = _generaterawid();
      }
    }
    return id;
  }
}