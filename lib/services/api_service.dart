import 'dart:convert';//convert json string to dart objects
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {

  final String baseurl = "https://food-detection.abasak.com/detect";//send the image to this url address
  final String apikey = "PP4d6Kksn9HgwVoJZ8TCUuAEpYgHTtAT";

  Future <Map<String, dynamic>?> detectFood(File imagefile) async{

    try{

      var request = http.MultipartRequest('POST', Uri.parse(baseurl));//create a multipart request -used for file uploads
      //POST method -> sending data
      request.headers['X-API-Key'] = apikey;//add api key to headers for security

      var filestream = await http.MultipartFile.fromPath('file', imagefile.path, contentType: MediaType('image', 'jpeg'));//file is key name expected by fastapi
      request.files.add(filestream);//add the image file to the request
    

      var streamedresponse = await request.send();//send the request to the server and wait for response
      var response = await http.Response.fromStream(streamedresponse);//convert the stream to a standard response object
      if(response.statusCode == 200){//check if the server accepted the request -200 ok

        var jsonresponse = json.decode(response.body);
        //decode the json response body -- string to map conversion

        if(jsonresponse['success'] == true && jsonresponse['detections'] != null){//check if success is true and if detection is not empty
          
          List<dynamic>detections = jsonresponse['detections'];
          if(detections.isNotEmpty){
            return detections[0];//return the first detected food item
          }

        }
        return null; //if failed
      }
      else{

        //server returned an error 
        print("Server Error: ${response.statusCode} - ${response.body}");
        return null;
      }


    }catch(e){
      // Network error -- no internet, tunnel closed
      print("Connection Error: $e");
      return null;


    }
    
  }





}