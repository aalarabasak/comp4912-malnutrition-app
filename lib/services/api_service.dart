import 'dart:convert';//convert json string to dart objects
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:malnutrition_app/services/nutrition_datamodels.dart';

class ApiService {

  final String baseurl = "<url>";
  final String apikey = "<api_key>";

  //used for yolo-food detection
  Future <Map<String, dynamic>?> detectFood(File imagefile) async{

    final Uri url = Uri.parse("$baseurl/detect");

    try{

      var request = http.MultipartRequest('POST', url);//create a multipart request -used for file uploads
      //POST method -> sending data
      request.headers['X-API-Key'] = apikey;//add api key to headers for security

      var filestream = await http.MultipartFile.fromPath('file', imagefile.path, contentType: MediaType('image', 'jpeg'));
      request.files.add(filestream);//add the image file to the request
    

      var streamedresponse = await request.send();//send the request to the server 
      var response = await http.Response.fromStream(streamedresponse);//convert the stream to a response object
      if(response.statusCode == 200){//check if the server accepted the request 

        var jsonresponse = json.decode(response.body);
        //decode the json response body -- string to map conversion

        if(jsonresponse['success'] == true && jsonresponse['detections'] != null){
          
          List<dynamic>detections = jsonresponse['detections'];
          if(detections.isNotEmpty){
            return detections[0];//return the first detected food item
          }

        }
        return null; 
      }
      else{

      
        print("Server Error: ${response.statusCode} - ${response.body}");
        return null;
      }


    }catch(e){
     
      print("Connection Error: $e");
      return null;


    }
    
  }

  //used for getting LLM advice from endpoint /advice
  Future<String?> getAiAdvice(FullAdviceRequest request)async{
    
    final Uri url = Uri.parse("$baseurl/advice");

    try{

      final response = await http.post(
        url, 
        headers: {
          "Content-Type": "application/json",
          "X-API-Key": apikey,
        },
        //encode the request JSON object
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