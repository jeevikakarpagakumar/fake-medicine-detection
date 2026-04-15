import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/medicine_result.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.40:5001';

  static Future<MedicineResult> verifyText(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-text'),
      body: {'text': text},
    );
    if (response.statusCode == 200) {
      return MedicineResult.fromJson(jsonDecode(response.body));
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  static Future<MedicineResult> uploadImage(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload-image'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      return MedicineResult.fromJson(jsonDecode(response.body));
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  static Future<String> sendChatMessage(String message, String? context) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "message": message,
        "context": context ?? ""
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["response"];
    } else {
      throw Exception('Chatbot error: ${response.statusCode}');
    }
  }
}