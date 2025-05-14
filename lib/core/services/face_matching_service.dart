import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String apiUrl = "https://facematch-ulg3.onrender.com/match_faces/";

/// Function to compare extracted face with selfie
Future<bool> matchFaces(File extractedFace, File selfie) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    request.files.add(
        await http.MultipartFile.fromPath('license_image', extractedFace.path));
    request.files
        .add(await http.MultipartFile.fromPath('selfie_image', selfie.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseData);

    if (jsonResponse.containsKey("match")) {
      return jsonResponse["match"]; // Returns true if faces match
    } else {
      print("❌ API Error: ${jsonResponse["error"]}");
      return false;
    }
  } catch (e) {
    print("❌ Face Matching Error: $e");
    return false;
  }
}
