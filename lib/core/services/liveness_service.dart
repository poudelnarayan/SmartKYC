import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String apiUrl = "https://faceliveliness.onrender.com/detect_liveliness/";

/// Send video to AWS Rekognition API and print response
Future<String> detectLiveliness(File videoFile) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    // Attach the video file
    request.files
        .add(await http.MultipartFile.fromPath('video', videoFile.path));

    // Send the request
    var response = await request.send();

    // Read response
    var responseData = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseData);

    // Print response to console
    print("📢 API Response: $jsonResponse");
    return jsonResponse["message"];
  } catch (e) {
    print("❌ Liveliness Detection Error: $e");
    return "Error";
  }
}
