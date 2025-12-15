import 'dart:convert';//convert json string to dart objects
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:malnutrition_app/services/nutrition_datamodels.dart';

class ApiService {

  final String baseurl = "https://food-detection.abasak.com";//send the image to this url address
  final String apikey = "PP4d6Kksn9HgwVoJZ8TCUuAEpYgHTtAT";

  //this method is used for yolo-food detection
  Future <Map<String, dynamic>?> detectFood(File imagefile) async{

    final Uri url = Uri.parse("$baseurl/detect");

    try{

      var request = http.MultipartRequest('POST', url);//create a multipart request -used for file uploads
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

  //this method is used for getting LLM advice from endpoint /advice
  Future<String?> getAiAdvice(FullAdviceRequest request)async{
    
    final Uri url = Uri.parse("$baseurl/advice");

    try{

      final response = await http.post(
        url, 
        headers: {
          "Content-Type": "application/json",
          "X-API-Key": apikey,
        },
        // Encode the request as a JSON object
        body: jsonEncode(request.tojson()),
      );

      if(response.statusCode == 200){
        final Map<String, dynamic> data = jsonDecode(response.body);

        if(data['success'] == true){
          return data['advice'];
        }
        else{
          print("Server Error: ${response.statusCode} - ${response.body}");
        }

      }

    
    } catch (e){
      print("Advice Connection Error: $e");
    }

    return null;
  }





}