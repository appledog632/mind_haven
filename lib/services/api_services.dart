import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart'; // For MIME type detection
import 'package:http_parser/http_parser.dart'; // Add this import

class ApiService {
  static const String _baseUrl = "http://192.168.50.212:8000";

  // Fetch concerns
  static Future<List<String>> fetchConcerns() async {
    final response = await http.get(Uri.parse("$_baseUrl/concerns"));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch concerns");
    }
  }

  // Fetch goals based on selected concerns
  static Future<List<String>> fetchGoals(List<String> concerns) async {
    final concernsParam = concerns.join("+");
    final response =
        await http.get(Uri.parse("$_baseUrl/goals/$concernsParam"));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch goals");
    }
  }

  static Future<List<String>> getQuestions(List<String> concerns) async {
    final String concernParams = concerns.join('+');
    final response = await http.get(
      Uri.parse('$_baseUrl/questions/$concernParams'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Failed to load questions');
    }
  }

  static Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    final uri = Uri.parse('http://192.168.50.212:8080/emotion'); // Update the URL as needed
    final request = http.MultipartRequest('POST', uri);

    try {
      // Get the MIME type of the image
      final mimeType = lookupMimeType(imageFile.path) ?? 'application/octet-stream';
      
      // Add the image file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // This should match the backend's expected parameter name
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Send the request and wait for the server response
      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      // Handle the response based on status code
      if (response.statusCode == 200) {
        // Parse the response if it's successful
        return jsonDecode(responseString);
      } else {
        throw Exception(
            'Server error (${response.statusCode}): $responseString');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<dynamic> submitAnswers(
      List<Map<String, dynamic>> answers) async {
    print('Submitting answers: $answers');
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/answers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(answers),
      );

      final responseData = jsonDecode(response.body);
      print("Response: $responseData");

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(
            'Failed to submit answers: ${responseData['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('Failed to submit answers: ${e.toString()}');
    }
  }

  static Future<String> chatWithCompanion(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chat/${Uri.encodeComponent(query)}'),
        // Removed incorrect Content-Type header since it's a GET request
      );
      print('Raw response: ${response.body}');

      if (response.statusCode == 200) {
        // Directly return the response body as it's already a string
        return response.body;
      } else {
        return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error connecting to the server: $e';
    }
  }
}
